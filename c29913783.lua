--対壊獣用決戦兵器メカサンダー・キング
-- 效果：
-- 这个卡名的④的效果在决斗中只能使用1次。
-- ①：双方的主要阶段把这张卡从手卡丢弃才能发动。选原本持有者是对方的自己场上1只「坏兽」怪兽除外。那之后，可以从自己墓地选1只怪兽特殊召唤。
-- ②：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ③：场上的这张卡不受其他的「坏兽」卡的效果影响，不会被和「坏兽」怪兽的战斗破坏。
-- ④：自己结束阶段才能发动。这张卡从墓地特殊召唤。
function c29913783.initial_effect(c)
	-- 限制自己场上只能存在1只表侧表示的「坏兽」怪兽（对应②效果）。
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0xd3),LOCATION_MZONE)
	-- ①：双方的主要阶段把这张卡从手卡丢弃才能发动。选原本持有者是对方的自己场上1只「坏兽」怪兽除外。那之后，可以从自己墓地选1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29913783,0))  --"除外坏兽并苏生"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(c29913783.spcon)
	e1:SetCost(c29913783.spcost)
	e1:SetTarget(c29913783.sptg)
	e1:SetOperation(c29913783.spop)
	c:RegisterEffect(e1)
	-- ③：不会被和「坏兽」怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(c29913783.indval)
	c:RegisterEffect(e2)
	-- ③：不受其他的「坏兽」卡的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(c29913783.efilter)
	c:RegisterEffect(e3)
	-- 这个卡名的④的效果在决斗中只能使用1次。④：自己结束阶段才能发动。这张卡从墓地特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(29913783,1))  --"这张卡特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,29913783+EFFECT_COUNT_CODE_DUEL)
	e4:SetCondition(c29913783.spcon2)
	e4:SetTarget(c29913783.sptg2)
	e4:SetOperation(c29913783.spop2)
	c:RegisterEffect(e4)
end
-- e1的发动条件：仅允许在主要阶段1或主要阶段2（即双方主要阶段）发动。
function c29913783.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2，是则条件成立。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- e1的发动代价：判断并执行从手卡丢弃此卡；chk==0时检查此卡可丢弃，执行时将其作为COST丢弃至墓地。
function c29913783.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡从手卡送去墓地，作为①效果的发动代价（丢弃）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 筛选符合条件的坏兽：表侧表示、属「坏兽」字段、可除外且原本持有者为对方（1-tp）的自己场上怪兽。
function c29913783.rmfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xd3) and c:IsAbleToRemove() and c:GetOwner()==1-tp
end
-- ①效果发动前的目标条件检查：确认自己场上有可除外的坏兽，并设置除外操作信息。
function c29913783.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定：若自己场上不存在能除外的坏兽，则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c29913783.rmfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 设置连锁的除外操作信息：从自己怪兽区除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
end
-- 筛选墓地中可被特殊召唤的怪兽（以表侧表示、使用该效果进行特殊召唤）。
function c29913783.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- ①效果处理：先选择并除外1只坏兽；若除外成功且满足墓地特召条件，则询问是否特召，是则中断后从墓地特召1只怪兽。
function c29913783.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出提示框，要求玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己怪兽区选择1张满足rmfilter的坏兽怪兽。
	local g=Duel.SelectMatchingCard(tp,c29913783.rmfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- 若选中且该卡成功除外，继续进行后续墓地特召判定。
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0
		-- 检查自己墓地是否存在不受王家长眠之谷影响且可特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c29913783.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查自己怪兽区是否有空位以特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 由玩家选择是否进行“那之后”的墓地特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(29913783,2)) then  --"是否从墓地特殊召唤？"
		-- 中断当前效果处理，使后续特殊召唤成为独立处理，避免与除外同时进行。
		Duel.BreakEffect()
		-- 弹出提示框，要求玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从自己墓地选择1张满足条件且不受王家长眠之谷影响的怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c29913783.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判定与这张卡战斗的怪兽是否为「坏兽」，若是则这张卡不会被那次战斗破坏（③效果）。
function c29913783.indval(e,c)
	return c:IsSetCard(0xd3)
end
-- 判定来源效果是否来自「坏兽」字段的卡，若是则这张卡不受该效果影响（③效果）。
function c29913783.efilter(e,te)
	return te:GetHandler():IsSetCard(0xd3)
end
-- ④效果的发动条件：仅在拥有者（tp）自己的结束阶段且本卡在墓地时可发动。
function c29913783.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己（tp），保证只有自己回合的结束阶段触发。
	return tp==Duel.GetTurnPlayer()
end
-- ④效果发动前：检查此卡能否特殊召唤、自己场上是否有空位，并设置特殊召唤操作信息。
function c29913783.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定：此卡可特殊召唤且自己怪兽区有空位。
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置操作信息：本次连锁会将此卡特殊召唤（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ④效果处理：若此卡仍与效果相关联，则将其特殊召唤到自己场上。
function c29913783.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡从墓地以表侧表示特殊召唤到自己怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
