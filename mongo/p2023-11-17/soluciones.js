// 1
db.sales.find(
  {
    storeLocation: {
      $in: ["London", "Austin", "San Diego"],
    },
    "customer.age": {
      $gte: 18,
    },
    items: {
      $elemMatch: {
        price: {
          $gte: 1000,
        },
        tags: {
          $elemMatch: {
            $in: ["school", "kids"],
          },
        },
      },
    },
  },
  {
    sale: "$_id",
    saleDate: 1,
    storeLocation: 1,
    email: "$customer.email",
  }
);

db.sales.find();

// 2
// Forma intuitiva
db.sales.aggregate([
  {
    $match: {
      storeLocation: "Seattle",
      purchaseMethod: {
        $in: ["In store", "Phone"],
      },
      saleDate: {
        $gte: new Date("2014-02-01"),
        $lte: new Date("2015-01-31"),
      },
    },
  },
  {
    $unwind: "$items",
  },
  {
    $project: {
      customer_email: "$customer.email",
      customer_satisfaction: "$customer.satisfaction",
      total_ammount: { $multiply: ["$items.price", "$items.quantity"] },
    },
  },
  {
    $group: {
      _id: "$_id",
      customer_email: { $first: "$customer_email" },
      customer_satisfaction: { $first: "$customer_satisfaction" },
      total_ammount: { $sum: "$total_ammount" },
    },
  },
  {
    $sort: {
      customer_satisfaction: -1,
      customer_email: 1,
    },
  },
]);

// Forma "más efifiente" (Aunque genera también info intermedia redundante)
db.sales.aggregate([
  {
    $match: {
      storeLocation: "Seattle",
      purchaseMethod: {
        $in: ["In store", "Phone"],
      },
      saleDate: {
        $gte: new Date("2014-02-01"),
        $lte: new Date("2015-01-31"),
      },
    },
  },
  {
    $addFields: {
      total_ammount: {
        $map: {
          input: "$items",
          as: "item",
          in: {
            $multiply: ["$$item.price", "$$item.quantity"],
          },
        },
      },
    },
  },
  {
    $project: {
      customer_email: "$customer.email",
      customer_satisfaction: "$customer.satisfaction",
      total_ammount: { $sum: "$total_ammount" },
    },
  },
  {
    $sort: {
      customer_satisfaction: -1,
      customer_email: 1,
    },
  },
]);

db.sales.find();

// 3
db.createView("salesInvoiced", "sales", [
  {
    $unwind: "$items",
  },
  {
    $addFields: {
      total_ammount: { $multiply: ["$items.price", "$items.quantity"] },
    },
  },
  {
    $group: {
      _id: { year: { $year: "$saleDate" }, month: { $month: "$saleDate" } },
      date: {
        $first: {
          $dateToString: { format: "%Y-%m", date: "$saleDate" },
        },
      },
      min_ammount: { $min: "$total_ammount" },
      max_ammount: { $max: "$total_ammount" },
      total_ammount: { $sum: "$total_ammount" },
    },
  },
  {
    $project: {
      _id: 0,
      date: 1,
      min_ammount: 1,
      max_ammount: 1,
      total_ammount: 1,
    },
  },
  {
    $sort: { date: 1 },
  },
]);

db.salesInvoiced.drop();
db.salesInvoiced.find();

db.sales.findOne();

// 4

db.sales.aggregate([
  {
    $addFields: {
      total_ammount: {
        $map: {
          input: "$items",
          as: "item",
          in: {
            $multiply: ["$$item.price", "$$item.quantity"],
          },
        },
      },
    },
  },
  {
    $unwind: "$total_ammount",
  },
  {
    $lookup: {
      from: "storeObjectives",
      localField: "storeLocation",
      foreignField: "_id",
      as: "store",
    },
  },
  {
    $unwind: "$store",
  },
  {
    $group: {
      _id: "$storeLocation",
      storeLocation: { $first: "$storeLocation" },
      storeObjective: { $first: "$store.objective" },
      avg_ammount: { $avg: "$total_ammount" },
    },
  },
  {
    $project: {
      _id: 0,
      storeLocation: 1,
      storeObjective: 1,
      avg_ammount: 1,
      diff_to_objective: { $subtract: ["$avg_ammount", "$storeObjective"] },
    },
  },
]);

db.sales.aggregate([
  {
    $unwind: "$items",
  },
  {
    $addFields: {
      total_ammount: {
        $multiply: ["$items.price", "$items.quantity"],
      },
    },
  },
  {
    $lookup: {
      from: "storeObjectives",
      localField: "storeLocation",
      foreignField: "_id",
      as: "store",
    },
  },
  {
    $unwind: "$store",
  },
  {
    $group: {
      _id: "$storeLocation",
      storeLocation: { $first: "$storeLocation" },
      storeObjective: { $first: "$store.objective" },
      avg_ammount: { $avg: "$total_ammount" },
    },
  },
  {
    $project: {
      _id: 0,
      storeLocation: 1,
      storeObjective: 1,
      avg_ammount: 1,
      diff_to_objective: { $subtract: ["$avg_ammount", "$storeObjective"] },
    },
  },
]);

db.storeObjectives.findOne();
db.sales.findOne();

// 5
db.runCommand({
  collMod: "sales",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["saleDate", "storeLocation", "purchaseMethod", "customer"],
      properties: {
        saleDate: {
          bsonType: "date",
        },
        storeLocation: {
          bsonType: "string",
        },
        purchaseMethod: {
          bsonType: "string",
        },
        customer: {
          bsonType: "object",
          required: ["gender", "age", "email", "satisfaction"],
          properties: {
            gender: {
              enum: ["M", "F"],
            },
            age: {
              bsonType: "int",
              minimum: 0,
              maximum: 150,
            },
            email: {
              bsonType: "string",
              pattern: "^(.*)@(.*)\\.(.{2,4})$",
            },
            satisfaction: {
              bsonType: "int",
              minimum: 0,
              maximum: 5,
            },
          },
        },
      },
    },
  },
});

db.sales.findOne();

// Caso de éxito
db.sales.insertOne({
  saleDate: new Date("2024-03-23T21:06:49.506Z"),
  items: [
    {
      name: "binder",
      tags: ["school", "general", "organization"],
      price: 14.16,
      quantity: 3,
    },
  ],
  storeLocation: "Denver",
  customer: {
    gender: "M",
    age: NumberInt(43),
    email: "cauho@witwuta.sv",
    satisfaction: NumberInt(4),
  },
  purchaseMethod: "Online",
});

// Caso de falla (fañta saleDate)
db.sales.insertOne({
  items: [
    {
      name: "binder",
      tags: ["school", "general", "organization"],
      price: 14.16,
      quantity: 3,
    },
  ],
  storeLocation: "Denver",
  customer: {
    gender: "M",
    age: NumberInt(43),
    email: "cauho@witwuta.sv",
    satisfaction: NumberInt(4),
  },
  purchaseMethod: "Online",
});

db.getCollectionInfos()