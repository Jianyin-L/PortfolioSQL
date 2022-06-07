/*
Data Cleaning & Manupulation using SQL
*/

SELECT *
FROM Nashville_housing..NashHouse;

-- Convert SaleDate datatype 
ALTER TABLE Nashville_housing..NashHouse
ALTER COLUMN SaleDate Date NOT NULL;


-- Populate property address data
SELECT *
FROM Nashville_housing..NashHouse
ORDER BY ParcelID;
--> Same parcel ID will have same property address

UPDATE HousingA
SET HousingA.PropertyAddress = ISNULL(HousingA.PropertyAddress, HousingB.PropertyAddress)
FROM Nashville_housing..NashHouse HousingA
	Join Nashville_housing..NashHouse HousingB
		ON HousingA.ParcelID = HousingB.ParcelID
		AND HousingA.UniqueID <> HousingB.UniqueID
WHERE HousingA.PropertyAddress is NULL;


-- Split Property Address to address and city
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
FROM Nashville_housing..NashHouse;


ALTER TABLE Nashville_housing..NashHouse
ADD PropertySplitAddress Nvarchar(255);

UPDATE Nashville_housing..NashHouse
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);


ALTER TABLE Nashville_housing..NashHouse
Add PropertySplitCity Nvarchar(255);

UPDATE Nashville_housing..NashHouse
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));


--ALTER TABLE Nashville_housing..NashHouse
--  DROP COLUMN OwerSplitCity;

SELECT PropertyAddress, PropertySplitaddress, PropertySplitCity
FROM Nashville_housing..NashHouse;



-- Split OwnerAddress
ALTER TABLE Nashville_housing..NashHouse
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Nashville_housing..NashHouse
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


ALTER TABLE Nashville_housing..NashHouse
Add OwnerSplitCity Nvarchar(255);

UPDATE Nashville_housing..NashHouse
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


ALTER TABLE Nashville_housing..NashHouse
Add OwnerSplitState Nvarchar(255);

UPDATE Nashville_housing..NashHouse
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM Nashville_housing..NashHouse;

SELECT *
FROM Nashville_housing..NashHouse;


-- SoldAsVacant
SELECT distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville_housing..NashHouse
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant);
--> Contain Y, Yes, N, No

UPDATE Nashville_housing..NashHouse
SET SoldAsVacant = case SoldAsVacant 
	WHEN 'Y' then 'Yes'
	WHEN 'N' then 'No'
	ELSE SoldAsVacant
	END

SELECT distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville_housing..NashHouse
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant);


---- Remove duplicate
--SELECT *, 
--	ROW_NUMBER() OVER (
--		Partition by ParcelID, 
--					 PropertyAddress, 
--					 LegalReference
--		Order by UniqueID
--		) counts
--FROM Nashville_housing..NashHouse
--ORDER BY ParcelID



--WITH DuplicateRow as(
--	SELECT *, 
--		ROW_NUMBER() OVER (
--			Partition by ParcelID, PropertyAddress, LegalReference
--			Order by UniqueID
--			) counts
--	FROM Nashville_housing..NashHouse
--)
--DELETE
--FROM DuplicateRow
--WHERE counts > 1
--;

--WITH DuplicateRow as(
--	SELECT *, 
--		ROW_NUMBER() OVER (
--			Partition by ParcelID, PropertyAddress, LegalReference
--			Order by UniqueID
--			) counts
--	FROM Nashville_housing..NashHouse
--)
--SELECT *
--FROM DuplicateRow
--WHERE counts > 1
--;







