--ミスティック・パイパー
-- 效果：
-- 把这张卡解放发动。从自己卡组抽1张卡。这个效果抽到的卡给双方确认，1星怪兽的场合，自己再抽1张卡。「神秘之吹笛人」的效果1回合只能使用1次。
function c14198496.initial_effect(c)
	-- 把这张卡解放发动。从自己卡组抽1张卡。这个效果抽到的卡给双方确认，1星怪兽的场合，自己再抽1张卡。「神秘之吹笛人」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14198496,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,14198496)
	e1:SetCost(c14198496.cost)
	e1:SetTarget(c14198496.target)
	e1:SetOperation(c14198496.operation)
	c:RegisterEffect(e1)
end
-- 效果处理时的费用支付阶段
function c14198496.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果处理时的发动确认阶段
function c14198496.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的处理信息为抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理时的主要处理阶段
function c14198496.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家从卡组抽1张卡
	local ct=Duel.Draw(tp,1,REASON_EFFECT)
	if ct==0 then return end
	-- 获取刚刚抽到的卡
	local dc=Duel.GetOperatedGroup():GetFirst()
	-- 给对方确认抽到的卡
	Duel.ConfirmCards(1-tp,dc)
	if dc:IsLevel(1) then
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 让玩家再抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	-- 将玩家手卡洗牌
	Duel.ShuffleHand(tp)
end
