/*

Cleaning Data in SQL Queries

*/

Use PortfolioProject;


Select *
From PortfolioProject..nash_ville;

-----------------------------------------------------------------------------------------------------------------------------
-- Standadize Data Formart


Select SaleDate, Convert(Date, SaleDate)
From PortfolioProject..nash_ville;


Update nash_ville
Set SaleDate =  Convert(Date, SaleDate);

Alter Table nash_ville
Add SaleDateConverted Date;

Update nash_ville
Set SaleDateConverted =  Convert(Date, SaleDate)



-----------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

 Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 From PortfolioProject..nash_ville a
	Join PortfolioProject..nash_ville b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..nash_ville a
	Join PortfolioProject..nash_ville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-----------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as StreetAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as CityAddress
From  PortfolioProject..nash_ville;

ALTER TABLE nash_ville
ADD PropertyStreetAddress Nvarchar(255);

UPDATE nash_ville
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1);


ALTER TABLE nash_ville
ADD PropertyCityAddress Nvarchar(255);

UPDATE nash_ville
SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));



Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From nash_ville;

ALTER TABLE nash_ville
ADD OwnerStreetAddress Nvarchar(255);

UPDATE nash_ville
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


ALTER TABLE nash_ville
ADD OwnerCityAddress Nvarchar(255);

UPDATE nash_ville
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


ALTER TABLE nash_ville
ADD OwnerStateAddress Nvarchar(255);

UPDATE nash_ville
SET OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


-----------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From nash_ville
Group By SoldAsVacant
Order By 2


UPDATE nash_ville
SET SoldAsVacant =
	CASE When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 ELSE SoldAsVacant
		 END
From nash_ville



-----------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates Rows


With RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
				PARTITION BY ParcelID,
							PropertyAddress,
							OwnerCityAdrress,
							OwnerAddress,
							SalePrice,
							SaleDate,
							LegalReference
							Order By
								UniqueID
								) row_num
From nash_ville
)

DELETE
From RowNumCTE
Where row_num >1




-----------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates Columns



ALTER TABLE nash_ville
DROP COLUMN PropertyAddress;

ALTER TABLE nash_ville
DROP COLUMN OwnerCityAdrress;

ALTER TABLE nash_ville
DROP COLUMN OwnerAddress;

ALTER TABLE nash_ville
DROP COLUMN SaleDate;



-----------------------------------------------------------------------------------------------------------------------------
-- Change column name


EXEC sp_rename 'nash_ville.SaleDateConverted', 'SaleDate', 'COLUMN';




