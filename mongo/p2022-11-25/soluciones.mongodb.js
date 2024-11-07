// 1
db.restaurants
  .find(
    {
      cuisine: "Italian",
      grades: {
        $elemMatch: {
          grade: "A",
          score: { $gte: 10 },
        },
      },
    },
    {
      _id: 0,
      name: 1,
      borough: 1,
    }
  )
  .sort({ borough: 1, name: 1 });

// Lo mismo pero usando regex
db.restaurants
  .find(
    {
      cuisine: { $regex: /^Italian$/ },
      grades: {
        $elemMatch: {
          grade: "A",
          score: { $gte: 10 },
        },
      },
    },
    {
      _id: 0,
      name: 1,
      borough: 1,
    }
  )
  .sort({ borough: 1, name: 1 });

db.restaurants.findOne();

// 2
db.restaurants.updateMany(
  {
    cuisine: { $in: ["Bakery", "Coffee"] },
  },
  {
    $set: {
      discounts: {
        day: {
          $cond: [{ $eq: ["$borough", "Manhattan"] }, "Monday", "Tuesday"],
          amount: {
            $cond: [{ $eq: ["$borough", "Manhattan"] }, "%10", "5%"],
          },
        },
      },
    },
  }
);

db.restaurants.find({
  cuisine: { $in: ["Bakery", "Coffee"] },
});

// 3
// ESTO NO HANDLEA ERRORES (y para esta db no anda):
// db.restaurants.countDocuments({
//   $expr: {
//     $and: [
//       { $gte: [{ $toInt: "$address.zipcode" }, 10000] },
//       { $lte: [{ $toInt: "$address.zipcode" }, 11000] },
//     ],
//   },
// });

// Esto funciona bien
db.restaurants.countDocuments({
  $expr: {
    $and: [
      {
        $gte: [
          {
            $convert: {
              input: "$address.zipcode",
              to: "int",
              onError: { error: true },
              onNull: { isnull: true },
            },
          },
          10000,
        ],
      },
      {
        $lte: [
          {
            $convert: {
              input: "$address.zipcode",
              to: "int",
              onError: { error: true },
              onNull: { isnull: true },
            },
          },
          11000,
        ],
      },
    ],
  },
});

db.restaurants.findOne();

// 4
db.restaurants.aggregate([
  {
    $unwind: "$grades",
  },
  {
    $match: {
      "grades.date": {
        $gte: new Date("2013-03-01"),
        $lt: new Date("2013-05-01"),
      },
    },
  },
  {
    $group: {
      _id: "$grades.grade",
      count: { $sum: 1 },
    },
  },
  {
    $sort: {
      cuisine: 1,
      _id: 1,
    },
  },
]);

// Forma refinada (aunque más larga)
db.restaurants.aggregate([
  {
    $unwind: "$grades",
  },
  {
    $match: {
      "grades.date": {
        $gte: new Date("2013-03-01"),
        $lt: new Date("2013-05-01"),
      },
    },
  },
  {
    $group: {
      _id: "$grades.grade",
      grade: { $first: "$grades.grade" },
      count: { $sum: 1 },
    },
  },
  {
    $sort: {
      cuisine: 1,
      grade: 1,
    },
  },
  {
    $project: {
      _id: 0,
      grade: 1,
      count: 1,
    },
  },
]);

// 5
db.restaurants.aggregate(
  {
    $addFields: {
      grade_values: {
        $map: {
          input: "$grades",
          as: "grade",
          in: {
            $switch: {
              branches: [
                {
                  case: {
                    $eq: ["$$grade.grade", "A"],
                  },
                  then: 5,
                },
                {
                  case: {
                    $eq: ["$$grade.grade", "B"],
                  },
                  then: 4,
                },
                {
                  case: {
                    $eq: ["$$grade.grade", "C"],
                  },
                  then: 3,
                },
                {
                  case: {
                    $eq: ["$$grade.grade", "D"],
                  },
                  then: 2,
                },
              ],
              default: 1,
            },
          },
        },
      },
    },
  },
  {
    $unwind: "$grade_values",
  },
  {
    $group: {
      _id: "$cuisine",
      avg_grade: { $avg: "$grade_values" },
      max_grade: { $max: "$grade_values" },
      min_grade: { $min: "$grade_values" },
    },
  },
  {
    $project: {
      cuisine: "$_id",
      avg_grade: 1,
      max_grade: 1,
      min_grade: 1,
    },
  },
  {
    $sort: {
      avg_grade: -1,
    },
  }
);

// 6
db.runCommand({
  collMod: "restaurant",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      // La consigna no lo pide: required: ["address", "borough", "cuisine", "grades", "name", "restaurant_id", "discount"],
      properties: {
        address: {
          bsonType: "object",
          properties: {
            building: {
              bsonType: "string",
            },
            coord: {
              bsonType: "array",
              minItems: 2,
              maxItems: 2,
              items: {
                bsonType: "double",
              },
            },
            street: {
              bsonType: "string",
            },
            zipcode: {
              bsonType: "string",
              pattern:
                "^(?!.*\b10000\b)(10[0-9]{3}|11[0-5][0-9]{2}|116[0-9][0-7])$",
            },
          },
        },
        borough: {
          bsonType: "string",
        },
        cuisine: {
          bsonType: "string",
        },
        grades: {
          bsonType: "object",
          properties: {
            date: {
              bsonType: "date",
            },
            grade: {
              enum: ["A", "B", "C", "D"],
            },
            score: {
              bsonType: "int",
            },
          },
        },
      },
    },
  },
});

db.restaurants.findOne();

// 7
db.createCollection("client_reviews");

db.runCommand({
    collMod: "client_reviews",
    validator: {
      $jsonSchema: {
        bsonType: "object",
        required: ["reviews", "client_id"],
        properties: {
          address: {
            bsonType: "object",
            properties: {
              building: {
                bsonType: "string",
              },
              coord: {
                bsonType: "array",
                minItems: 2,
                maxItems: 2,
                items: {
                  bsonType: "double",
                },
              },
              street: {
                bsonType: "string",
              },
              zipcode: {
                bsonType: "string",
                pattern:
                  "^(?!.*\b10000\b)(10[0-9]{3}|11[0-5][0-9]{2}|116[0-9][0-7])$",
              },
            },
          },
          borough: {
            bsonType: "string",
          },
          cuisine: {
            bsonType: "string",
          },
          grades: {
            bsonType: "object",
            properties: {
              date: {
                bsonType: "date",
              },
              grade: {
                enum: ["A", "B", "C", "D"],
              },
              score: {
                bsonType: "int",
              },
            },
          },
        },
      },
    },
  });

