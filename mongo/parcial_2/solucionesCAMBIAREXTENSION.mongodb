// 1
db.grades.aggregate([
  {
    $match: {
      $and: [
        {
          $or: [
            {
              scores: {
                $elemMatch: {
                  type: "exam",
                  score: {
                    $gte: 80,
                  },
                },
              },
            },
            {
              scores: {
                $elemMatch: {
                  type: "quiz",
                  score: {
                    $gte: 90,
                  },
                },
              },
            },
          ],
        },
        {
          $expr: {
            $gte: [{ $min: "$scores.score" }, 60],
          },
        },
      ],
    },
  },
  {
    $project: {
      _id: 0,
    },
  },
  {
    $sort: {
      class_id: -1,
      student_id: 1,
    },
  },
]);

// 2
db.grades.aggregate([
  {
    $match: {
      class_id: {
        $in: [20, 220, 420],
      },
    },
  },
  {
    $project: {
      _id: 0,
      student_id: 1,
      class_id: 1,
      min_score: { $min: "$scores.score" },
      avg_score: { $avg: "$scores.score" },
      max_score: { $max: "$scores.score" },
    },
  },
  {
    $sort: {
      student_id: 1,
      class_id: 1,
    },
  },
]);

// 3
db.grades.aggregate([
  {
    $project: {
      class_id: 1,
      student_id: 1,
      exam_scores: {
        $filter: {
          input: "$scores",
          as: "exam",
          cond: {
            $eq: ["$$exam.type", "exam"],
          },
        },
      },
      quiz_scores: {
        $filter: {
          input: "$scores",
          as: "exam",
          cond: {
            $eq: ["$$exam.type", "quiz"],
          },
        },
      },
    },
  },
  {
    $group: {
      _id: "$class_id",
      max_exam_score: { $max: { $max: "$exam_scores.score" } },
      max_quiz_score: { $max: { $max: "$quiz_scores.score" } },
    },
  },
  {
    $project: {
      class_id: "$_id",
      _id: 0,
      max_exam_score: 1,
      max_quiz_score: 1,
    },
  },
  {
    $sort: {
      class_id: 1,
    },
  },
]);

// Query equivalente aunque más pesada (la usé para testear si me daban lo mismo):
// db.grades.aggregate([
//   {
//     $project: {
//       class_id: 1,
//       student_id: 1,
//       exam_scores: {
//         $filter: {
//           input: "$scores",
//           as: "exam",
//           cond: {
//             $eq: ["$$exam.type", "exam"],
//           },
//         },
//       },
//       quiz_scores: {
//         $filter: {
//           input: "$scores",
//           as: "exam",
//           cond: {
//             $eq: ["$$exam.type", "quiz"],
//           },
//         },
//       },
//     },
//   },
//   {
//     $unwind: "$exam_scores"
//   },
//   {
//     $unwind: "$quiz_scores"
//   },
//   {
//     $group: {
//       _id: "$class_id",
//       max_exam_score: { $max: "$exam_scores.score" },
//       max_quiz_score: { $max: "$quiz_scores.score" },
//     },
//   },
//   {
//     $project: {
//       class_id: "$_id",
//       _id: 0,
//       max_exam_score: 1,
//       max_quiz_score: 1,
//     },
//   },
//   {
//     $sort: {
//       class_id: 1,
//     },
//   },
// ]);

// 4
db.createView("top10students", "grades", [
  {
    $group: {
      _id: "$student_id",
      avg_score: { $avg: { $avg: "$scores.score" } },
    },
  },
  {
    $sort: {
      avg_score: -1,
    },
  },
  {
    $limit: 10,
  },
]);

// Para borrar la view o buscar en la view
// db.top10students.drop();
// db.top10students.find();

// Find equivalente
// db.grades.aggregate([
//   {
//     $group: {
//       _id: "$student_id",
//       avg_score: { $avg: { $avg: "$scores.score" } },
//     },
//   },
//   {
//     $sort: {
//       avg_score: -1,
//     },
//   },
//   {
//     $limit: 10,
//   },
// ]);
//
// Query equivalente que use para testear/comparar resultados
// db.grades.aggregate([
//   {
//     $unwind: "$scores"
//   },
//   {
//     $group: {
//       _id: "$student_id",
//       avg_score: { $avg: "$scores.score" },
//     },
//   },
//   {
//     $sort: {
//       avg_score: -1,
//     },
//   },
//   {
//     $limit: 10,
//   },
// ]);

