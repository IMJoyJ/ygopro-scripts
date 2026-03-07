--アクションマジック－ダブル・バンキング
-- 效果：
-- ①：丢弃1张手卡才能发动。自己场上的怪兽在这个回合战斗破坏对方怪兽的场合，只再1次可以继续攻击。
-- ②：这张卡在墓地存在的场合，自己主要阶段从手卡丢弃1张魔法卡才能发动。这张卡在自己的魔法与陷阱区域盖放。这个效果在这张卡送去墓地的回合不能发动。
function c35498188.initial_effect(c)
	-- 效果原文内容：①：丢弃1张手卡才能发动。自己场上的怪兽在这个回合战斗破坏对方怪兽的场合，只再1次可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 判断当前是否处于可以进行战斗相关操作的时点或阶段
	e1:SetCondition(aux.bpcon)
	e1:SetCost(c35498188.cost)
	e1:SetTarget(c35498188.target)
	e1:SetOperation(c35498188.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡在墓地存在的场合，自己主要阶段从手卡丢弃1张魔法卡才能发动。这张卡在自己的魔法与陷阱区域盖放。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35498188,0))  --"这张卡盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 判断这张卡是否在墓地且当前回合未发动过此效果
	e2:SetCondition(aux.exccon)
	e2:SetCost(c35498188.setcost)
	e2:SetTarget(c35498188.settg)
	e2:SetOperation(c35498188.setop)
	c:RegisterEffect(e2)
end
-- 检查玩家手牌中是否存在可丢弃的卡片并执行丢弃操作
function c35498188.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从玩家手牌中丢弃1张可丢弃的卡片作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检查玩家场上是否存在表侧表示的怪兽
function c35498188.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
-- 为场上所有表侧表示的怪兽注册战斗破坏时可继续攻击的效果
function c35498188.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为怪兽注册战斗破坏时可继续攻击的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetCondition(c35498188.atkcon)
		e1:SetOperation(c35498188.atkop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 判断该怪兽是否在战斗中被破坏且可以进行连锁攻击
function c35498188.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该怪兽是否在战斗中被破坏且可以进行连锁攻击
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
end
-- 询问玩家是否继续攻击并执行连锁攻击
function c35498188.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 询问玩家是否继续攻击
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(35498188,1)) then  --"是否继续攻击？"
		-- 使攻击卡可以再进行1次攻击
		Duel.ChainAttack()
	end
end
-- 过滤函数，用于判断卡片是否为魔法卡且可丢弃
function c35498188.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 检查玩家手牌中是否存在可丢弃的魔法卡并执行丢弃操作
function c35498188.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在可丢弃的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c35498188.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从玩家手牌中丢弃1张可丢弃的魔法卡作为发动代价
	Duel.DiscardHand(tp,c35498188.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 检查该卡是否可以盖放
function c35498188.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置连锁操作信息，表示将此卡从墓地盖放
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 执行将此卡盖放的操作
function c35498188.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡盖放在玩家的魔法与陷阱区域
		Duel.SSet(tp,c)
	end
end
