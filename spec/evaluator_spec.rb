require 'spec_helper'

describe BooleanDsl::Evaluator do
  context '#evaluate_comparison' do
    let(:evaluator) { described_class.new(nil, nil) }

    specify { expect(evaluator.evaluate_comparison(1, '==', 1)).to be_truthy }
    specify { expect(evaluator.evaluate_comparison(1, '==', 0)).to be_falsey }
    specify { expect(evaluator.evaluate_comparison(1, '!=', 1)).to be_falsey }
    specify { expect(evaluator.evaluate_comparison(1, '!=', 0)).to be_truthy }

    specify { expect(evaluator.evaluate_comparison('alpha', '==', 'alpha')).to be_truthy }
    specify { expect(evaluator.evaluate_comparison('beta', '==', 'omega')).to be_falsey }
    specify { expect(evaluator.evaluate_comparison('alpha', '!=', 'alpha')).to be_falsey }
    specify { expect(evaluator.evaluate_comparison('beta', '!=', 'omega')).to be_truthy }

    specify { expect(evaluator.evaluate_comparison(10, '<', 20)).to be_truthy }
    specify { expect(evaluator.evaluate_comparison(20, '<', 10)).to be_falsey }
    specify { expect(evaluator.evaluate_comparison(20, '>', 10)).to be_truthy }
    specify { expect(evaluator.evaluate_comparison(10, '>', 20)).to be_falsey }
    specify { expect(evaluator.evaluate_comparison(20, '<=', 20)).to be_truthy }
    specify { expect(evaluator.evaluate_comparison(20, '>=', 20)).to be_truthy }

    specify { expect(evaluator.evaluate_comparison([1, 'alpha'], 'includes', 1)).to be_truthy }
    specify { expect(evaluator.evaluate_comparison([1, 'alpha'], 'includes', 0)).to be_falsey }
    specify { expect(evaluator.evaluate_comparison([1, 'alpha'], 'includes', 'alpha')).to be_truthy }
    specify { expect(evaluator.evaluate_comparison([1, 'alpha'], 'includes', 'beta')).to be_falsey }

    specify { expect(evaluator.evaluate_comparison([1, 'alpha'], 'excludes', 1)).to be_falsey }
    specify { expect(evaluator.evaluate_comparison([1, 'alpha'], 'excludes', 0)).to be_truthy }
    specify { expect(evaluator.evaluate_comparison([1, 'alpha'], 'excludes', 'alpha')).to be_falsey }
    specify { expect(evaluator.evaluate_comparison([1, 'alpha'], 'excludes', 'beta')).to be_truthy }

    specify { expect(evaluator.evaluate_comparison(Date.new(2024,9,1), '==', Date.new(2024,9,1))).to be_truthy }
    specify { expect(evaluator.evaluate_comparison(Date.new(2024,9,1), '<', Date.new(2024,9,2))).to be_truthy }
    specify { expect(evaluator.evaluate_comparison(Date.new(2024,9,1), '>', Date.new(2024,8,31))).to be_truthy }
    specify { expect(evaluator.evaluate_comparison(Date.new(2024,9,1), '<=', Date.new(2024,9,1))).to be_truthy }
    specify { expect(evaluator.evaluate_comparison(Date.new(2024,9,1), '>=', Date.new(2024,9,1))).to be_truthy }

    specify do
      expect { evaluator.evaluate_comparison(Date.new(2024,9,1), '>', 'a string') }
        .to raise_error(BooleanDsl::EvaluationFailed, 'Invalid comparison')
    end
  end

  context '#evaluate_boolean' do
    let(:evaluator) { described_class.new(nil, nil) }

    before do
      allow(evaluator).to receive(:evaluate).with(true).and_return(true)
      allow(evaluator).to receive(:evaluate).with(false).and_return(false)
    end

    specify { expect(evaluator.evaluate_boolean(true, 'and', true)).to be_truthy }
    specify { expect(evaluator.evaluate_boolean(true, 'and', false)).to be_falsey }
    specify { expect(evaluator.evaluate_boolean(false, 'and', true)).to be_falsey }
    specify { expect(evaluator.evaluate_boolean(false, 'and', false)).to be_falsey }

    specify { expect(evaluator.evaluate_boolean(true, 'or', true)).to be_truthy }
    specify { expect(evaluator.evaluate_boolean(true, 'or', false)).to be_truthy }
    specify { expect(evaluator.evaluate_boolean(false, 'or', true)).to be_truthy }
    specify { expect(evaluator.evaluate_boolean(false, 'or', false)).to be_falsey }
  end

  context 'full parse' do
    def outcome_for(expression, context_hash = {})
      described_class.new(expression, context_hash).outcome
    end
    specify { expect(outcome_for('1 == 1')).to be_truthy }
    specify { expect(outcome_for('1 == 0')).to be_falsey }
    specify { expect(outcome_for("(1 < 4 or 5 < 4) and (1 == 1 and 'alpha' == 'alpha')")).to be_truthy }
    specify { expect(outcome_for('gamma == 7', { 'gamma' => 7 })).to be_truthy }
    specify { expect(outcome_for('gamma == 8', { 'gamma' => 7 })).to be_falsey }
    specify { expect(outcome_for("alpha == 'beta'", { 'alpha' => 'beta' })).to be_truthy }
    specify { expect(outcome_for("alpha == 'beta'", { 'alpha' => 'delta' })).to be_falsey }
    specify { expect(outcome_for("20.5% < 50%")).to be_truthy }
    specify { expect(outcome_for("[1,2,3] includes 2")).to be_truthy }
    specify { expect(outcome_for("['alpha','beta'] includes 'beta'")).to be_truthy }
    specify { expect(outcome_for("[] includes 'beta'")).to be_falsey }
    specify { expect(outcome_for("attribute_array includes 'beta'", { "attribute_array" => ["alpha", "beta"]})).to be_truthy }
    specify { expect(outcome_for("[1,2,3] excludes 2")).to be_falsey }
    specify { expect(outcome_for("['alpha','beta'] excludes 'beta'")).to be_falsey }
    specify { expect(outcome_for("[] excludes 'beta'")).to be_truthy }
    specify { expect(outcome_for("attribute_array excludes 'beta'", { "attribute_array" => ["alpha", "beta"]})).to be_falsey }
    specify { expect(outcome_for("start_date > 1/9/2024", { 'start_date' => Date.new(2024,9,2) })).to be_truthy }
  end
end

