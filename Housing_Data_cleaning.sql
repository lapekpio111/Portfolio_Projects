Select *
From portfolio_project..NashvilleHousing

--date conversion

Select SaleDate, convert(Date,SaleDate)
From portfolio_project..NashvilleHousing

Update NashvilleHousing
Set SaleDate = convert(Date,SaleDate)


Alter table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
Set SaleDateConverted = convert(Date,SaleDate)

Select SaleDateConverted
From portfolio_project..NashvilleHousing


--Populate Property address data

Select *
From portfolio_project..NashvilleHousing
where PropertyAddress is NULL

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolio_project..NashvilleHousing a
join portfolio_project..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolio_project..NashvilleHousing a
join portfolio_project..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out address into individual columns


Select PropertyAddress
From portfolio_project..NashvilleHousing


Select substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From portfolio_project..NashvilleHousing

Alter table NashvilleHousing
Add Property_split_address Nvarchar(255)

Update NashvilleHousing
Set Property_split_address = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter table NashvilleHousing
Add property_split_city Nvarchar(255)

Update NashvilleHousing
Set property_split_city = substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select*
From portfolio_project..NashvilleHousing



Select OwnerAddress
From portfolio_project..NashvilleHousing

Select 
Parsename(REPLACE(OwnerAddress, ',', '.'), 3),
Parsename(REPLACE(OwnerAddress, ',', '.'), 2),
Parsename(REPLACE(OwnerAddress, ',', '.'), 1)
From portfolio_project..NashvilleHousing



Alter table NashvilleHousing
Add owner_split_address Nvarchar(255)

Update NashvilleHousing
Set owner_split_address = Parsename(REPLACE(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
Add owner_split_city Nvarchar(255)

Update NashvilleHousing
Set owner_split_city = Parsename(REPLACE(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add owner_split_state Nvarchar(255)

Update NashvilleHousing
Set owner_split_state = Parsename(REPLACE(OwnerAddress, ',', '.'), 1)


Select *
from NashvilleHousing


--Change 'Y' and 'N' to 'Yes' and 'No' in 'SoldAsVacant'

Select distinct(SoldAsVacant), count(SoldAsVacant)
From portfolio_project..NashvilleHousing
group by SoldAsVacant
order by 2



Select SoldAsVacant,
CASE
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End
From portfolio_project..NashvilleHousing



Update NashvilleHousing
Set SoldAsVacant =
CASE
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End
From portfolio_project..NashvilleHousing


--Removing duplicates


With RowNumCTE as (
Select *,
ROW_NUMBER() OVER (
	Partition by Parcelid, 
				 Propertyaddress, 
				 SalePrice, SaleDate, 
				 LegalReference
				 Order by
					Uniqueid
					) row_num
From portfolio_project..NashvilleHousing
)
Delete
from RowNumCTE
Where row_num > 1




With RowNumCTE as (
Select *,
ROW_NUMBER() OVER (
	Partition by Parcelid, 
				 Propertyaddress, 
				 SalePrice, SaleDate, 
				 LegalReference
				 Order by
					Uniqueid
					) row_num
From portfolio_project..NashvilleHousing
)
Select *
from RowNumCTE
Where row_num > 1
order by PropertyAddress



--Delete unused columns


Select *
From portfolio_project..NashvilleHousing

Alter table NashvilleHousing
Drop column Owneraddress, propertyaddress, saledate
