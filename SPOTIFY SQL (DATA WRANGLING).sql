
--SOURCE: https://www.kaggle.com/datasets/yukawithdata/spotify-top-tracks-2023

select *
from [dbo].[Top 50 Spotify]
-- This dataset compiles the tracks from Spotify's official "Top Tracks of 2023" playlist, showcasing the most popular and influential music of the year according to Spotify's streaming data.
-- This dataset contains 19 columns
-- Sum up: there is no NULL or invalid values; some data type changes needed.

-- 1. Artist_name (nvarchar(255))

-- 1.1. Checking for null and invalid values
select artist_name
from [Top 50 Spotify]
where artist_name is NULL or ISNUMERIC(artist_name)=1 -- Pass: this query returns 0 row.

-- 1.2. Distribution
with cte as (
select distinct artist_name, count(artist_name) as artist_name_frequency
from [Top 50 Spotify] -- 41 artists
group by artist_name
)
select * 
from cte 
where artist_name_frequency > 1 -- 6 artist have more than 1 track in Top 50.

-- 2. track_name (nvarchar(255))
-- 2.1. Checking for null and invalid values
select track_name
from [Top 50 Spotify]
where track_name is NULL or ISNUMERIC(track_name)=1 -- Pass: this query returns 0 row.

-- 3. is_explicit (nvarchar(255)): Indicates whether the track contains explicit content

-- 3.1. Checking for null and invalid values
select is_explicit
from [Top 50 Spotify]
where is_explicit is NULL or ISNUMERIC(is_explicit)=1 -- Pass: this query returns 0 row.

-- 3.2. Distribution
select distinct is_explicit
from [Top 50 Spotify] -- 2 values: False and True.

-- 3.3. Correction: change False to No and True to Yes
update [Top 50 Spotify]
set is_explicit = 'Yes'
where is_explicit = 'True'

update [Top 50 Spotify]
set is_explicit = 'No'
where is_explicit = 'False'

-- 4. album_release_date: The date when the track was released

-- 4.1. Checking for format: this column is nvarchar(255). Must change it to date type. 
ALTER TABLE [Top 50 Spotify]
ALTER COLUMN album_release_date date;

-- 4.2. Checking for NULL
select album_release_date
from [Top 50 Spotify]
where album_release_date is NULL -- Pass: this query returns 0 row.

-- 5. genres (nvarchar(255)): A list of genres associated with the track's artist(s)

-- 5.1. Checking for NULL:
select genres
from [Top 50 Spotify]
where genres is NULL -- Pass: this query returns 0 row.

-- 6. danceability (float): A measure from 0.0 to 1.0 indicating how suitable a track is for dancing based on a combination of musical elements

-- 6.1. Checking for NULL and invalid values
select danceability
from [Top 50 Spotify]
where danceability is NULL or danceability < 0 -- Pass: this query returns 0 row.

-- 7. valence (floar): A measure from 0.0 to 1.0 indicating the musical positiveness conveyed by a track

-- 7.1. Checking for NULL and invalid values
select valence
from [Top 50 Spotify]
where valence is NULL or valence < 0 -- Pass: this query returns 0 row.

-- 8. energy (float): A measure from 0.0 to 1.0 representing a perceptual measure of intensity and activity

-- 8.1. Checking for NULL and invalid values
select energy
from [Top 50 Spotify]
where energy is NULL or energy < 0 -- Pass: this query returns 0 row.

-- 9. loudness (float): The overall loudness of a track in decibels (dB)

-- 9.1. Checking for NULL and invalid values
select loudness
from [Top 50 Spotify]
where loudness is NULL -- Pass: this query returns 0 row.

-- 10. acousticness (float): A measure from 0.0 to 1.0 whether the track is acoustic.

-- 10.1. Checking for NULL and invalid values
select acousticness
from [Top 50 Spotify]
where acousticness is NULL or acousticness < 0 -- Pass: this query returns 0 row.

-- 11. instrumentalness (float): Predicts whether a track contains no vocals
select instrumentalness
from [Top 50 Spotify]

-- 12.  liveness (float): Detects the presence of an audience in the recordings

-- 12.1. Checking for NULL
select liveness
from [Top 50 Spotify]
where liveness is NULL -- Pass: this query returns 0 row.

-- 13. speechiness (float): Detects the presence of spoken words in a track

-- 13.1. Checking for NULL
select speechiness
from [Top 50 Spotify]
where speechiness is NULL -- Pass: this query returns 0 row.

-- 14. [key]: The key the track is in. Integers map to pitches using standard Pitch Class notation.

-- 14.1. Alter type to int
alter table [Top 50 Spotify]
alter column [key] int;

-- 14.2. Checking for NULL
select [key]
from [Top 50 Spotify]
where [key] is NULL -- Pass: this query returns 0 row.

-- 15. tempo (float): The overall estimated tempo of a track in beats per minute (BPM)

-- 15.1. Checking NULL and invalid values
select tempo
from [Top 50 Spotify]
where tempo is NULL or tempo < 0 -- Pass: this query returns 0 row.

-- 16. mode: Modality of the track

-- 16.1. Checking NULL and invalid values
select mode
from [Top 50 Spotify]
where mode is NULL or mode < 0 -- Pass: this query returns 0 row.

-- 17. duration_ms: The length of the track in milliseconds

-- 17.1. Checking NULL and invalid values
select duration_ms
from [Top 50 Spotify]
where duration_ms is NULL or duration_ms < 0 -- Pass: this query returns 0 row.

-- 18. time_signature: An estimated overall time signature of a track

-- 18.1. Checking NULL and invalid values
select time_signature
from [Top 50 Spotify]
where time_signature is NULL or time_signature < 0 -- Pass: this query returns 0 row.

-- 19. popularity: A score between 0 and 100, with 100 being the most popular

-- 19.1. Checking NULL and invalid values
select popularity
from [Top 50 Spotify]
where popularity is NULL or popularity < 0 -- Pass: this query returns 0 row.