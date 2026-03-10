--Gゴーレム・ディグニファイド・トリリトン
-- 效果：
-- 地属性怪兽2只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：可以攻击的对方怪兽必须向这张卡作出攻击。
-- ②：这张卡和对方怪兽进行战斗的伤害计算前1次，从手卡把1只地属性怪兽送去墓地才能发动。那只对方怪兽直到回合结束时攻击力下降200，效果无效化。
-- ③：自己场上的连接怪兽为对象的效果由对方发动时才能发动。那个效果无效并破坏。
function c50546029.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2个地属性怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_EARTH),2)
	c:EnableReviveLimit()
	-- 可以攻击的对方怪兽必须向这张卡作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e2:SetValue(c50546029.atklimit)
	c:RegisterEffect(e2)
	-- 这张卡和对方怪兽进行战斗的伤害计算前1次，从手卡把1只地属性怪兽送去墓地才能发动。那只对方怪兽直到回合结束时攻击力下降200，效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(50546029,0))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetCondition(c50546029.atkcon)
	e3:SetCost(c50546029.atkcost)
	e3:SetOperation(c50546029.atkop)
	c:RegisterEffect(e3)
	-- 自己场上的连接怪兽为对象的效果由对方发动时才能发动。那个效果无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(50546029,1))
	e4:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,50546029)
	e4:SetCondition(c50546029.discon)
	e4:SetTarget(c50546029.distg)
	e4:SetOperation(c50546029.disop)
	c:RegisterEffect(e4)
end
-- 设置必须攻击的条件，只有当前卡本身才能被指定为攻击目标
function c50546029.atklimit(e,c)
	return c==e:GetHandler()
end
-- 判断是否满足攻击条件，即自身和对方怪兽都处于战斗状态且对方怪兽是对方控制
function c50546029.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle() and bc:IsControler(1-tp)
end
-- 定义用于支付代价的过滤函数，筛选手牌中可送入墓地的地属性怪兽
function c50546029.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToGraveAsCost()
end
-- 发动效果时检查是否有满足条件的地属性怪兽并将其丢弃作为代价
function c50546029.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即手牌中存在至少1张符合条件的地属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c50546029.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中丢弃1张符合条件的地属性怪兽作为发动代价
	Duel.DiscardHand(tp,c50546029.cfilter,1,1,REASON_COST)
end
-- 处理攻击效果，使对方怪兽攻击力下降200并使其效果无效
function c50546029.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsFaceup() and bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 使与该怪兽相关的连锁无效化
		Duel.NegateRelatedChain(bc,RESET_TURN_SET)
		-- 使对方怪兽的攻击力下降200
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		bc:RegisterEffect(e1)
		-- 使对方怪兽的效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		bc:RegisterEffect(e2)
		-- 使对方怪兽的效果在回合结束时被无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetValue(RESET_TURN_SET)
		bc:RegisterEffect(e3)
	end
end
-- 定义用于判断目标卡片是否为己方场上的连接怪兽的过滤函数
function c50546029.acfilter(c,tp)
	return c:IsType(TYPE_LINK) and c:IsControler(tp) and c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
-- 判断是否满足发动条件，即对方发动了针对己方连接怪兽的效果
function c50546029.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的目标卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return rp==1-tp and tg and tg:IsExists(c50546029.acfilter,1,nil,tp)
end
-- 设置连锁操作信息，包括使效果无效和破坏目标
function c50546029.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息为破坏目标
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 处理连锁无效化与破坏效果，先使效果无效再破坏目标
function c50546029.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使效果无效且目标卡存在并关联到该效果
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
