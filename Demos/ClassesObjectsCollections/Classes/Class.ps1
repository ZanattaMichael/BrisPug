

class Car {

    [int]$WheelQuantity
    [int]$SeatQuantity
    [int]$DoorQuantity
    [int]$EngineSize
    [string]$PaintColour
    [int]$WindowsQuantity
    [double]$ExhaustSize
    [string]$Brand

    # Default Constructor
    Car() {
    }

    # Overload
    Car([string]$brand, [int]$wheelQuantity, [int]$seatQuantity, [string]$paintColour, [int]$engineSize) {
        $this.Brand = $brand
        $this.WheelQuantity = $wheelQuantity
        $this.SeatQuantity = $seatQuantity
        $this.PaintColour = $paintColour
        $this.EngineSize = $engineSize
    }

    # Method
    ChangeBrand([String]$newBrand) {
        $this.Brand = $newBrand
    }

    # Steal
    Steal([string]$newPaintColour,[int]$newEngineSize,[double]$newExhaustSize) {
        
        $this.PaintColour = $newPaintColour
        $this.EngineSize = $newEngineSize
        $this.ExhaustSize = $newExhaustSize

    }

}

$cars = @()
$cars += [Car]::new("Ford",4,5,"Red", 5)
$cars += [Car]::new("Holden",4,5,"Red", 5)
$cars += [Car]::new("Toyota",4,5,"Red", 5)

For ($i = 0; $i -ne ($cars.Length - 1), $i++) {

    $cars[$i]

}


<#

    So a car needs to have:

    1. number of Wheels
    2. number of Seats
    3. number of Doors
    4. Size of the Engine
    5. Paint Colour
    6. number of Windows
    7. size of Exhaust (cms)
    8. Brand 



#>
