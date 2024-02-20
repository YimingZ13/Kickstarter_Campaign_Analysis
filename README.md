# Kickstarter Campaign Analysis

## Table of Contents
1. [Introduction](#Introduction)
2. [File Structure](#FileStructure)
3. [Feature Documentations](#FeatureDocumentations)
5. [Key Results](#KeyResults)
6. [Special Note](#SpecialNote)
7. [Authors](#Authors)
8. [License](#License)

<a name="Introduction"></a>
## Introduction
# Kickstarter Campaign Analysis in SQL
Welcome to my Kickstarter Campaign Analysis repository. This project delves into the vibrant world of crowdfunding, where creativity meets financial backing, using the robust querying capabilities of SQL. Kickstarter, a leader in the crowdfunding domain, has seen an expansive array of projects, varying in success and scope across numerous categories and regions. Our objective is to dissect this wealth of data to uncover insights that could guide creators and backers towards more informed decisions.

Through the use of SQL, I systematically analyze campaign trends, success rates, and category performances to glean patterns and narratives that lie within the numbers. The queries range from basic data retrieval to complex joins, aggregations, and window functions, aiming to unravel the factors that contribute to a campaign's success or failure.

This analysis is not only a reflection of the current state of crowdfunding but also serves as a strategic tool for prospective project creators and investors. By understanding past and present trends, stakeholders can forecast future patterns and position their campaigns for optimal visibility and funding success.

We encourage you to explore the SQL scripts, contribute to the analysis, and share your unique findings as we collectively enhance our understanding of the Kickstarter ecosystem. Let's dive into the data and discover what stories lie beneath the surface of successful crowdfunding campaigns.

The [original datasets]((https://www.kickstarter.com/help/stats)), sourced from the BIXI Montreal [Open Data website](https://bixi.com/en/open-data), encapsulates bike usage and station data throughout the year 2021.

<a name="FileStructure"></a>
## File Structure
Each of the following project steps is completed in a separate notebook:
- [Raw Trips Data](https://github.com/YimingZ13/BIXI_Montreal_Data_Analysis/blob/main/2021_donnees_ouvertes.csv): `2021_donnees_ouvertes.csv`
- [Raw Stations Data](https://github.com/YimingZ13/BIXI_Montreal_Data_Analysis/blob/main/2021_stations.csv): `2021_stations.csv`
- [Data Cleaning](https://github.com/YimingZ13/BIXI_Montreal_Data_Analysis/blob/main/BIXI_cleaning.ipynb): `BIXI_cleaning.ipynb`
- [EDA/Business Recommendations](https://github.com/YimingZ13/BIXI_Montreal_Data_Analysis/blob/main/BIXI_EDA.ipynb): `BIXI_EDA.ipynb`

<a name="Installing"></a>
## Installing
There are no special packages needed for this project, most of packages come with the Anaconda distribution of Python 3.

<a name="FeatureDocumentations"></a>
## Feature Documentations
`2021_donnees_ouvertes.csv`:
- `start_date`: Date and time of the start of the trip (yyyy-MM-dd HH:mm:ss.SSSSSS)
- `emplacement_pk_start`: Code of the station where the trip starts
- `end_date`: Date and time of the end of the trip (yyyy-MM-dd HH:mm:ss.SSSSSS)
- `emplacement_pk_end`:  Code of the station where the trip ends
- `duration_sec`: Duration of the trip in seconds
- `is_member`: Memebership status of the trip (1: member, 0: non-member)
  
`2021_stations.csv`:
- `pk`: Station code
- `name`: Name of the station
- `latitude`: Geographic coordinates for the latitude of the station
- `longitude`: Longitude coordinates for the longitude of the station

<a name="KeyResults"></a>
## Key Insights
- Stations for bike pick-up and drop-off, indicated by 'emplacement_pk_start' and 'emplacement_pk_end', share a similar distribution, suggesting that station popularity isn't tied to a specific function. Factors like geography likely play a more significant role.
- The majority of trips are under 1 hour in duration.
- Member usage outnumbers non-member usage by approximately 5 times.
- Biking sees increased activity during warmer months, with peak usage in August and September.
- Bike usage is consistent on weekdays, with a slight uptick on weekends and a decline on Sundays.
- Short trips under 1 hour are mainly used by members, while casual riders show a gradual increase for trips lasting 55 to 160 minutes. Longer trips beyond 160 minutes see members regaining dominance.
- The map reveals shorter trips clustering around the city center, while longer trips disperse towards the outskirts, often originating from stations near parks or recreational areas, indicating leisure activities.
- Member trips peak on Tuesday, gradually declining until Saturday, with a slight uptick on Sunday. Non-member trips show a gradual rise, peaking on Saturday, indicating weekend leisure usage.
- Non-members have longer average bike durations, with casual riders extending trips. Members maintain a relatively stable average duration but show a spike on Saturdays.
- Longer average durations suggest bike trips for leisure purposes.
- Members and non-members exhibit similar usage patterns throughout the week, with peak periods at 8 a.m. and 5 p.m. on weekdays. Fridays show increased nighttime usage, likely due to leisure activities, and weekends have concentrated afternoon trips with a notable surge at midnight.

<a name="SpecialNote"></a>
## Special Note
Since the scatter mapbox graph under the Geographical Pattern section in the EDA notebook cannot be embedded in the notebook, below is the screenshot of the scatter mapbox. Feel free to revisit this plot when navigating through the `BIXI_EDA.ipynb` notebook.
![Screenshot 2024-01-23 at 3 36 58 PM](https://github.com/YimingZ13/BIXI_Montreal_Data_Analysis/assets/128729320/284e7cec-967c-426e-811f-02d1f6c3056c)

<a name="Authors"></a>
## Authors
Yiming Zhao | [LinkedIn](https://www.linkedin.com/in/yiming-zhao13/)

<a name="License"></a>
## License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

The project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
