--王の棺
-- 效果：
-- 这个卡名的②的效果1回合可以使用最多4次。
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「荷鲁斯」怪兽不会被不以自身为对象的卡的效果破坏。
-- ②：把1张手卡送去墓地才能发动。从卡组把1只「荷鲁斯」怪兽送去墓地。
-- ③：1回合1次，自己的「荷鲁斯」怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽送去墓地。
function c16528181.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「荷鲁斯」怪兽不会被不以自身为对象的卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetValue(c16528181.efilter)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c16528181.intg)
	c:RegisterEffect(e1)
	-- ②：把1张手卡送去墓地才能发动。从卡组把1只「荷鲁斯」怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(4,16528181)
	e2:SetCost(c16528181.cost)
	e2:SetTarget(c16528181.target)
	e2:SetOperation(c16528181.activate)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己的「荷鲁斯」怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16528181,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c16528181.descon)
	e3:SetTarget(c16528181.destg)
	e3:SetOperation(c16528181.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示的「荷鲁斯」怪兽
function c16528181.intg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x19d)
end
-- 效果过滤函数，用于判断当前连锁效果是否对目标怪兽生效
function c16528181.efilter(e,re,rp,c)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(c)
end
-- ②效果的发动费用，丢弃1张手卡
function c16528181.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足②效果发动的费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行②效果的费用处理，丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 过滤函数，用于筛选卡组中可送去墓地的「荷鲁斯」怪兽
function c16528181.filter(c)
	return c:IsSetCard(0x19d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ②效果的发动宣言，检索满足条件的「荷鲁斯」怪兽
function c16528181.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足②效果发动的检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c16528181.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置②效果的处理信息，确定将要处理的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数，选择并把1只「荷鲁斯」怪兽送去墓地
function c16528181.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「荷鲁斯」怪兽
	local g=Duel.SelectMatchingCard(tp,c16528181.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「荷鲁斯」怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ③效果的发动条件，判断是否满足发动条件
function c16528181.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在战斗的怪兽
	local ac=Duel.GetBattleMonster(tp)
	if not (ac and ac:IsFaceup() and ac:IsSetCard(0x19d)) then return false end
	local bc=ac:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsControler(1-tp) and bc:IsRelateToBattle()
end
-- ③效果的发动宣言，设置处理信息
function c16528181.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc end
	-- 设置③效果的处理信息，确定将要处理的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,bc,1,0,0)
end
-- ③效果的处理函数，将对方怪兽送去墓地
function c16528181.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc and bc:IsControler(1-tp) and bc:IsRelateToBattle() then
		-- 将对方怪兽送去墓地
		Duel.SendtoGrave(bc,REASON_EFFECT)
	end
end
