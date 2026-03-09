--魂を呼ぶ者
-- 效果：
-- 反转：从自己墓地里特殊召唤1只3星以下的通常怪兽上场。
function c48659020.initial_effect(c)
	-- 反转：从自己墓地里特殊召唤1只3星以下的通常怪兽上场。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48659020,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetTarget(c48659020.target)
	e1:SetOperation(c48659020.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查满足条件的通常怪兽（等级不超过3），且可以被特殊召唤。
function c48659020.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时点，判断是否满足发动条件，包括场上是否有空位和墓地是否存在符合条件的怪兽。
function c48659020.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c48659020.filter(chkc,e,tp) end
	-- 检查玩家场上是否有可用区域（主怪兽区）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在至少1张满足过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(c48659020.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从玩家墓地中选择一张满足条件的怪兽作为目标。
	local g=Duel.SelectTarget(tp,c48659020.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果发动时执行的操作，将选中的怪兽特殊召唤上场。
function c48659020.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示的形式特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
