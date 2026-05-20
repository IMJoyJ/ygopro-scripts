--超魔導騎士－ブラック・キャバルリー
-- 效果：
-- 「黑魔术师」＋战士族怪兽
-- ①：这张卡的攻击力上升双方的场上·墓地的魔法·陷阱卡数量×100。
-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：场上的卡为对象的魔法·陷阱·怪兽的效果发动时，丢弃1张手卡才能发动。那个发动无效并破坏。
function c73452089.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，素材为「黑魔术师」和1只战士族怪兽
	aux.AddFusionProcCodeFun(c,46986414,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),1,true,true)
	-- ①：这张卡的攻击力上升双方的场上·墓地的魔法·陷阱卡数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c73452089.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- ③：场上的卡为对象的魔法·陷阱·怪兽的效果发动时，丢弃1张手卡才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(73452089,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c73452089.discon)
	e3:SetCost(c73452089.discost)
	e3:SetTarget(c73452089.distg)
	e3:SetOperation(c73452089.disop)
	c:RegisterEffect(e3)
end
-- 计算攻击力上升值的函数
function c73452089.atkval(e,c)
	-- 获取双方场上及墓地的魔法、陷阱卡数量并乘以100
	return Duel.GetMatchingGroupCount(Card.IsType,0,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil,TYPE_SPELL+TYPE_TRAP)*100
end
-- 效果③的发动条件判断函数
function c73452089.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取触发连锁的效果的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断对象卡片中是否存在场上的卡，且该效果的发动可以被无效
	return tg and tg:IsExists(Card.IsOnField,1,nil) and Duel.IsChainNegatable(ev)
end
-- 效果③的发动代价处理函数
function c73452089.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认手卡中是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 效果③的发动目标处理函数
function c73452089.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明该效果包含使发动无效的操作
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若该卡可被破坏且仍与效果关联，则设置操作信息，表明该效果包含破坏的操作
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果③的效果处理函数
function c73452089.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且该卡在效果处理时仍与该效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动被无效的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
