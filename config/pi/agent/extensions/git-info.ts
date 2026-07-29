import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const GIT_INFO_EVENT = "dashboard:git-info";
const REFRESH_EVENT = "dashboard:refresh";

type PullRequest = { number: number; url: string };

export default function gitInfo(pi: ExtensionAPI) {
  let context: ExtensionContext | undefined;
  let generation = 0;

  const emitEmpty = () => {
    pi.events.emit(GIT_INFO_EVENT, {
      isRepository: false,
      branch: null,
      changedFiles: 0,
      pullRequest: null,
    });
  };

  const refresh = async (ctx = context) => {
    if (!ctx) return;
    const currentGeneration = ++generation;

    const repository = await pi.exec(
      "git",
      ["rev-parse", "--is-inside-work-tree"],
      { cwd: ctx.cwd, timeout: 3_000 },
    );
    if (currentGeneration !== generation || context !== ctx) return;
    if (repository.code !== 0 || repository.stdout.trim() !== "true") {
      emitEmpty();
      return;
    }

    const [branchResult, statusResult, pullRequestResult] = await Promise.all([
      pi.exec("git", ["branch", "--show-current"], {
        cwd: ctx.cwd,
        timeout: 3_000,
      }),
      pi.exec("git", ["status", "--porcelain=v1"], {
        cwd: ctx.cwd,
        timeout: 3_000,
      }),
      pi.exec("gh", ["pr", "view", "--json", "number,url"], {
        cwd: ctx.cwd,
        timeout: 3_000,
      }),
    ]);
    if (currentGeneration !== generation || context !== ctx) return;

    let pullRequest: PullRequest | null = null;
    if (pullRequestResult.code === 0) {
      try {
        const value = JSON.parse(pullRequestResult.stdout) as Partial<PullRequest>;
        if (typeof value.number === "number" && typeof value.url === "string") {
          pullRequest = { number: value.number, url: value.url };
        }
      } catch {
        // No pull request for this branch.
      }
    }

    const status = statusResult.stdout.trim();
    pi.events.emit(GIT_INFO_EVENT, {
      isRepository: true,
      branch: branchResult.stdout.trim() || null,
      changedFiles: status ? status.split("\n").length : 0,
      pullRequest,
    });
  };

  const stopRefreshListener = pi.events.on(REFRESH_EVENT, () => {
    void refresh();
  });

  pi.on("session_start", (_event, ctx) => {
    context = ctx;
    void refresh(ctx);
  });

  pi.on("agent_settled", (_event, ctx) => {
    context = ctx;
    void refresh(ctx);
  });

  pi.on("session_shutdown", () => {
    stopRefreshListener();
    generation += 1;
    context = undefined;
  });
}
