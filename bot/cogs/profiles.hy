(import
  discord
  [discord.ext [commands]]
  [bot.database.models [Profile]]
  [bot.utils [create-embed get-guild-prefix]]
  [bot.utils.helpers [get-create-user]])


(defn/a query-profile [^int user-id]
  #[[: query profile, create if not exist]]
  (setv profile (await (.get Profile user-id)))
  (if-not profile
    (setv profile (await (.create Profile :user-id user-id))))
  (return profile))


(defn/a send-changed-embed [ctx ^str changed ^str before ^str after]
  (setv embed (await (create-embed :description f"*{changed} changed*")))
  (.set-thumbnail embed :url ctx.author.avatar-url)
  (.add_field embed :name "From" :value before)
  (.add_field embed :name "To" :value after)
  (await (.send ctx :embed embed)))


(defclass Profiles [commands.Cog]
  (defn __init__ [self bot]
    (setv self.bot bot))
  #@((.listener commands.Cog)
      (defn/a on-ready [self]
        (print "Profiles Cog ready.")))
  #@((.group commands :invoke-without-command True :pass-context True)
      (defn/a profile [self ctx &optional ^discord.User [user-check None]]
        #[[*Look up your or your friends profile*

        `[user]` is optional and either a user-id or a user mention
        **Usage**: `{prefix}profile [user]`
        **Example**: `{prefix}profile`

        To setup your own profile use the following commands
        **Usage**: `{prefix}profile <key> <value>`
        **Possible keys**:
            `island, name, fruit, hemisphere, fc, flower, airport, timezone`
        **Examples**:
            `{prefix}profile name Ditto`
            `{prefix}profile fc SW-000-0000`
            `{prefix}profile timezone NYC`]]
        (setv author user-check)
        (if-not author
          (setv author ctx.author))
        (setv user (await (get-create-user ctx.message.author.id)))
        (setv profile (await (query-profile user.id)))
        (setv embed (await (create-embed)))
        (if user.level
          (.add-field embed :name ":level_slider: Level" :value user.level))
        (if user.xp
          (.add-field embed :name ":bar_chart: XP" :value user.xp))
        (if user.times-hosted
          (.add-field embed :name ":metal: Times Hosted" :value user.times-hosted))
        (if-not (= profile.user_name "Not Set")
          (do
            (.add-field embed :name "Character Name" :value profile.user-name)
            (.add-field embed :name "\u200c" :value "\u200c")))
        (if profile.timezone
          (.add-field embed :name ":clock130: Timezone" :value profile.timezone))
        (if profile.friend-code
          (.add-field embed :name "Friend Code" :value profile.friend-code))
        (if embed.fields
          (do
            (.set-thumbnail embed :url author.avatar-url)
            (.set-footer embed :text f"Profile of {author.name}#{author.discriminator}"))
          (do
            (if user-check
              (do
                (setv embed.description f"{user-check.mention} hasn't configured their profile yet!"))
              (do
                (setv prefix (get-guild-prefix self.bot ctx.guild.id))
                (setv embed.description
                    #[f[**You haven't configured your profile yet!**\n
                    To configure your profile use: \n`{prefix}profile <key> <value>`\n
                    **Possible keys**: \n
                    `name, fc, timezone`\n
                    **Examples**:\n
                    `{prefix}profile name Ditto`\n
                    `{prefix}profile fc SW-000-0000`\n
                    `{prefix}profile timezone NYC`\n]f]
                )))))
        (await (.send ctx :embed embed))))
  #@((.command profile :aliases ["name" "username"])
      (defn/a character [self ctx &rest ^str character-name]
        (setv profile (await (query-profile ctx.author.id)))
        (setv character-name (.join " " character-name))
        (await (send-changed-embed
                  ctx
                  :changed "Character name"
                  :before profile.user-name
                  :after character-name))
        (await (.apply (.update profile :user-name character-name)))))
  #@((.command profile :aliases ["fc" "code"])
      (defn/a friendcode [self ctx ^str friend-code]
        (setv profile (await (query-profile ctx.author.id)))
        (setv friend-code (.upper friend-code))
        (if-not (in "SW-" friend-code)
          (setv friend-code f"SW-{friend-code}"))
        (await (send-changed-embed
                  ctx
                  :changed "Friend code"
                  :before profile.friend-code
                  :after friend-code))
        (await (.apply (.update profile :friend-code friend-code)))))
  #@((.command profile)
      (defn/a timezone [self ctx &rest timezone]
        (setv profile (await (query-profile ctx.author.id)))
        (setv timezone (.join " " timezone))
        (setv before profile.timezone)
        (if-not before
          (setv before "Not Set"))
        (await (.apply (.update profile :timezone timezone)))
        (await (send-changed-embed
                  ctx
                  :changed "Timezone"
                  :before before
                  :after profile.timezone)))))


(defn setup [bot]
  (.add_cog bot (Profiles bot)))
