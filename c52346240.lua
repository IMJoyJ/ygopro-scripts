--ロックキャット
-- 效果：
-- 这张卡召唤成功时，可以选择自己墓地存在的1只1星的兽族怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c52346240.initial_effect(c)
	-- 效果原文内容：这张卡召唤成功时，可以选择自己墓地存在的1只1星的兽族怪兽表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52346240,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c52346240.sptg)
	e1:SetOperation(c52346240.spop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的墓地怪兽（1星、兽族、可特殊召唤）
function c52346240.filter(c,e,tp)
	return c:IsLevel(1) and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判断是否满足发动条件（存在目标怪兽且场上存在空位）
function c52346240.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c52346240.filter(chkc,e,tp) end
	-- 判断是否存在符合条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c52346240.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 判断场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c52346240.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，确定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：特殊召唤目标怪兽并使其效果无效
function c52346240.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽有效且为兽族，并尝试特殊召唤
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_BEAST) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
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
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
