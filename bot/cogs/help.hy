(import
  discord
  [discord.ext [commands]]
  [bot.utils [create_embed get_guild_prefix]]
  [bot.utils.helpers [get_create_user]])


(defn/a create_bot_help [embed mapping]
  (lfor [cog cmds] (.items mapping)
    (do
      (setv cmd-str "")
      (for [cmd [cmds]]
        (setv cmd (get cmd 0))
        (if-not (and cmd.hidden (< (len cmd.checks) 1))
          (setv cmd_str (+ cmd_str f"`{cmd.name}`: {cmd.short_doc}\n"))))
    (if cmd_str
      (.add_field embed :name cog.qualified_name :value cmd_str :inline False))))
  (return embed))


(defclass Help [commands.Cog]
  (defn __init__ [self bot]
    (setv self.bot bot))
  #@((.listener commands.Cog)
      (defn/a on_ready [self]
        (print "Help Cog ready.")))
  (defn get_bot_mapping [self]
    #[[Retrieves the bot mapping passed to :meth:`send_bot_help`.]]
    (setv bot self.bot)
    (return (dfor cog (.values bot.cogs) [cog (.get_commands cog)])))
  (defn/a admin_help [self ctx &optional ^str [command_name None]]
    (setv prefix (get_guild_prefix ctx.bot ctx.guild.id))
    (setv embed (await
                  (create_embed
                    :title "Help"
                    :description f"*Use `{prefix}help <command-name>` to get a more detailed help for a specific command!*\n`<value>` is for required arguments and `[value]` for optional arguments!")))
    (.set_footer embed
      :text "Thank you for using Ditto!"
      :icon_url self.bot.user.avatar_url)
    (if-not command_name
      (do
        (setv cmd (.get ctx.bot.all_commands command_name))
        (if cmd
          (do
            (.add_field embed :name cmd.name :value (.format cmd.help :prefix prefix))
            (return (await (.send ctx :embed embed)))))))
    (setv embed (await (create_bot_help embed (.get_bot_mapping self))))
    (await (.send ctx :embed embed)))
  #@((.command commands)
      (defn/a help [self ctx &optional ^str [command_name None]]
        #[[*Shows this help message*]]
        (await (get_create_user ctx.message.author.id))
        (if ctx.message.author.guild_permissions.administrator
          (do
            (await (.admin_help self ctx))
            (return)))
        (setv prefix (get_guild_prefix ctx.bot ctx.guild.id))
        (setv embed (await
                      (create_embed
                        :title "Help"
                        :description f"*Use `{(prefix)}help <command-name>` to get a more detailed help for a specific command!*\n`<value>` is for required arguments and `[value]` for optional arguments!")))
        (.set_footer embed
          :text "Thank you for using Ditto!"
          :icon_url self.bot.user.avatar_url)
        (if-not command_name
          (do
            (setv cmd (.get ctx.bot.all_commands command_name))
            (if cmd
              (do
                (.add_field embed :name cmd.name :value (.format cmd.help :prefix prefix))
                (return (await (.send ctx :embed embed)))))))
        (setv embed (await (create_bot_help embed (.get_bot_mapping self))))
        (await (.send ctx :embed embed)))))


(defn setup [bot]
  (.add_cog bot (Help bot)))