// 5
db.grades.updateMany(
  {
    class_id: 339,
  },
  [
    {
      $set: {
        score_avg: { $avg: "$scores.score" },
      },
    },
    {
      $set: {
        letter: {
          $switch: {
            branches: [
              {
                case: {
                  $and: [
                    { $gte: ["$score_avg", 0] },
                    { $lt: ["$score_avg", 60] },
                  ],
                },
                then: "NA",
              },
              {
                case: {
                  $and: [
                    { $gte: ["$score_avg", 60] },
                    { $lt: ["$score_avg", 80] },
                  ],
                },
                then: "A",
              },
              {
                case: {
                  $and: [
                    { $gte: ["$score_avg", 80] },
                    { $lte: ["$score_avg", 100] },
                  ],
                },
                then: "P",
              },
            ],
          },
        },
      },
    },
  ]
);

// Queries de test/comprobación que usé:
// Para borrar los campos agregados
// db.grades.updateMany(
//   {
//     class_id: 339,
//   },
//   [
//     {
//       $unset: "score_avg",
//     },
//     {
//       $unset: "letter",
//     },
//   ]
// );
// Para ver los documentos que deberían haberse modificado:
// db.grades.find({
//   class_id: 339,
// });

// 6
// (a)
db.runCommand({
  collMod: "grades",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["student_id", "scores", "class_id"],
      properties: {
        student_id: {
          bsonType: "int",
        },
        scores: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["type", "score"],
            properties: {
              type: {
                enum: ["exam", "quiz", "homework"],
              },
              score: {
                bsonType: "double",
              },
            },
          },
        },
        class_id: {
          bsonType: "int",
        },
      },
    },
  },
  validationAction: "error", // Sé que es el valor por defecto, pero por las dudas lo agrego.
  validationLevel: "strict", // Sé que es el valor por defecto, pero por las dudas lo agrego.
});

// Query para ver qué tipos de scores hay
// db.grades.aggregate([
//     {
//         $unwind: "$scores"
//     },
//     {
//         $group: {
//             _id: "$scores.type",
//         }
//     }
// ])
// db.getCollectionInfos()

// (b)
// Casos de Falla
// Falla debido a un score que no es int
db.grades.insertOne({
  student_id: NumberInt(24),
  scores: [
    {
      type: "exam",
      score: "Hola :)",
    },
    {
      type: "quiz",
      score: 39.12,
    },
    {
      type: "homework",
      score: 32.42,
    },
    {
      type: "homework",
      score: 30.11,
    },
  ],
  class_id: NumberInt(39),
});

// Falla debido a que student_id es un objeto y no un int
db.grades.insertOne({
  student_id: {
    name: "Juan Durán",
    detallito: "Juan Durán dice: Te faltó un detallito en este punto.",
    suerte: "Espero aprobar esta materia pronto :-)",
    aclaracion: "Tomarse estos comentarios con humor",
  },
  scores: [
    {
      type: "exam",
      score: 4.132,
    },
    {
      type: "quiz",
      score: 39.12,
    },
    {
      type: "homework",
      score: 32.42,
    },
    {
      type: "homework",
      score: 30.11,
    },
  ],
  class_id: NumberInt(96),
});

// Caso de éxito
db.grades.insertOne({
  student_id: NumberInt(13),
  scores: [
    {
      type: "exam",
      score: 4.132,
    },
    {
      type: "quiz",
      score: 39.12,
    },
    {
      type: "homework",
      score: 32.42,
    },
    {
      type: "homework",
      score: 30.11,
    },
  ],
  class_id: NumberInt(26),
});

// Queries auxiliares para testear funcionamiento:
// db.grades.find(
//     {
//         student_id: 13,
//         class_id: 26
//     }
// );
// db.grades.deleteMany(
//     {
//         student_id: 13,
//         class_id: 26
//     }
// )