SET search_path TO "Housing Data", public;

CREATE TABLE "Housing Data".nashvillehousing (
    uniqueid INTEGER,
    parcelid TEXT,
    landuse TEXT,
    propertyaddress TEXT,
    saledate DATE,
    saleprice TEXT,
    legalreference TEXT,
    soldasvacant TEXT,
    ownername TEXT,
    owneraddress TEXT,
    acreage NUMERIC,
    taxdistrict TEXT,
    landvalue NUMERIC,
    building_value NUMERIC,
    totalvalue NUMERIC,
    yearbuilt INTEGER,
    bedrooms INTEGER,
    fullbath INTEGER,
    halfbath INTEGER
);


SELECT *
FROM nashvillehousing;

-- Standardize Date format

SELECT saleDate,
       saleDate::DATE AS saleDateConverted
FROM "Housing Data".nashvillehousing;

-- Creating New Column
ALTER TABLE "Housing Data".nashvillehousing
ADD COLUMN saleDateConverted DATE;

-- Inserting information to new column
UPDATE "Housing Data".nashvillehousing
SET saleDateConverted = saleDate::DATE;




-- Populating null Property addresses for matching parecelIDs 

SELECT A.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, COALESCE(a.propertyaddress, b.propertyaddress)
FROM "Housing Data".nashvillehousing a
JOIN "Housing Data".nashvillehousing b
on a.parcelid = b.parcelid
AND a.UNIQUEID <> b.UNIQUEID
WHERE a.propertyaddress is null;


-- nulls populated
UPDATE nashvillehousing AS a
SET propertyaddress = b.propertyaddress  
WHERE a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
AND a.propertyaddress IS NULL;


-- SEPARATING ADDRESS INTO SPECIFIC COLUMNS

SELECT propertyaddress
FROM "Housing Data".nashvillehousing;


SELECT
SUBSTRING(propertyaddress, 1, STRPOS( propertyaddress, ',') -1) as address,
SUBSTRING(propertyaddress, STRPOS( propertyaddress, ',') + 1, LENGTH(propertyaddress)) as address2
From "Housing Data".nashvillehousing;


-- creating and populating split address
ALTER TABLE nashvillehousing
Add PropertySplitAddress text;

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, STRPOS( propertyaddress, ',') -1)

-- creating and populating city column
ALTER TABLE nashvillehousing
Add PropertySplitCity text;

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyaddress, STRPOS( propertyaddress, ',') + 1, LENGTH(propertyaddress))


SELECT *
FROM "Housing Data".nashvillehousing;

-- Splitting owner address into address, city and state
SELECT SPLIT_PART(owneraddress, ',', 1),
SPLIT_PART(owneraddress, ',', 2),
SPLIT_PART(owneraddress, ',', 3)
FROM "Housing Data".nashvillehousing;


ALTER TABLE nashvillehousing
Add ownersplitaddress text;

Update NashvilleHousing
SET ownersplitaddress = SPLIT_PART(owneraddress, ',', 1);


ALTER TABLE nashvillehousing
Add ownersplitcity text;

Update NashvilleHousing
SET ownersplitcity = SPLIT_PART(owneraddress, ',', 2);


ALTER TABLE nashvillehousing
Add ownersplitstate text;

Update NashvilleHousing
SET ownersplitstate = SPLIT_PART(owneraddress, ',', 3);


SELECT *
FROM "Housing Data".nashvillehousing;


-- STANDARDIZING SOLD AS VACANT TO YES AND NO ONLY
SELECT soldasvacant,
CASE 
WHEN soldasvacant = 'Y' THEN 'Yes'
WHEN soldasvacant = 'N' THEN 'No'
ELSE soldasvacant
END
FROM "Housing Data".nashvillehousing;


UPDATE nashvillehousing
SET soldasvacant =
CASE 
WHEN soldasvacant = 'Y' THEN 'Yes'
WHEN soldasvacant = 'N' THEN 'No'
ELSE soldasvacant
END;


-- Removing duplicates

WITH rownumcte AS(
Select *,
ROW_NUMBER() OVER (
PARTITION BY parcelid,
propertyaddress,
saleprice,
saledate,
legalreference
ORDER BY
uniqueid
) AS rownum
From "Housing Data".nashvillehousing
)
DELETE FROM "Housing Data".nashvillehousing
WHERE uniqueid IN
(
SELECT uniqueid
FROM rownumcte
WHERE rownum > 1
);



























