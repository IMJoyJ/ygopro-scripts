--紅蓮の指名者
-- 效果：
-- ①：支付2000基本分，把手卡全部给对方观看才能发动。把对方手卡确认，从那之中选1张直到下次的对方结束阶段除外。
function c43262273.initial_effect(c)
	-- ①：支付2000基本分，把手卡全部给对方观看才能发动。把对方手卡确认，从那之中选1张直到下次的对方结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_TOHAND)
	e1:SetCost(c43262273.cost)
	e1:SetTarget(c43262273.target)
	e1:SetOperation(c43262273.activate)
	c:RegisterEffect(e1)
end
-- 检查玩家是否能支付2000基本分且自己手卡不为空且没有公开的手卡
function c43262273.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=0
		-- 检查自己手卡是否全部未公开
		and not Duel.IsExistingMatchingCard(Card.IsPublic,tp,LOCATION_HAND,0,1,nil) end
	-- 支付2000基本分
	Duel.PayLPCost(tp,2000)
	-- 获取自己的手卡组
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 确认对方查看自己的手卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手卡
	Duel.ShuffleHand(tp)
end
-- 检查对方手卡是否存在可除外的卡
function c43262273.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡是否存在
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0
		-- 检查对方手卡是否存在可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	-- 设置操作信息为除外对方手卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,LOCATION_HAND)
end
-- 发动效果：确认对方手卡并选择除外一张
function c43262273.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡组
	local g0=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 确认自己查看对方手卡
	Duel.ConfirmCards(tp,g0)
	-- 获取对方手卡组中可除外的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	if g:GetCount()>0 then
		-- 提示选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		-- 将选中的卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		tc:RegisterFlagEffect(43262273,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 设置一个在对方结束阶段触发的效果用于将卡送回手卡
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		-- 判断是否为对方回合且为结束阶段
		if Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()==PHASE_END then
			-- 记录当前回合数
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		else
			e1:SetLabel(0)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		end
		e1:SetLabelObject(tc)
		e1:SetCondition(c43262273.retcon)
		e1:SetOperation(c43262273.retop)
		-- 注册该效果
		Duel.RegisterEffect(e1,tp)
	end
	-- 洗切对方手卡
	Duel.ShuffleHand(1-tp)
end
-- 判断是否为对方回合且回合数不等于记录值
function c43262273.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(43262273)==0 then
		e:Reset()
		return false
	else
		-- 判断是否为对方回合且回合数不等于记录值
		return Duel.GetTurnPlayer()==1-tp and Duel.GetTurnCount()~=e:GetLabel()
	end
end
-- 将卡送回对方手卡
function c43262273.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将卡送回对方手卡
	Duel.SendtoHand(tc,1-tp,REASON_EFFECT)
end
