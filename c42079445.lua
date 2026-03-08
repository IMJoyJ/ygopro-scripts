--ロスト・スター・ディセント
-- 效果：
-- ①：以自己墓地1只同调怪兽为对象才能发动。那只怪兽的等级下降1星，守备力变成0守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化，不能把表示形式变更。
function c42079445.initial_effect(c)
	-- 效果原文内容：①：以自己墓地1只同调怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c42079445.sptg)
	e1:SetOperation(c42079445.spop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的同调怪兽（可特殊召唤）
function c42079445.spfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果作用：选择目标怪兽
function c42079445.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c42079445.spfilter(chkc,e,tp) end
	-- 效果作用：判断场上是否有特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断自己墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c42079445.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的墓地怪兽作为对象
	local g=Duel.SelectTarget(tp,c42079445.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 效果作用：设置连锁操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果原文内容：那只怪兽的等级下降1星，守备力变成0守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化，不能把表示形式变更。
function c42079445.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 效果作用：判断目标怪兽是否有效且执行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 效果原文内容：这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 效果原文内容：不能把表示形式变更
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 效果原文内容：那只怪兽的等级下降1星
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_LEVEL)
		e3:SetValue(-1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
		-- 效果原文内容：守备力变成0守备表示特殊召唤
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e4:SetValue(0)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4,true)
		-- 效果原文内容：不能把表示形式变更
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e5,true)
	end
	-- 效果作用：完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
