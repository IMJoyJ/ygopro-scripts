--デーモンの雄叫び
-- 效果：
-- 支付500基本分才能发动。从自己的墓地里特殊召唤1只名称中含有「恶魔」字样的怪兽上场。此怪兽不可作为任何情况下的祭品。本回合的结束阶段时，此怪兽被破坏。
function c56246017.initial_effect(c)
	-- 支付500基本分才能发动。从自己的墓地里特殊召唤1只名称中含有「恶魔」字样的怪兽上场。此怪兽不可作为任何情况下的祭品。本回合的结束阶段时，此怪兽被破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c56246017.cost)
	e1:SetTarget(c56246017.target)
	e1:SetOperation(c56246017.activate)
	c:RegisterEffect(e1)
end
-- 发动代价处理：检查并支付500点基本分。
function c56246017.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付500点基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除玩家500点基本分。
	Duel.PayLPCost(tp,500)
end
-- 过滤条件：自己墓地中属于「恶魔」系列且可以特殊召唤的怪兽。
function c56246017.filter(c,e,tp)
	return c:IsSetCard(0x45) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检查。
function c56246017.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c56246017.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的「恶魔」怪兽作为效果对象。
		and Duel.IsExistingTarget(c56246017.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「恶魔」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c56246017.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：特殊召唤目标怪兽，并适用不能解放以及结束阶段破坏的效果。
function c56246017.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否还有空余的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取发动的效果对象。
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽仍符合效果条件，则将其以表侧表示特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 此怪兽不可作为任何情况下的祭品。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e2,true)
		-- 本回合的结束阶段时，此怪兽被破坏。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetOperation(c56246017.desop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		tc:RegisterEffect(e3,true)
	end
end
-- 结束阶段破坏该怪兽的具体操作函数。
function c56246017.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将该怪兽破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
