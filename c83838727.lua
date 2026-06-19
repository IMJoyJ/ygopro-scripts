--ドローパン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己墓地有怪兽存在的场合，支付200基本分才能发动。自己抽1张，给双方确认。那是怪兽的场合，再让那个属性的以下效果适用。
-- ●不在自己墓地存在的属性：自己抽1张。
-- ●自己墓地存在的属性：选自己1张手卡丢弃。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己墓地有怪兽存在的场合，支付200基本分才能发动。自己抽1张，给双方确认。那是怪兽的场合，再让那个属性的以下效果适用。●不在自己墓地存在的属性：自己抽1张。●自己墓地存在的属性：选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES_SELF+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动的条件：自己墓地有怪兽存在
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少1张怪兽卡
	return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_MONSTER)
end
-- 定义效果发动的代价：支付200基本分
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否能够支付200基本分
	if chk==0 then return Duel.CheckLPCost(tp,200) end
	-- 让发动效果的玩家支付200基本分
	Duel.PayLPCost(tp,200)
end
-- 定义效果发动的目标与操作信息：检查是否能抽卡，并设置抽卡操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家当前是否可以效果抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的目标玩家设置为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为1（代表抽1张卡）
	Duel.SetTargetParam(1)
	-- 向系统宣告此效果包含抽卡操作，预计让玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义效果处理的函数：执行抽卡、确认，并根据抽到怪兽的属性适用后续效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果抽卡，并检查是否成功抽到了卡
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 获取刚才因抽卡操作而加入手牌的卡片组
		local g=Duel.GetOperatedGroup()
		local tc=g:GetFirst()
		-- 将抽到的卡展示给对方玩家确认
		Duel.ConfirmCards(1-p,tc)
		if not tc:IsType(TYPE_MONSTER) then
			-- 洗切玩家的手牌
			Duel.ShuffleHand(p)
			return
		end
		-- 中断当前效果处理，使后续的效果适用与之前的抽卡不视为同时处理
		Duel.BreakEffect()
		-- 检查自己墓地是否存在与抽到的怪兽相同属性的怪兽
		if Duel.IsExistingMatchingCard(Card.IsAttribute,p,LOCATION_GRAVE,0,1,nil,tc:GetAttribute()) then
			-- 获取玩家手牌中所有可以因效果丢弃的卡片组
			local sg=Duel.GetMatchingGroup(Card.IsDiscardable,p,LOCATION_HAND,0,nil,REASON_EFFECT+REASON_DISCARD)
			-- 向玩家发送提示信息，要求选择要丢弃的手牌
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			local dg=sg:Select(p,1,1,nil)
			-- 洗切玩家的手牌
			Duel.ShuffleHand(p)
			-- 将选中的手牌送去墓地（视为因效果丢弃）
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		else
			-- 执行效果抽卡，让玩家再抽1张卡
			Duel.Draw(p,1,REASON_EFFECT)
		end
		-- 洗切玩家的手牌
		Duel.ShuffleHand(p)
	end
end
