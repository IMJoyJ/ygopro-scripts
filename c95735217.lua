--古代の機械巨人－アルティメット・パウンド
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ②：1回合最多2次，这张卡的攻击破坏怪兽时，从手卡丢弃1只机械族怪兽才能发动。这张卡可以继续攻击。
-- ③：场上的这张卡被战斗·效果破坏的场合才能发动。从卡组把1张「融合」加入手卡，从自己墓地把1只其他的「古代的机械」怪兽加入手卡。
function c95735217.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- ②：1回合最多2次，这张卡的攻击破坏怪兽时，从手卡丢弃1只机械族怪兽才能发动。这张卡可以继续攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(95735217,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(2)
	e3:SetCondition(c95735217.atcon)
	e3:SetCost(c95735217.atcost)
	e3:SetOperation(c95735217.atop)
	c:RegisterEffect(e3)
	-- ③：场上的这张卡被战斗·效果破坏的场合才能发动。从卡组把1张「融合」加入手卡，从自己墓地把1只其他的「古代的机械」怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(95735217,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c95735217.thcon)
	e4:SetTarget(c95735217.thtg)
	e4:SetOperation(c95735217.thop)
	c:RegisterEffect(e4)
end
-- 攻击破坏怪兽时发动追加攻击效果的条件判断
function c95735217.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 必须是自身攻击且在战斗中破坏了怪兽
	return Duel.GetAttacker()==e:GetHandler() and aux.bdcon(e,tp,eg,ep,ev,re,r,rp)
		and e:GetHandler():IsChainAttackable(0)
end
-- 过滤手牌中可丢弃的机械族怪兽
function c95735217.costfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsDiscardable()
end
-- 追加攻击效果的发动代价处理
function c95735217.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1只可丢弃的机械族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c95735217.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌丢弃1只机械族怪兽作为发动代价
	Duel.DiscardHand(tp,c95735217.costfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 追加攻击效果的处理
function c95735217.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使这张卡可以继续攻击
	Duel.ChainAttack()
end
-- 场上的这张卡被战斗或效果破坏的条件判断
function c95735217.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中可加入手牌的「融合」
function c95735217.thfilter1(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 过滤自己墓地中可加入手牌的其他「古代的机械」怪兽
function c95735217.thfilter2(c)
	return c:IsSetCard(0x7) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索「融合」并回收墓地「古代的机械」怪兽效果的目标检查与操作信息设置
function c95735217.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c95735217.thfilter1,tp,LOCATION_DECK,0,1,nil)
		-- 并且检查自己墓地中是否存在除自身以外的可回收的「古代的机械」怪兽
		and Duel.IsExistingMatchingCard(c95735217.thfilter2,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 设置操作信息：将2张卡从卡组和墓地加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
	-- 设置操作信息：有1张卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
-- 检索「融合」并回收墓地「古代的机械」怪兽效果的具体处理
function c95735217.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「融合」
	local g1=Duel.SelectMatchingCard(tp,c95735217.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g1:GetCount()>0 then
		-- 将选中的「融合」加入手牌
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的「融合」
		Duel.ConfirmCards(1-tp,g1)
		-- 再次提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从自己墓地选择1只其他的「古代的机械」怪兽
		local g2=Duel.SelectMatchingCard(tp,c95735217.thfilter2,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
		if g2:GetCount()>0 then
			-- 显式展示选中的墓地怪兽
			Duel.HintSelection(g2)
			-- 将选中的「古代的机械」怪兽加入手牌
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
		end
	end
end
