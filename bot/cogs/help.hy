(import
  discord
  [discord.ext [commands]]
  [bot.utils [create-embed get-guild-prefix]]
  [bot.utils.helpers [get-create-user]])


(defn/a create-bot-help [embed mapping]
  (for [[cog cmds] (.items mapping)]
      (setv cmd-str "")
      (for [cmd cmds]
        (setv cmd (get cmd 0))
        (if-not (and cmd.hidden (< (len cmd.checks) 1))
          (setv cmd-str (+ cmd-str f"`{cmd.name}`: {cmd.short-doc}\n")))))
    (if cmd-str
      (.add-field embed :name cog.qualified-name :value cmd-str :inline False))))
  (return embed))


(defclass Help [commands.Cog]
  (defn __init__ [self bot]
    (setv self.bot bot))
  #@((.listener commands.Cog)
      (defn/a on-ready [self]
        (print "Help Cog ready.")))
  (defn get-bot-mapping [self]
    #[[Retrieves the bot mapping passed to :meth:`send-bot-help`.]]
    (setv bot self.bot)
    (return (dfor cog (.values bot.cogs) [cog (.get-commands cog)])))
  (defn/a admin-help [self ctx &optional ^str [command-name None]]
    (setv prefix (get-guild-prefix ctx.bot ctx.guild.id))
    (setv embed (await
                  (create-embed
                    :title "Help"
                    :description f"*Use `{prefix}help <command-name>` to get a more detailed help for a specific command!*\n`<value>` is for required arguments and `[value]` for optional arguments!")))
    (.set-footer embed
      :text "Thank you for using Ditto!"
      :icon-url self.bot.user.avatar-url)
    (if command-name
      (do
        (setv cmd (.get ctx.bot.all-commands command-name))
        (if cmd
          (do
            (.add-field embed :name cmd.name :value (.format cmd.help :prefix prefix))
            (return (await (.send ctx :embed embed)))))))
    (setv embed (await (create-bot-help embed (.get-bot-mapping self))))
    (await (.send ctx :embed embed)))
  #@((.command commands)
      (defn/a help [self ctx &optional ^str [command-name None]]
        #[[*Shows this help message*]]
        (await (get-create-user ctx.message.author.id))
        (if ctx.message.author.guild-permissions.administrator
          (do
            (await (.admin-help self ctx command-name))
            (return)))
        (setv prefix (get-guild-prefix ctx.bot ctx.guild.id))
        (setv embed (await
                      (create-embed
                        :title "Help"
                        :description f"*Use `{(prefix)}help <command-name>` to get a more detailed help for a specific command!*\n`<value>` is for required arguments and `[value]` for optional arguments!")))
        (.set-footer embed
          :text "Thank you for using Ditto!"
          :icon-url self.bot.user.avatar-url)
        (if command-name
          (do
            (setv cmd (.get ctx.bot.all-commands command-name))
            (if cmd
              (do
                (.add-field embed :name cmd.name :value (.format cmd.help :prefix prefix))
                (return (await (.send ctx :embed embed)))))))
        (setv embed (await (create-bot-help embed (.get-bot-mapping self))))
        (await (.send ctx :embed embed)))))


(defn setup [bot]
  (.add-cog bot (Help bot)))
