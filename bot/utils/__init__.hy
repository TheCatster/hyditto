(import
  [.config [Config]]
  [.embeds [create_embed wait_for_choice]])

(setv config Config)

(defn get_guild_prefix [_bot guild_id]
  (setv prefix (.prefix config))
  (try
    (setv guild_data (get (.guild_data _bot) guild_id))
    (setv _prefix (.prefix guild_data))
    (if (_prefix is not None) (setv prefix _prefix))
    (except [KeyError]
      None))
  (return prefix))
