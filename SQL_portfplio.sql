
--Creating the table by combining all the individual files (monthly data) into a new table in the data base  Cyclist_full_year_2020

DROP TABLE IF EXISTS Cyclist_data.Cyclist_full_year_2020;
CREATE TABLE Cyclist_data.Cyclist_full_year_2020 AS 
(   SELECT *
    FROM `theta-arcana-328503.Cyclist_data.Cyclist_04_2020`
    UNION ALL 
    SELECT *
    FROM Cyclist_data.Cyclist_Q1_2020
    UNION ALL
    SELECT *
    FROM Cyclist_data.Cyclist_05_2020
    UNION ALL
    SELECT *
    FROM Cyclist_data.Cyclist_06_2020
    UNION ALL
    SELECT *
    FROM Cyclist_data.Cyclist_07_2020
    UNION ALL
    SELECT *
    FROM Cyclist_data.Cyclist_08_2020
    UNION ALL
    SELECT *
    FROM Cyclist_data.Cyclist_09_2020
    UNION ALL
    SELECT *
    FROM Cyclist_data.Cyclist_10_2020
    UNION ALL
    SELECT *
    FROM Cyclist_data.Cyclist_11_2020
    UNION ALL 
    SELECT ride_id,rideable_type,started_at, ended_at, start_station_name, CAST (start_station_id AS INT64) AS start_station_id, end_station_name, CAST (end_station_id AS INT64 ) AS end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
    FROM Cyclist_data.Cyclist_11_2020
 
)  


--Using CTE to perform the following funtions 
--Removing all the null values from the TABLE and removing unclean ride_id values

WITH non_null_table AS
( 
    SELECT *
    FROM `theta-arcana-328503.Cyclist_data.Cyclist_full_year_2020`
    WHERE NOT
        ride_id IS NULL OR ride_id = "" OR
        rideable_type IS NULL OR rideable_type = "" OR 
        started_at IS NULL OR 
        ended_at IS NULL OR
        start_station_name IS NULL OR start_station_name = "" OR
        start_station_id IS NULL OR 
        end_station_name IS NULL OR end_station_name = "" OR
        end_station_id IS NULL OR
        member_casual IS NULL OR member_casual = "" 
),
clean_ride_id_table AS
(
        SELECT *
        FROM non_null_table 
        WHERE LENGTH(ride_id) = 16 
),


--•	After looking data, few columns were added which would be utilised for analysis and visualization. Also I cleaned 
--the ride_duration_minutes column (like negative time duration) so removed those . Functions used were
-- FORMAT_DATE, CAST, TIMESTAMP_DIFF, EXTRACT
ride_month AS
(
    SELECT *,
        FORMAT_DATE('%b', (CAST (started_at AS DATE))) AS ride_month
    FROM clean_ride_id_table 
),

ride_details_table AS
(
        SELECT *,
            TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_duration_minutes,
            FORMAT_DATE('%A', (CAST (started_at AS DATE))) AS day_of_ride,
            EXTRACT(HOUR FROM started_at) as starting_hour
        FROM ride_month 
        WHERE TIMESTAMP_DIFF(ended_at, started_at, MINUTE) > 0 
),

--•	Lastly, a final table was created. Few modifications are also made in the final table:
--o	Removed the whitespaces using TRIM()
--o	Didn’t include the LAT,LONG columns as I did not used them for the analysis purpose
--o	Also, some names were modified for better understanding

final_table AS
(   
        SELECT 
            trim(ride_id) as ride_id,
            trim(rideable_type) as type_of_ride,
            trim(member_casual) as member_type,
            trim(start_station_name) as start_station,
            trim(end_station_name) as end_station,
            ride_duration_minutes,
            day_of_ride,
            ride_month,
            starting_hour
        FROM ride_details_table 

)
SELECT *
FROM final_table 


