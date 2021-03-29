(import
  random
  discord
  [discord.ext [commands]]
  [bot.utils [create-embed get-guild-prefix]]
  [bot.database.models [Raid]]
  [bot.utils.helpers [chunk get-create-user update-xp]]
  [disputils [BotEmbedPaginator]])


(defclass Raids [commands.Cog]
  #[[:video_game:]]
  (defn __init__ [self bot]
    (setv self.bot bot))
  #@((.command commands)
      (defn/a raids [self ctx]
        #[[*Look at available raids.*

        **Usage**: `{prefix}raids`
        **Example**: `{prefix}raids`]]
        (setv raids (lfor raid (.values self.bot.raid-data) (if (= raid.guild-id ctx.guild.id) raid)))
        (if (= (len raids) 0)
          (do
            (await (.send ctx "There are currently no raids running. You should start one!"))
            (return)))
        (setv raid-list [])
        (try
          (for [chunked (chunk raids 5)]
            (.append raid-list
              (lfor raid chunked f"\n\n**-** {(if raid.gmax ('Gmax') (''))} {(if raid.shiny ('Shiny') (''))} {(.capitalize raid.pokemon)}")))
          (except [e [Exception]]
            (print e)
            (await (.send ctx "An error has occurred."))
            (return)))
        (if (> (len raids) 0)
          (do
            (setv description [])
            (for [page raid-list]
              (setv de-string "")
              (for [item page]
                (setv de-string (+ de-string item)))
              (.append description de-string))
            (setv embed (lfor page description (.Embed discord :description (+ "**Current Raids:**" page) :color (.purple discord.Colour))))
            (setv paginator (BotEmbedPaginator ctx embeds))
            (await (.run paginator)))
          (await (.send ctx "No raids are running.")))))
  #@((.command commands)
      (defn/a queue [self ctx &rest ^str pokemon]
        #[[*Look up a raid's queue*

        `[pokemon]` is the name of the Pokemon raid you want to view.
        **Usage**: `{prefix}queue [pokemon]`
        **Example**: `{prefix}queue Pikachu`]]
        (await (.wait-until-ready self.bot))
        (setv raid None)
        (for [[raid-id raid] (.items self.bot.raid-data)]
          (if (and (= raid.pokemon (.lower pokemon)) (= raid.guild-id ctx.guild.id))
            (do
              (setv raid raid)
              (break))
            (setv raid None)))
        (if-not raid
          (do
            (await (.send ctx "There is no raid running with that Pokemon, or you did not specify a Pokemon, try using this command again."))
            (return)))
        (setv users (lfor user (.values self.bot.queue-data) (if (and (= (get user "guild-id") ctx.guild.id) (= (get user "raid-id") raid.id)) user)))
        (if (> (len users) 0)
          (do
            (setv description [])
            (setv raid-pokemon "")
            (if raid.gmax
              (setv raid-pokemon (+ raid-pokemon "Gmax ")))
            (if raid.shiny
              (setv raid-pokemon (+ raid-pokemon "Shiny ")))
            (setv raid-pokemon (+ raid-pokemon (.capitalize raid.pokemon))))
          (await (.send ctx "There is no raid running with that Pokemon, or you did not specify a Pokemon, try using this command again."))
          (try
            (setv user-list (lfor ))
            (except [e [Exception]]
              (print e)
              (await (.send ctx "An error has occurred."))
              (return)))))))

            try:
                user_list = [
                    [f"**-** <@{user['user_id']}>\n" for user in chunked]
                    for chunked in chunk(users, 5)
                ]

            for page in user_list:
                de_string = ""
                for item in page:
                    de_string += item
                description.append(de_string)

            embeds = [
                discord.Embed(
                    title="Raid Queue",
                    description=f"**Current Pokemon:** "
                    f"{raid_pokemon}\n\n"
                    f"Current Queue:\n" + page,
                    color=discord.Colour.purple(),
                )
                for page in description
            ]

            try:
                for embed in embeds:
                    embed.set_thumbnail(url=self.bot.pokemon_images[pokemon.lower()])

            except Exception as e:
                print(e)
                await ctx.send(
                    "An image for this pokemon cannot be found... contact the dev regarding this issue."
                )
                return

            paginator = BotEmbedPaginator(ctx, embeds)
            await paginator.run()

    @commands.command()
    async def join(self, ctx, *, raid_pokemon: str):
        """*Join an existing Pokemon raid.*

        `[pokemon]` is the Pokemon raid you want to join
        **Usage**: `{prefix}join [pokemon]`
        **Example**: `{prefix}join Pikachu`
        """
        raid = None
        for raid_id, raid in self.bot.raid_data.items():
            if raid.pokemon == raid_pokemon.lower() and raid.guild_id == ctx.guild.id:
                raid = raid
                break
            else:
                raid = None
        if raid:
            host_id = raid.host_id
            queue = [
                user
                for user in self.bot.queue_data.values()
                if user["raid_id"] == raid.id
                if user["guild_id"] == ctx.guild.id
            ]
            if len(queue) == 0:
                await ctx.send("No raid is running for this pokemon.")
                self.bot.raid_data.pop(raid.id, None)
                await raid.delete()
                return
            if ctx.message.author not in queue:
                self.bot.queue_data[f"{raid.id}+{ctx.message.author.id}"] = {
                    "raid_id": raid.id,
                    "user_id": ctx.message.author.id,
                    "guild_id": ctx.guild.id,
                }

                host = await get_create_user(host_id)
                if len(queue) >= 4:
                    await update_xp(user=host, modifier=0.2)
                else:
                    await update_xp(user=host, modifier=0)

                participant = await get_create_user(ctx.message.author.id)

                await update_xp(user=participant, modifier=0)

                await ctx.send(
                    f"Added to queue for the {raid.pokemon.capitalize()} raid!"
                )
            else:
                await ctx.send("You are already in the queue for this raid.")
                return
        else:
            await ctx.send("No raid is running for this pokemon.")
            return

    @commands.command()
    async def leave(self, ctx, *, raid_pokemon: str):
        """*Leave a raid you are in.*

        `[pokemon]` is the Pokemon raid you want to leave
        **Usage**: `{prefix}leave [pokemon]`
        **Example**: `{prefix}leave Pikachu`
        """
        raid = None
        for raid_id, raid in self.bot.raid_data.items():
            if raid.pokemon == raid_pokemon.lower() and raid.guild_id == ctx.guild.id:
                raid = raid
                break
            else:
                raid = None
        if raid:
            queue = [
                user["user_id"]
                for user in self.bot.queue_data.values()
                if user["raid_id"] == raid.id
                if user["guild_id"] == ctx.guild.id
            ]
            if ctx.message.author.id == raid.host_id:
                await ctx.send(
                    "You cannot leave your own raid. Please close it if you are done hosting."
                )
                return
            elif ctx.message.author.id not in queue:
                await ctx.send("You are not in the queue for this raid.")
                return
            else:
                await ctx.send(
                    f"Removed from the queue for the {raid.pokemon.capitalize()} raid!"
                )
                self.bot.queue_data.pop(f"{raid.id}+{ctx.message.author.id}", None)
                return
        else:
            await ctx.send("No such raid.")
            return

    @commands.command()
    async def host(self, ctx, gmax: str, shiny: str, *, pokemon_name: str):
        """*Host your own Pokemon raid.*

        `[pokemon]` is the Pokemon you want to host
        `[gmax]` is a y or n and is whether or not your Pokemon is gmax
        `[shiny]` is a y or n and is whether or not your Pokemon is shiny
        **Usage**: `{prefix}host [gmax] [shiny] [pokemon]`
        **Example**: `{prefix}host y y Pikachu`
        """
        raid = None
        for raid_id, raid in self.bot.raid_data.items():
            if raid.host_id == ctx.message.author.id and raid.guild_id == ctx.guild.id:
                await ctx.send(
                    "You cannot host multiple raids at once. Please close your existing one."
                )
                return
            if raid.pokemon == pokemon_name.lower() and raid.guild_id == ctx.guild.id:
                raid = raid
                break
            else:
                raid = None
        if raid:
            await ctx.send(
                "A raid for this pokemon is already running in this server. Consider joining it!"
            )
            return

        pokemon_name = pokemon_name.lower()

        if shiny == "y" or shiny == "n":
            shiny = True if shiny == "y" else False

        if gmax == "y" or gmax == "n":
            gmax = True if gmax == "y" else False

        if type(gmax) != bool or type(shiny) != bool:
            await ctx.send(
                "Please say 'y' or 'n' for gmax and shiny. Try running the command again."
            )
            return

        if pokemon_name not in self.bot.pokemon_images.keys():
            await ctx.send(
                "This is not a valid Pokemon name, or it has been misspelled. "
                "Try running this command again."
            )
            return

        raid = await Raid.create(
            guild_id=ctx.guild.id,
            pokemon=pokemon_name,
            shiny=shiny,
            gmax=gmax,
            host_id=ctx.message.author.id,
        )

        self.bot.raid_data[raid.id] = raid

        self.bot.queue_data[f"{raid.id}+{ctx.message.author.id}"] = {
            "raid_id": raid.id,
            "user_id": ctx.message.author.id,
            "guild_id": ctx.guild.id,
        }

        user = await get_create_user(ctx.message.author.id)
        await user.update(times_hosted=user.times_hosted + 1).apply()

        await ctx.send(
            "Raid started, you have been automatically added to the queue, and you can check on the current "
            "raid using the queue command."
            " Invite your friends to join!"
        )

        await ctx.send(
            "**TIP:** In order to get XP, get 3 or more people to be in the queue!"
        )

    @commands.command()
    async def close(self, ctx, pokemon_name: str):
        """*Close a raid you started.*

        `[pokemon]` is the Pokemon raid you want to close
        **Usage**: `{prefix}close [pokemon]`
        **Example**: `{prefix}close Pikachu`
        """
        raid = None
        for raid_id, raid in self.bot.raid_data.items():
            if raid.pokemon == pokemon_name.lower() and raid.guild_id == ctx.guild.id:
                raid = raid
                break
            else:
                raid = None

        if not raid:
            await ctx.send(
                "This raid cannot be found. Please type in a valid Pokemon name."
            )
            return

        if (
            raid.host_id != ctx.message.author.id
            and not ctx.message.author.guild_permissions.administrator
        ):
            await ctx.send(
                "You did not host this raid, and are not an admin. Please get someone else to "
                "close it."
            )
            return

        try:
            for queue_id, queue in self.bot.queue_data.items():
                if queue["raid_id"] == raid.id:
                    self.bot.raid_data.pop(queue_id, None)
            await raid.delete()
            self.bot.raid_data.pop(raid.id, None)
        except Exception as e:
            print(e)
            return

        await ctx.send("Raid has been closed, and queue has been purged!")


def setup(bot):
    bot.add_cog(Raids(bot))
