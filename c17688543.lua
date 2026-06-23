--深すぎた墓穴
-- 效果：
-- ①：以自己或者对方的墓地1只怪兽为对象才能发动。下次的自己准备阶段把那只怪兽从墓地往自己场上特殊召唤。
function c17688543.initial_effect(c)
	-- ①：以自己或者对方的墓地1只怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c17688543.target)
	e1:SetOperation(c17688543.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组
function c17688543.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsSpecialSummonableCard() end
	-- 判断自己场上是否有怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断对方墓地是否存在可特殊召唤的怪兽
		and Duel.IsExistingTarget(Card.IsSpecialSummonableCard,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,Card.IsSpecialSummonableCard,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 下次的自己准备阶段把那只怪兽从墓地往自己场上特殊召唤
function c17688543.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local fid=c:GetFieldID()
		-- 创建一个在准备阶段触发的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c17688543.spcon)
		e1:SetOperation(c17688543.spop)
		-- 判断是否为自己的回合且当前阶段为准备阶段
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
			-- 记录当前回合数
			e1:SetValue(Duel.GetTurnCount())
			tc:RegisterFlagEffect(17688543,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2,fid)
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			e1:SetValue(0)
			tc:RegisterFlagEffect(17688543,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1,fid)
		end
		-- 将效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否为自己的回合且当前回合数不等于记录值
function c17688543.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的回合且当前回合数不等于记录值
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=e:GetValue()
end
-- 执行特殊召唤操作
function c17688543.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:GetFlagEffectLabel(17688543)==e:GetLabel() then
		-- 显示卡片发动的动画
		Duel.Hint(HINT_CARD,0,17688543)
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
