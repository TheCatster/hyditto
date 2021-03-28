(import
  [.config [Config]]
  [.embeds [create-embed wait-for-choice]])

(setv config (Config))

(defn get-guild-prefix [_bot guild-id]
  (setv prefix config.prefix)
  (try
    (setv guild-data (get _bot.guild-data guild-id))
    (setv _prefix guild-data.prefix)
    (if (_prefix is not None) (setv prefix _prefix))
    (except [KeyError]
      None))
  (return prefix))
