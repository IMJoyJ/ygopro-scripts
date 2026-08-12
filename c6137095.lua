--誤作動
-- 效果：
-- 支付500基本分。陷阱卡的发动无效，那张卡按原本的形式放回。
function c6137095.initial_effect(c)
	-- 支付500基本分。陷阱卡的发动无效，那张卡按原本的形式放回。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c6137095.condition)
	e1:SetCost(c6137095.cost)
	e1:SetTarget(c6137095.target)
	e1:SetOperation(c6137095.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检查被连锁的效果是否为可无效的陷阱卡的发动
function c6137095.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 被连锁的效果是陷阱卡的发动，且该发动可以被无效
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- Cost：支付500基本分
function c6137095.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分
	Duel.PayLPCost(tp,500)
end
-- Target：检查目标卡片状态并设置对应的效果分类与操作信息
function c6137095.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not re:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
			return re:GetHandler():IsCanTurnSet()
		else return true end
	end
	if e:IsCostChecked() then
		if re:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
			e:SetCategory(CATEGORY_NEGATE+CATEGORY_TOHAND)
		else
			e:SetCategory(CATEGORY_NEGATE+CATEGORY_SSET)
		end
	end
	-- 设置操作信息：使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
		-- 设置操作信息：将手牌发动的陷阱卡送回手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,1,0,0)
	end
end
-- 效果处理：使发动无效，并将该卡按原本的形式放回（手牌或场上盖放）
function c6137095.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 如果成功使发动无效，且该卡在场上或手牌中与该效果关联
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		if rc:IsStatus(STATUS_ACT_FROM_HAND) then
			rc:CancelToGrave()
			-- 将从手牌发动的陷阱卡送回手牌
			Duel.SendtoHand(rc,nil,REASON_EFFECT)
		else
			if rc:IsCanTurnSet() then
				rc:CancelToGrave()
				-- 将从场上发动的陷阱卡重新里侧表示盖放
				Duel.ChangePosition(rc,POS_FACEDOWN)
				rc:SetStatus(STATUS_SET_TURN,false)
				-- 触发盖放魔陷卡的时点
				Duel.RaiseEvent(rc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
			end
		end
	end
end
