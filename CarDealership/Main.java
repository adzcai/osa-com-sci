import java.util.ArrayList;

class Car {
  private String make;
  private String model;
  private int year;
  private int odometer;
  private String colour;
  private float price;

  Car(String make, String model, int year, int odometer, String colour, float price) {
    this.make = make;
    this.model = model;
    this.year = year;
    this.odometer = odometer;
    this.colour = colour;
    this.price = price;
  }

  public String getMake() { return this.make; }
  public String getModel() { return this.model; }
  public float getPrice() { return this.price; }

  /** This method is used to format information about the car into a string. */
  @Override
  public String toString() {
    return String.format("%s %d %s %s, %d KM, $%.2f", this.colour, this.year, this.make, this.model, this.odometer, this.price);
  }
}

class CarDealership {
  // We use an arraylist to store the inventory because it is flexible: if we want
  // to add or remove cars later on, it is easier to do so than if we used an array.
  private ArrayList<Car> inventory = new ArrayList<Car>();

  CarDealership() {
    this.inventory.add(new Car("Honda", "Pilot EX-L", 2014, 187152, "Blue", 19988));
    this.inventory.add(new Car("Hyundai", "Elantra Ultimate", 2020, 18, "White", 29254));
    this.inventory.add(new Car("Ford", "Edge SEL", 2019, 24278, "Grey", 31998));
  }

  public void addCar(String make, String model, int year, int odometer, String colour, float price) {
    this.inventory.add(new Car(make, model, year, odometer, colour, price));
  }

  public void addCar(Car car) {
    this.inventory.add(car);
  }

  public ArrayList<Car> getInventory() {
    return this.inventory;
  }

  /**
   * Gets a list of cars with the specified make.
   */
  public ArrayList<Car> getByMake(String make) {
    ArrayList<Car> foundCars = new ArrayList<Car>();
    for (Car car : this.inventory)
      if (car.getMake() == make)
        foundCars.add(car);
    return foundCars;
  }

  /**
   * Gets a list of cars with the specified make and model.
   */
  public ArrayList<Car> getByMakeAndModel(String make, String model) {
    ArrayList<Car> foundCars = new ArrayList<Car>();
    for (Car car : this.inventory)
      if (car.getMake() == make && car.getModel() == model)
        foundCars.add(car);
    return foundCars;
  }

  public ArrayList<Car> getByPrice(float from, float to) {
    ArrayList<Car> foundCars = new ArrayList<Car>();
    for (Car car : this.inventory)
      if (car.getPrice() > from && car.getPrice() < to)
        foundCars.add(car);
    return foundCars;
  }

  // We can create several functions like the above, looping through the dealership's
  // inventory and returning a new list with the cars that match the specifications.
}

public class Main {
  public static void main(String[] args) {
    CarDealership cd = new CarDealership();

    System.out.println("All cars:");
    for (Car c : cd.getInventory())
      System.out.println(c);

    Car newCar = new Car("Honda", "CR-V EX", 2019, 11, "Black", 36500);
    cd.addCar(newCar);
    System.out.println("\nAdded " + newCar);

    System.out.println("\nAll Honda cars:");
    for (Car c : cd.getByMake("Honda"))
      System.out.println(c);

    System.out.println("\nAll cars that cost from $10000 to $30000:");
    for (Car c : cd.getByPrice(10000, 30000))
      System.out.println(c);
  }
}
