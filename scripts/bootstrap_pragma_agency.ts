import { spawnSync } from "node:child_process";
import { mkdir, readFile } from "node:fs/promises";
import { join } from "node:path";
import { pathToFileURL } from "node:url";

const sourceRoot = process.env.PRAGMA_SOURCE_ROOT;
const pragmaHome = process.env.PRAGMA_HOME;
const bundlePath = process.env.PRAGMA_AGENCY_BUNDLE;
const mode = process.env.PRAGMA_AGENCY_MODE ?? "verify";
const runtimeId = process.env.PRAGMA_AGENCY_RUNTIME_ID ?? "codex";
const providerId = process.env.PRAGMA_AGENCY_PROVIDER_ID ?? "openai";
const modelId = process.env.PRAGMA_AGENCY_MODEL ?? "gpt-5.6-luna";
const EXPECTED_AGENCY_COUNT = 275;

if (sourceRoot === undefined || pragmaHome === undefined || bundlePath === undefined) {
  throw new Error("PRAGMA_SOURCE_ROOT, PRAGMA_HOME and PRAGMA_AGENCY_BUNDLE are required.");
}

const moduleUrl = (relativePath: string): string =>
  pathToFileURL(join(sourceRoot, relativePath)).href;

const core = await import(moduleUrl("packages/core/src/index.ts"));
const { PragmaPaths } = core;
const { createPragmaProjectStore } = await import(
  moduleUrl("apps/desktop/src/main/features/projects/pragma-project-store.ts"),
);
const { createCapabilityStore } = await import(
  moduleUrl("apps/desktop/src/main/features/capabilities/capability-store.ts"),
);
const { createCapabilityCredentialStore } = await import(
  moduleUrl("apps/desktop/src/main/features/capabilities/capability-credential-store.ts"),
);
const { createCapabilityVerifier } = await import(
  moduleUrl("apps/desktop/src/main/features/capabilities/capability-verifier.ts"),
);
const { createContextStoreStore } = await import(
  moduleUrl("apps/desktop/src/main/features/context-stores/context-store-store.ts"),
);
const { createPluginCredentialStore } = await import(
  moduleUrl("apps/desktop/src/main/features/plugins/plugin-credential-store.ts"),
);
const { createPluginStore } = await import(
  moduleUrl("apps/desktop/src/main/features/plugins/plugin-store.ts"),
);
const { createWorkflowLayoutStore } = await import(
  moduleUrl("apps/desktop/src/main/features/projects/workflow-layout-store.ts"),
);
const { createPragmaBundleService } = await import(
  moduleUrl("apps/desktop/src/main/features/bundles/pragma-bundle-service.ts"),
);
const { canonicalPragmaResourceRef } = await import(
  moduleUrl("packages/interpreter/src/ast/index.ts"),
);

const noEncryption = {
  isAvailable: () => false,
  encrypt: (_value: string): Buffer => {
    throw new Error("No credentials are accepted by the bootstrap helper.");
  },
  decrypt: (_value: Buffer): string => {
    throw new Error("No credentials are accepted by the bootstrap helper.");
  },
};

const codexAvailable =
  process.platform === "win32"
    ? spawnSync("where.exe", ["codex"], { encoding: "utf8" }).status === 0
    : spawnSync("sh", ["-lc", "command -v codex"], { encoding: "utf8" }).status === 0;

const paths = new PragmaPaths({ pragmaHome });
await Promise.all(
  [
    paths.stateRoot(),
    paths.dataRoot(),
    paths.workspaceRoot(),
    paths.cacheRoot(),
    paths.archivesRoot(),
    paths.temporaryRoot(),
    paths.trashRoot(),
    paths.projectsRoot(),
    paths.contentObjectsRoot(),
    paths.credentialsRoot(),
    paths.pluginsRoot(),
  ].map((directory) => mkdir(directory, { recursive: true, mode: 0o700 })),
);

