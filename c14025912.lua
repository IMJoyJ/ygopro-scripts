--斬機方程式
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「斩机」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力直到回合结束时上升1000。
function c14025912.initial_effect(c)
	-- ①：以自己墓地1只「斩机」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,14025912+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c14025912.target)
	e1:SetOperation(c14025912.activate)
	c:RegisterEffect(e1)
end
-- 判断目标怪兽是否为「斩机」卡且可以特殊召唤
function c14025912.filter(c,e,tp)
	return c:IsSetCard(0x132) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时选择对象怪兽
function c14025912.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14025912.filter(chkc,e,tp) end
	-- 检查场上是否有足够空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c14025912.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择符合条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c14025912.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的发动
function c14025912.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽有效且成功执行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的攻击力直到回合结束时上升1000
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
