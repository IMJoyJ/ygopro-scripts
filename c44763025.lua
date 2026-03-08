--いたずら好きな双子悪魔
-- 效果：
-- 支付1000基本分发动。对方随机把1张手卡丢弃，再选1张手卡丢弃。
function c44763025.initial_effect(c)
	-- 创建效果，设置为发动时支付1000基本分，对方随机丢弃1张手卡，再选择1张手卡丢弃
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c44763025.cost)
	e1:SetTarget(c44763025.target)
	e1:SetOperation(c44763025.activate)
	c:RegisterEffect(e1)
end
-- 支付1000基本分
function c44763025.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 设置连锁目标玩家和操作信息
function c44763025.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否有手牌
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置当前连锁的目标玩家为发动者
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息为对方丢弃2张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,2)
end
-- 处理效果发动，执行丢弃手牌操作
function c44763025.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取目标玩家的手牌组
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	if g:GetCount()>0 then
		local sg=g:RandomSelect(p,1)
		-- 将选中的手牌送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
		g:RemoveCard(sg:GetFirst())
		if g:GetCount()>0 then
			-- 提示对方选择要丢弃的手牌
			Duel.Hint(HINT_SELECTMSG,1-p,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			sg=g:Select(1-p,1,1,nil)
			-- 将选中的手牌送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