const project = createPragmaProjectStore({
  projectsPath: paths.projectsRoot(),
  objectsPath: paths.contentObjectsRoot(),
  projectViewsPath: paths.projectViewsCacheRoot(),
  storagePaths: paths,
});
const capabilityCredentials = createCapabilityCredentialStore({
  configPath: join(paths.credentialsRoot(), "capability-credentials.json"),
  encryption: noEncryption,
});
const mcpToolRegistryPool = core.createMcpToolRegistryPool();
const capabilities = createCapabilityStore({
  capabilitiesPath: join(paths.dataRoot(), "capabilities"),
  credentials: capabilityCredentials,
  mcpToolRegistryPool,
  verify: createCapabilityVerifier(capabilityCredentials, mcpToolRegistryPool),
  isReferenced: async () => false,
});
const contextStores = createContextStoreStore({
  storesPath: join(paths.dataRoot(), "context-stores"),
  isReferenced: async () => false,
});
const pluginCredentials = createPluginCredentialStore({
  configPath: join(paths.credentialsRoot(), "plugin-credentials.json"),
  encryption: noEncryption,
});
const plugins = createPluginStore({
  builtInPluginsPath: join(sourceRoot, "apps/desktop/.plugin-bundles/plugins"),
  userPluginsPath: paths.pluginsRoot(),
  paths,
  credentials: pluginCredentials,
  isReferenced: async () => false,
});
const layouts = createWorkflowLayoutStore({ projectsPath: paths.projectsRoot() });
const getRuntimes = async () => [
  {
    id: runtimeId,
    origin: "built-in",
    isDefault: true,
    kind: "codex",
    displayName: "Codex Local Runtime",
    status: codexAvailable ? "available" : "unavailable",
    models: [
      {
        id: modelId,
        displayName: modelId,
        provider: { kind: "runtime-managed", id: providerId, displayName: providerId },
      },
    ],
    ...(codexAvailable ? {} : { reason: "The Codex CLI was not found on PATH." }),
  },
];
const bundleService = createPragmaBundleService({
  paths,
  project,
  capabilities,
  contextStores,
  plugins,
  layouts,
  getRuntimes,
});
await bundleService.initialize();

type Installation = Awaited<ReturnType<typeof bundleService.listInstallations>>[number];

async function inspectState() {
  const snapshot = await project.get();
  const capabilityList = await capabilities.list();
  const installations = await bundleService.listInstallations();
  const agencyExperts = snapshot.resources.filter(
    (resource: any) =>
      resource.kind === "Expert" &&
      Array.isArray(resource.metadata?.tags) &&
      resource.metadata.tags.includes("agency-agent"),
  );
  const agencySkills = capabilityList.filter(
    (capability: any) =>
      capability.definition?.kind === "skill" &&
      (String(capability.manifest?.name ?? "").endsWith(" Skill") ||
        String(capability.definition?.name ?? "").endsWith(" Skill")),
  );
  const agencyInstallations = installations.filter((installation: any) =>
    String(installation.rootName).includes("Agency"),
  );
  const pending = [] as Array<{ root: string; pending: boolean }>;
  for (const installation of agencyInstallations) {
    pending.push({
      root: installation.rootRef,
      pending: await bundleService.isRefPending(installation.rootRef),
    });
  }
  return {
    projectId: snapshot.projectId,
    projectRevision: snapshot.revision,
    resourceCount: snapshot.resources.length,
    agencyExpertCount: agencyExperts.length,
    agencySkillCount: agencySkills.length,
    readySkillCount: agencySkills.filter((capability: any) => capability.health?.status === "ready").length,
    installationCount: installations.length,
    agencyInstallations: agencyInstallations.map((installation: any) => ({
      id: installation.id,
      rootName: installation.rootName,
      rootRef: installation.rootRef,
      status: installation.status,
      projectRevision: installation.projectRevision,
      pending: installation.pending,
    })),
    pending,
    codexAvailable,
  };
}

