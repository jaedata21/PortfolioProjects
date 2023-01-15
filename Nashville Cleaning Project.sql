-- Data Cleaning--

Select * 
From pproject.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDate, Convert(date,SaleDate)
From pproject.dbo.NashvilleHousing

UPDATE NashvilleHousing
Set SaleDate = Convert (date,SaleDate)

-----------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From pproject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
Order by ParcelID

Select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From pproject.dbo.NashvilleHousing a
JOIN pproject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is NULL

Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From pproject.dbo.NashvilleHousing a
JOIN pproject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is NULL


--------------------------------------------------------------------------------------------------------------------------------


--Breaking out Address into Individual Columns (Address,City,State)

Select PropertyAddress
From pproject.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress)) as City
From pproject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress))



SELECT
PARSENAME(Replace (OwnerAddress, ',','.') ,3)
,PARSENAME(Replace (OwnerAddress, ',','.') ,2)
,PARSENAME(Replace (OwnerAddress, ',','.') ,1)
From pproject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace (OwnerAddress, ',','.') ,3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace (OwnerAddress, ',','.') ,2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace (OwnerAddress, ',','.') ,1)



----------------------------------------------------------------------------------------------------------------------------------------


--Change Y and N to Yes and No in "Sold Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From pproject.dbo.NashvilleHousing
Group by SoldAsVacant

Select SoldAsVacant
,   CASE When SoldAsVacant = 'Y' Then 'Yes'
         When SoldAsVacant = 'N' Then 'No'
         Else SoldAsVacant
    End
From pproject.dbo.NashvilleHousing



Update
-----------------------------------------------------------------------------------------------------------------------------------------


--Remove Duplicates

With RowNumCTE As (
Select *,
    ROW_NUMBER() Over(
    PARTITION By ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY
                   UNIQUEID
                   ) row_num

From pproject.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num >1


-------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Select *
From pproject.dbo.NashvilleHousing

Alter Table pproject.dbo.NashvilleHousing
Drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
