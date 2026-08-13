--ネクロの魔導書
-- 效果：
-- 把自己墓地1只魔法师族怪兽从游戏中除外，把这张卡以外的手卡1张名字带有「魔导书」的魔法卡给对方观看才能发动。选择自己墓地1只魔法师族怪兽表侧攻击表示特殊召唤，把这张卡装备。此外，装备怪兽的等级上升因为这张卡发动而除外的魔法师族怪兽的等级数值。「死灵之魔导书」在1回合只能发动1张。
function c52628687.initial_effect(c)
	-- 对应效果原文：把自己墓地1只魔法师族怪兽从游戏中除外，把这张卡以外的手卡1张名字带有「魔导书」的魔法卡给对方观看才能发动。选择自己墓地1只魔法师族怪兽表侧攻击表示特殊召唤，把这张卡装备。此外，装备怪兽的等级上升因为这张卡发动而除外的魔法师族怪兽的等级数值。「死灵之魔导书」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,52628687+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c52628687.cost)
	e1:SetTarget(c52628687.target)
	e1:SetOperation(c52628687.operation)
	c:RegisterEffect(e1)
end
-- 代价占位函数：因真正代价在target中支付，这里仅设置标记100表示允许继续，返回true表示可发动；实际除外怪兽和展示手卡将在target中完成。
function c52628687.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 墓地除外代价筛选：选择自己墓地1只魔法师族怪兽，要求等级>0、可作为代价除外，且墓地存在另一只（排除该卡）可特殊召唤的魔法师族怪兽。
function c52628687.cfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:GetLevel()>0 and c:IsAbleToRemoveAsCost()
		-- 确认墓地存在排除候选代价卡自身外、可作为效果对象被特殊召唤的魔法师族怪兽，保证除外后仍有可特殊召唤的目标。
		and Duel.IsExistingTarget(c52628687.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
-- 手卡展示筛选：选择1张卡名带有「魔导书」的魔法卡，且该卡当前未被公开。
function c52628687.cffilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and not c:IsPublic()
end
-- 特殊召唤对象筛选：选择自己墓地1只魔法师族怪兽，要求能被效果以表侧攻击表示特殊召唤。
function c52628687.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 发动时的目标处理：先确认主怪兽区有空位、墓地存在可除外的魔法师族怪兽及可特殊召唤目标、手卡存在可展示的魔导书；随后实际支付代价（除外怪兽、展示手卡魔导书），再选择要特殊召唤的墓地魔法师族怪兽作为对象，并设置特殊召唤与装备的操作信息。
function c52628687.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c52628687.spfilter(chkc,e,tp) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查我方主要怪兽区域是否有空格，确保能特殊召唤怪兽。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查墓地是否存在至少1张满足代价条件的魔法师族怪兽（该条件已内含后续存在可特殊召唤目标的确认）。
			and Duel.IsExistingMatchingCard(c52628687.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			-- 检查手卡是否存在至少1张除本卡以外、卡名带有「魔导书」且可展示的魔法卡。
			and Duel.IsExistingMatchingCard(c52628687.cffilter,tp,LOCATION_HAND,0,1,e:GetHandler())
	end
	-- 弹出选择提示：请选择要除外的魔法师族怪兽（作为代价）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1张满足条件的魔法师族怪兽作为除外代价。
	local rg=Duel.SelectMatchingCard(tp,c52628687.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetLevel())
	-- 将选择的魔法师族怪兽以表侧表示除外，作为发动代价。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	-- 弹出选择提示：请选择要展示给对方确认的手卡「魔导书」魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家从手卡选择1张除本卡以外、满足条件的「魔导书」魔法卡。
	local cg=Duel.SelectMatchingCard(tp,c52628687.cffilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选择的「魔导书」展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,cg)
	-- 展示后洗切我方手牌，重置手牌顺序。
	Duel.ShuffleHand(tp)
	-- 弹出选择提示：请选择要特殊召唤的墓地魔法师族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的魔法师族怪兽作为特殊召唤对象（排除已除外的代价卡），并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c52628687.spfilter,tp,LOCATION_GRAVE,0,1,1,rg:GetFirst(),e,tp)
	-- 设置操作信息：本连锁包含特殊召唤1只怪兽（对象为g）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息：本连锁包含装备效果，由本卡装备给特殊召唤的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制判断函数：本卡仅能装备于记录的目标怪兽（e:GetLabelObject()）。
function c52628687.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 效果处理：确认本卡和目标怪兽仍与效果关联后，将目标怪兽表侧攻击表示特殊召唤；成功后把本卡装备给该怪兽，并赋予其等级上升效果和装备限制。
function c52628687.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本效果发动时选择的目标怪兽（特殊召唤对象）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 以分解式先将目标怪兽表侧攻击表示特殊召唤（若成功则继续执行装备和等级上升处理）。
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		-- 对应效果原文：此外，装备怪兽的等级上升因为这张卡发动而除外的魔法师族怪兽的等级数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 将本卡作为装备卡装备给特殊召唤出的怪兽。
		Duel.Equip(tp,c,tc)
		-- 对应效果原文：把这张卡装备（装备对象限制为所特殊召唤的怪兽）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetLabelObject(tc)
		e2:SetValue(c52628687.eqlimit)
		c:RegisterEffect(e2)
	end
	-- 完成整个特殊召唤处理（与SpecialSummonStep配对使用，结束连锁中的特殊召唤）。
	Duel.SpecialSummonComplete()
end
