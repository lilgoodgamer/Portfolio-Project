/*

Cleaning Data in SQL Queries

*/

------
--data start 
select *
from portfolio_project..AmesHousing;
------



--fix date so its one and its in date fo
------
--alter table portfolio_project..AmesHousing
--add SaleDate DATE;

--update portfolio_project..AmesHousing
--set SaleDate = DATEFROMPARTS(Yr_Sold, Mo_Sold, 1);

--alter table portfolio_project..AmesHousing
--drop column Mo_Sold, Yr_Sold;

--select * from AmesHousing
--------

--check for missing adresses 
select *
from AmesHousing
where PropertyAddress is null
order by UniqueID;

-- if they are null fill them with the parcel id 

update a 
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from AmesHousing a join AmesHousing b 
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;
--------

--remove duplcte rows 

with rowNumCTE as (
	select *, 
		ROW_NUMBER() over (
			partition by parcelID, PropertyAddress, SalePrice, SaleDate
			order by UniqueID
		) as row_num
	from AmesHousing
)
delete 
from rowNumCTE
where row_num >1;
-----------
--fix data types 

alter table AmesHousing 
alter column SalePrice money;

alter table AmesHousing
alter column Lot_Area int;

alter table AmesHousing
alter column Bedrooms int;

alter table AmesHousing 
alter column FullBath int;

alter table AmesHousing 
alter column HalfBath int;
-------
--adding property age at sale colum

alter table AmesHousing 
add propertyAgeAtSale as (year(SaleDate) - YearBuilt);

------
--final data check 

select * 
from AmesHousing