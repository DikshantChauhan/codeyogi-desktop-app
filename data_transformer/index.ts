import * as fs from "fs";
import * as path from "path";

const DATA_DIR = path.join(__dirname, "data");
const PATHWAY_FILE = path.join(DATA_DIR, "pathway.ts");
const STEPS_DIR = path.join(DATA_DIR, "steps");
const ASSIGNMENTS_MD_DIR = path.join(DATA_DIR, "_assignments");
const IMAGES_DIR = path.join(DATA_DIR, "images");
const OUTPUT_DIR = path.join(__dirname, "_data");
const OUTPUT_STEPS_JSON_DIR = path.join(OUTPUT_DIR, "steps");
const OUTPUT_PATHWAY_JSON_FILE = path.join(OUTPUT_DIR, "pathway.json");

async function loadStepData(stepId: string): Promise<any> {
  const stepFilePath = path.join(STEPS_DIR, `${stepId}.ts`);
  try {
    if (!fs.existsSync(stepFilePath)) {
      throw new Error(`Step file not found: ${stepFilePath}.`);
    }

    const stepModule = await import(stepFilePath);
    return stepModule.default;
  } catch (error) {
    throw new Error(`Error loading step data for ${stepId} from ${stepFilePath}: ${error}`);
  }
}

async function main() {
  console.log("Starting pathway data generation...");

  // 1. Load pathway order
  let pathwayOrder: string[] = [];
  try {
    const pathwayModule = await import(PATHWAY_FILE);
    if (Array.isArray(pathwayModule.default)) {
      pathwayOrder = pathwayModule.default;
    } else {
      console.error(`Error: Default export from ${PATHWAY_FILE} is not an array.`);
      return;
    }
    console.log(`Loaded pathway order with ${pathwayOrder.length} steps.`);
  } catch (error) {
    console.error(`Error loading pathway order from ${PATHWAY_FILE}:`, error);
    return;
  }

  // 2. Process each step
  for (const stepId of pathwayOrder) {
    console.log(`Processing step: ${stepId}...`);
    const stepData = await loadStepData(stepId);

    if (!stepData || !stepData.type) {
      throw new Error(`No data or type found for step ${stepId}.`);
    }

    if (fs.existsSync(path.join(OUTPUT_STEPS_JSON_DIR, `${stepId}.json`))) {
      fs.unlinkSync(path.join(OUTPUT_STEPS_JSON_DIR, `${stepId}.json`));
    } else {
      fs.mkdirSync(OUTPUT_STEPS_JSON_DIR, { recursive: true });
    }
    fs.writeFileSync(path.join(OUTPUT_STEPS_JSON_DIR, `${stepId}.json`), JSON.stringify(stepData, null, 2));
  }

  console.log("Copying images to output dir...");
  fs.cpSync(IMAGES_DIR, path.join(OUTPUT_DIR, "images"), { recursive: true });

  console.log("Copying assignments to output dir...");
  fs.cpSync(ASSIGNMENTS_MD_DIR, path.join(OUTPUT_DIR, "_assignments"), { recursive: true });

  console.log("Saving pathway.json...");
  fs.writeFileSync(OUTPUT_PATHWAY_JSON_FILE, JSON.stringify(pathwayOrder, null, 2));
}

main().catch((error) => {
  console.error("Unhandled error in main execution:", error);
});
