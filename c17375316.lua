--押収
-- 效果：
-- 支付1000基本分发动。把对方手卡确认，从那之中选1张卡丢弃。
function c17375316.initial_effect(c)
	-- 创建效果，设置为魔法卡发动效果，具有支付LP费用、选择对象、处理手牌丢弃的效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c17375316.cost)
	e1:SetTarget(c17375316.target)
	e1:SetOperation(c17375316.activate)
	c:RegisterEffect(e1)
end
-- 支付1000基本分发动
function c17375316.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 确认对方手卡并选择1张丢弃
function c17375316.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置当前效果的目标玩家为发动者
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作信息为丢弃对方1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
-- 处理效果发动后的实际操作
function c17375316.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取目标玩家的手牌组
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 确认目标玩家的手牌
		Duel.ConfirmCards(p,g)
		-- 提示目标玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		local sg=g:Select(p,1,1,nil)
		-- 将选中的手牌送入墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
		-- 将对方手牌洗牌
		Duel.ShuffleHand(1-p)
	end
end
