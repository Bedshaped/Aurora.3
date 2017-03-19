#define SECOND *10
#define SECONDS *10

#define MINUTE *600
#define MINUTES *600

var/roundstart_hour = 0
//Returns the world time in english
proc/worldtime2text(time = world.time, timeshift = 1)
	if(!roundstart_hour) roundstart_hour = rand(0, 23)
	return timeshift ? time2text(time+(36000*roundstart_hour), "hh:mm") : time2text(time, "hh:mm")

/proc/worldtime2hours()
	if (!roundstart_hour)
		worldtime2text()
	. = (world.timeofday / (60 MINUTES)) + roundstart_hour
	if (. > 24)
		. -= 24

proc/worlddate2text()
	return num2text(game_year) + "-" + time2text(world.timeofday, "MM-DD")

proc/time_stamp()
	return time2text(world.timeofday, "hh:mm:ss")

/* Returns 1 if it is the selected month and day */
proc/isDay(var/month, var/day)
	if(isnum(month) && isnum(day))
		var/MM = text2num(time2text(world.timeofday, "MM")) // get the current month
		var/DD = text2num(time2text(world.timeofday, "DD")) // get the current day
		if(month == MM && day == DD)
			return 1

		// Uncomment this out when debugging!
		//else
			//return 1

var/next_duration_update = 0
var/last_round_duration = 0
proc/round_duration()
	if(last_round_duration && world.time < next_duration_update)
		return last_round_duration

	var/mills = world.time // 1/10 of a second, not real milliseconds but whatever
	//var/secs = ((mills % 36000) % 600) / 10 //Not really needed, but I'll leave it here for refrence.. or something
	var/mins = round((mills % 36000) / 600)
	var/hours = round(mills / 36000)

	mins = mins < 10 ? add_zero(mins, 1) : mins
	hours = hours < 10 ? add_zero(hours, 1) : hours

	last_round_duration = "[hours]:[mins]"
	next_duration_update = world.time + 1 MINUTES
	return last_round_duration