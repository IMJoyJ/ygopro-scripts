--漆黒の魔王 LV6
-- 效果：
-- 用「漆黑之魔王 LV4」的效果特殊召唤的场合，这张卡战斗破坏的对方怪兽的效果无效化。这个效果把对方怪兽的效果无效化的下次的自己回合的准备阶段时，可以把这张卡送去墓地从手卡·卡组特殊召唤1只「漆黑之魔王 LV8」。
function c12817939.initial_effect(c)
	-- 用「漆黑之魔王 LV4」的效果特殊召唤的场合，这张卡战斗破坏的对方怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c12817939.disop)
	c:RegisterEffect(e1)
	-- 这个效果把对方怪兽的效果无效化的下次的自己回合的准备阶段时，可以把这张卡送去墓地从手卡·卡组特殊召唤1只「漆黑之魔王 LV8」。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12817939,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c12817939.spcon)
	e2:SetCost(c12817939.spcost)
	e2:SetTarget(c12817939.sptg)
	e2:SetOperation(c12817939.spop)
	c:RegisterEffect(e2)
end
c12817939.lvup={85313220,58206034}
c12817939.lvdn={85313220}
-- 伤害计算后，若本卡是由「漆黑之魔王 LV4」的效果特殊召唤、自身未被战斗破坏，且战斗对象是被战斗破坏的效果怪兽，则将那只对方怪兽的效果无效化，并为本卡记录该效果已发动的标记。
function c12817939.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击目标怪兽（即被攻击的怪兽）。
	local d=Duel.GetAttackTarget()
	-- 如果攻击目标为本卡，则将对象改为攻击怪兽，从而处理对方怪兽。
	if d==c then d=Duel.GetAttacker() end
	if d and d:IsStatus(STATUS_BATTLE_DESTROYED) and d:IsType(TYPE_EFFECT)
		and c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_LV and not c:IsStatus(STATUS_BATTLE_DESTROYED) then
		-- 这张卡战斗破坏的对方怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x17a0000)
		d:RegisterEffect(e1)
		c:RegisterFlagEffect(12817939,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,2)
	end
end
-- 准备阶段发动效果的条件：当前为自己回合，且本卡已通过战斗无效了对方怪兽的效果（持有标记）。
function c12817939.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件为：当前回合玩家是自己，且本卡持有已发动过无效效果的标记。
	return tp==Duel.GetTurnPlayer() and e:GetHandler():GetFlagEffect(12817939)~=0
end
-- 发动代价：将自己这张卡送去墓地，先检查本卡能否作为代价送去墓地，在支付时实际执行送墓。
function c12817939.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将本卡作为代价送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选可特殊召唤的卡：卡名必须为「漆黑之魔王 LV8」(58206034)，且对该玩家可以不检查召唤条件、不检查苏生限制地特殊召唤。
function c12817939.spfilter(c,e,tp)
	return c:IsCode(58206034) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 发动时判定：自己主要怪兽区域至少有可用位置（允许处理时因送墓腾出），且手卡·卡组中存在符合条件的「漆黑之魔王 LV8」。
function c12817939.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否有可用的区域（计算时允许空位为-1，因为发动后自己作为代价送墓可腾出位置）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡·卡组是否存在至少1张符合条件的「漆黑之魔王 LV8」。
		and Duel.IsExistingMatchingCard(c12817939.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，声明本次效果将把1张手卡·卡组的怪兽特殊召唤，用于后续时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：若主要怪兽区域没有空位则结束；否则提示玩家选择1张手卡·卡组的「漆黑之魔王 LV8」，以LV进化特殊召唤方式表侧表示特殊召唤，并完成该卡的进化处理。
function c12817939.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区域没有可用格则无法特殊召唤，直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家展示选择提示，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组中选择1张符合条件（卡名「漆黑之魔王 LV8」且可特殊召唤）的卡。
	local g=Duel.SelectMatchingCard(tp,c12817939.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的「漆黑之魔王 LV8」以LV进化特殊召唤方式、表侧表示特殊召唤到自己的主要怪兽区域（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,SUMMON_VALUE_LV,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
