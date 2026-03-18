import Foundation

func WorkoutIconName(for type: String) -> String {
    let t = type.lowercased()
    if t.contains("archery")                { return "target" }
    if t.contains("badminton")              { return "figure.badminton" }
    if t.contains("barre")                  { return "figure.barre" }
    if t.contains("baseball")              { return "figure.baseball" }
    if t.contains("basketball")             { return "figure.basketball" }
    if t.contains("bowling")                { return "figure.bowling" }
    if t.contains("boxing")                 { return "figure.boxing" }
    if t.contains("climb")                  { return "figure.climbing" }
    if t.contains("cooldown")               { return "figure.cooldown" }
    if t.contains("core")                   { return "figure.core.training" }
    if t.contains("cricket")                { return "figure.cricket" }
    if t.contains("cross train")            { return "figure.cross.training" }
    if t.contains("curl")                   { return "figure.curling" }
    if t.contains("cycl")                   { return "figure.outdoor.cycle" }
    if t.contains("danc") || t.contains("social dance") { return "figure.dance" }
    if t.contains("disc")                   { return "figure.disc.sports" }
    if t.contains("elliptical")             { return "figure.elliptical" }
    if t.contains("equestrian")             { return "figure.equestrian.sports" }
    if t.contains("fencing")                { return "figure.fencing" }
    if t.contains("fishing")                { return "figure.fishing" }
    if t.contains("gaming")                 { return "gamecontroller" }
    if t.contains("flexib")                 { return "figure.flexibility" }
    if t.contains("american football")      { return "figure.american.football" }
    if t.contains("australian football")    { return "figure.australian.football" }
    if t.contains("functional strength")    { return "figure.strengthtraining.functional" }
    if t.contains("golf")                   { return "figure.golf" }
    if t.contains("gymnastics")             { return "figure.gymnastics" }
    if t.contains("hand cycl")              { return "figure.hand.cycling" }
    if t.contains("handball")               { return "figure.handball" }
    if t.contains("hiit") || t.contains("interval") { return "figure.highintensity.intervaltraining" }
    if t.contains("hik")                    { return "figure.hiking" }
    if t.contains("hockey")                 { return "figure.hockey" }
    if t.contains("hunting")                { return "figure.hunting" }
    if t.contains("jump rope")              { return "figure.jumprope" }
    if t.contains("kickbox")                { return "figure.kickboxing" }
    if t.contains("lacrosse")               { return "figure.lacrosse" }
    if t.contains("martial")                { return "figure.martial.arts" }
    if t.contains("mind") || t.contains("tai chi") { return "figure.mind.and.body" }
    if t.contains("mixed cardio")           { return "figure.mixed.cardio" }
    if t.contains("paddl")                  { return "figure.sailing" }
    if t.contains("pickleball")             { return "figure.pickleball" }
    if t.contains("pilates")                { return "figure.pilates" }
    if t.contains("play")                   { return "figure.play" }
    if t.contains("racquetball")            { return "figure.racquetball" }
    if t.contains("row")                    { return "figure.rowing" }
    if t.contains("rugby")                  { return "figure.rugby" }
    if t.contains("run")                    { return "figure.run" }
    if t.contains("sailing")                { return "figure.sailing" }
    if t.contains("skat")                   { return "figure.skating" }
    if t.contains("snow sport")             { return "figure.snowboarding" }
    if t.contains("snowboard")              { return "figure.snowboarding" }
    if t.contains("soccer")                 { return "figure.soccer" }
    if t.contains("softball")               { return "figure.softball" }
    if t.contains("squash")                 { return "figure.squash" }
    if t.contains("stair stepper")          { return "figure.stair.stepper" }
    if t.contains("stairs")                 { return "figure.stairs" }
    if t.contains("step train")             { return "figure.step.training" }
    if t.contains("surf")                   { return "figure.surfing" }
    if t.contains("swim")                   { return "figure.pool.swim" }
    if t.contains("table tennis")           { return "figure.table.tennis" }
    if t.contains("tennis")                 { return "figure.tennis" }
    if t.contains("track")                  { return "figure.track.and.field" }
    if t.contains("strength")               { return "figure.strengthtraining.traditional" }
    if t.contains("volleyball")             { return "figure.volleyball" }
    if t.contains("walk")                   { return "figure.walk" }
    if t.contains("water fitness")          { return "figure.water.fitness" }
    if t.contains("water polo")             { return "figure.waterpolo" }
    if t.contains("water sport")            { return "figure.open.water.swim" }
    if t.contains("wheelchair")             { return "figure.roll" }
    if t.contains("wrestling")              { return "figure.wrestling" }
    if t.contains("yoga")                   { return "figure.yoga" }
    return "figure.mixed.cardio"
}
