import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const MODEL_INFO_EVENT = "dashboard:model-info";
const REFRESH_EVENT = "dashboard:refresh";

type Usage = {
  output?: number;
  cost?: { total?: number };
};

type Message = {
  role?: string;
  usage?: Usage;
};

export default function modelInfo(pi: ExtensionAPI) {
  let context: ExtensionContext | undefined;
  let responseStartedAt: number | undefined;
  let tokensPerSecond: number | null = null;

  const getCost = (ctx: ExtensionContext) =>
    ctx.sessionManager.getBranch().reduce((total, entry) => {
      if (entry.type !== "message") return total;
      const message = entry.message as Message;
      return total + (message.usage?.cost?.total ?? 0);
    }, 0);

  const emit = (ctx = context) => {
    if (!ctx) return;
    const usage = ctx.getContextUsage();
    pi.events.emit(MODEL_INFO_EVENT, {
      provider: ctx.model?.provider ?? "",
      modelId: ctx.model?.id ?? "no-model",
      thinking: pi.getThinkingLevel(),
      contextWindow: usage?.contextWindow ?? ctx.model?.contextWindow ?? 0,
      contextPercent: usage?.percent ?? null,
      contextTokens: usage?.tokens ?? null,
      cost: getCost(ctx),
      tokensPerSecond,
    });
  };

  const stopRefreshListener = pi.events.on(REFRESH_EVENT, () => emit());

  pi.on("session_start", (_event, ctx) => {
    context = ctx;
    responseStartedAt = undefined;
    tokensPerSecond = null;
    emit(ctx);
  });

  pi.on("model_select", (_event, ctx) => {
    context = ctx;
    emit(ctx);
  });

  pi.on("thinking_level_select", (_event, ctx) => {
    context = ctx;
    emit(ctx);
  });

  pi.on("message_start", (event, ctx) => {
    const message = event.message as Message;
    if (message.role !== "assistant") return;
    context = ctx;
    responseStartedAt = Date.now();
  });

  pi.on("message_end", (event, ctx) => {
    const message = event.message as Message;
    if (message.role !== "assistant") return;

    context = ctx;
    const elapsedSeconds = responseStartedAt
      ? (Date.now() - responseStartedAt) / 1_000
      : 0;
    const outputTokens = message.usage?.output;
    tokensPerSecond =
      elapsedSeconds > 0 && typeof outputTokens === "number"
        ? outputTokens / elapsedSeconds
        : null;
    responseStartedAt = undefined;
    emit(ctx);
  });

  pi.on("session_shutdown", () => {
    stopRefreshListener();
    context = undefined;
    responseStartedAt = undefined;
  });
}
