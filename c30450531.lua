--降霊の儀式
-- 效果：
-- 指定自己墓地里1张名称中含有「守墓」的怪兽卡特殊召唤。这张卡的发动不受「王家长眠之谷」的限制。
function c30450531.initial_effect(c)
	-- 效果原文内容：指定自己墓地里1张名称中含有「守墓」的怪兽卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c30450531.target)
	e1:SetOperation(c30450531.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：这张卡的发动不受「王家长眠之谷」的限制。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NECRO_VALLEY_IM)
	c:RegisterEffect(e2)
end
-- 规则层面作用：定义过滤函数，用于筛选墓地里含有「守墓」字段且可以特殊召唤的怪兽。
function c30450531.filter(c,e,tp)
	return c:IsSetCard(0x2e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：设置效果的目标选择条件，当chkc不为空时，判断目标是否为己方墓地中的怪兽且满足过滤条件。
function c30450531.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c30450531.filter(chkc,e,tp) end
	-- 规则层面作用：判断己方场上是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：判断己方墓地中是否存在至少一张符合条件的怪兽卡。
		and Duel.IsExistingTarget(c30450531.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面作用：向玩家发送提示信息，提示其选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：从己方墓地中选择一张符合条件的怪兽卡作为效果对象。
	local g=Duel.SelectTarget(tp,c30450531.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面作用：设置当前连锁的操作信息，表明将要进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 规则层面作用：定义效果发动后的处理函数，用于执行特殊召唤操作。
function c30450531.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面作用：将目标怪兽以正面表示的形式特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