async function installBundle(sourcePath: string): Promise<Installation> {
  const inspection = await bundleService.inspect(sourcePath);
  console.log(
    JSON.stringify(
      {
        action: "inspect",
        bundle: sourcePath,
        root: inspection.root,
        roots: inspection.roots.length,
        resourceCount: inspection.resources.length,
        dependencyCount: inspection.dependencies.length,
        requirementCount: inspection.requirements.length,
        conflicts: inspection.conflicts.length,
      },
      null,
      2,
    ),
  );
  const existing = (await bundleService.listInstallations()).find(
    (installation: any) =>
      installation.bundleFingerprint === inspection.bundleFingerprint &&
      installation.sourceRootRef === inspection.root.ref,
  );
  if (existing?.status === "ready") {
    console.log(`Bundle already ready: ${existing.rootName} (${existing.id})`);
    return existing;
  }

  const installation = await bundleService.startImport({
    sourcePath,
    rootRef: inspection.root.ref,
    expectedFingerprint: inspection.bundleFingerprint,
    expectedProjectFingerprint: inspection.projectFingerprint,
    expectedProjectRevision: inspection.projectRevision,
    conflicts: inspection.conflicts.map((conflict: any) => ({
      resourceRef: conflict.resourceRef,
      action: "copy" as const,
    })),
    runtimes: inspection.requirements
      .filter((requirement: any) => requirement.kind === "runtime")
      .map((requirement: any) => ({
        requirementId: requirement.id,
        resourceRef: requirement.resourceRef,
        runtimeId: requirement.runtimeRequest?.runtimeId ?? runtimeId,
        providerId: requirement.runtimeRequest?.providerId ?? providerId,
        modelId: requirement.runtimeRequest?.modelId ?? modelId,
        ...(requirement.runtimeRequest?.thinkingLevel === undefined
          ? {}
          : { thinkingLevel: requirement.runtimeRequest.thinkingLevel }),
      })),
    capabilities: [],
    contextStores: [],
    secrets: {},
  });
  if (installation.status === "needs_setup") {
    const runtimePending = installation.pending.filter((item: any) => item.kind === "runtime");
    if (runtimePending.length > 0) {
      throw new Error(
        `Codex Local Runtime is unavailable; refusing to mark the Bundle ready: ${runtimePending
          .map((item: any) => item.message)
          .join("; ")}`,
      );
    }
    throw new Error(
      `Bundle import still needs setup: ${installation.pending.map((item: any) => item.message).join("; ")}`,
    );
  }
  if (installation.status !== "ready") {
    throw new Error(`Bundle import failed: ${installation.error ?? installation.status}`);
  }
  return installation;
}

if (mode === "install") {
  await installBundle(bundlePath);
  const state = await inspectState();
  if (state.agencyExpertCount < EXPECTED_AGENCY_COUNT || state.agencySkillCount < EXPECTED_AGENCY_COUNT) {
    throw new Error(`Post-install count check failed: ${JSON.stringify(state)}`);
  }
  console.log(JSON.stringify({ ok: true, mode, state }, null, 2));
} else if (mode === "verify") {
  const state = await inspectState();
  const allReady =
    state.agencyExpertCount >= EXPECTED_AGENCY_COUNT &&
    state.agencySkillCount >= EXPECTED_AGENCY_COUNT &&
    state.readySkillCount >= EXPECTED_AGENCY_COUNT &&
    state.agencyInstallations.length > 0 &&
    state.agencyInstallations.every((installation: any) => installation.status === "ready") &&
    state.pending.every((item) => item.pending === false);
  console.log(JSON.stringify({ ok: allReady, mode, state }, null, 2));
  if (!allReady) process.exitCode = 1;
} else {
  throw new Error(`Unsupported PRAGMA_AGENCY_MODE: ${mode}`);
}
