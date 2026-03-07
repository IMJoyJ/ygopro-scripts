--シンクロン・エクスプローラー
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只「同调士」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c36643046.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤成功时，以自己墓地1只「同调士」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36643046,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c36643046.sumtg)
	e1:SetOperation(c36643046.sumop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的墓地「同调士」怪兽，该怪兽可以被特殊召唤
function c36643046.filter(c,e,tp)
	return c:IsSetCard(0x1017) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件，包括墓地存在符合条件的怪兽和场上存在空位
function c36643046.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c36643046.filter(chkc,e,tp) end
	-- 判断是否满足发动条件，包括墓地存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c36643046.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 判断是否满足发动条件，包括场上存在空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽，从玩家墓地中选择一只符合条件的怪兽
	local g=Duel.SelectTarget(tp,c36643046.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息，确定要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果作用：将目标怪兽特殊召唤到场上，并使该怪兽的效果无效化
function c36643046.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		-- 效果原文内容：这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果原文内容：这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
