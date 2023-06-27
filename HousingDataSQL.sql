--CLEANING DATA IN SQL

SELECT *
FROM HousingData..HousingData

-- Standardize Date Format
ALTER TABLE HousingData..HousingData
Add SaleDateConverted Date;

Update HousingData..HousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select saleDateConverted, CONVERT(Date,SaleDate)
From HousingData..HousingData

Update HousingData..HousingData
SET SaleDate = CONVERT(Date,SaleDate)

-- Populate Property Address data

Select *
From HousingData..HousingData
--Where PropertyAddress is null
order by ParcelID

-- Property address is same with Parcel ID, so we need data from ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From HousingData..HousingData a
JOIN HousingData..HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From HousingData..HousingData a
JOIN HousingData..HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From HousingData..HousingData
--Where PropertyAddress is null
--order by ParcelID

SELECT 
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM HousingData..HousingData;

ALTER TABLE HousingData..HousingData
ADD City VARCHAR(255);

UPDATE HousingData..HousingData
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

-- merubah nama kolom city menjadi propertysplitcity
EXEC sp_rename 'HousingData..HousingData.City', 'PropertySplitCity', 'COLUMN';

Select
PARSENAME(REPLACE(PropertyAddress, ',', '.') , 2)
From HousingData..HousingData

ALTER TABLE HousingData..HousingData
ADD PropertySplitAddress VARCHAR(255);

UPDATE HousingData..HousingData
SET PropertySplitAddress = PARSENAME(REPLACE(PropertyAddress, ',', '.') , 2)

--OWNER ADDRESS
Select OwnerAddress
From HousingData..HousingData


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From HousingData..HousingData

ALTER TABLE HousingData..HousingData
Add OwnerSplitAddress Nvarchar(255);

Update HousingData..HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE HousingData..HousingData
Add OwnerSplitCity Nvarchar(255);

Update HousingData..HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE HousingData..HousingData
Add OwnerSplitState Nvarchar(255);

Update HousingData..HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From HousingData..HousingData
Group by SoldAsVacant
order by 2




--Select SoldAsVacant
--, CASE When SoldAsVacant = 'Y' THEN 'Yes'
--	   When SoldAsVacant = 'N' THEN 'No'
--	   ELSE SoldAsVacant
--	   END
--From HousingData..HousingData


--Update HousingData..HousingData
--SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
--	   When SoldAsVacant = 'N' THEN 'No'
--	   ELSE SoldAsVacant
--	   END




-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From HousingData..HousingData
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From HousingData..HousingData


ALTER TABLE HousingData..HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
