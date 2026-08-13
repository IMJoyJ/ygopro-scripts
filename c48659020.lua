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
-- 检查卡片是否为3星以下的通常怪兽，且可以被特殊召唤。
function c48659020.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件判定：对象必须为己方墓地的满足条件的通常怪兽；且己方主要怪兽区有空位、墓地存在符合条件的怪兽。
function c48659020.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c48659020.filter(chkc,e,tp) end
	-- 确认己方主要怪兽区存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认墓地存在至少1只满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c48659020.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方墓地选择1只满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c48659020.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的特殊召唤操作信息，供效果处理和相关卡片的判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的对象卡特殊召唤到己方场上。
function c48659020.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
