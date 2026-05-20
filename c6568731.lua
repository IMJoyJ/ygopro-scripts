--極氷獣アイスバーグ・ナーワル
-- 效果：
-- 调整＋调整以外的水属性怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：每次自己场上的其他怪兽被对方怪兽的攻击或者对方的效果破坏发动。给与对方600伤害。
-- ②：自己场上有其他怪兽存在，自己·对方的战斗阶段对方把魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效并破坏。
function c6568731.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的水属性怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_WATER),1)
	c:EnableReviveLimit()
	-- ①：每次自己场上的其他怪兽被对方怪兽的攻击或者对方的效果破坏发动。给与对方600伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6568731,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c6568731.condition)
	e1:SetTarget(c6568731.target)
	e1:SetOperation(c6568731.operation)
	c:RegisterEffect(e1)
	-- ②：自己场上有其他怪兽存在，自己·对方的战斗阶段对方把魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6568731,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,6568731)
	e2:SetCondition(c6568731.discon)
	e2:SetTarget(c6568731.distg)
	e2:SetOperation(c6568731.disop)
	c:RegisterEffect(e2)
end
-- 过滤自身场上因对方卡片效果或对方怪兽攻击而被破坏的怪兽
function c6568731.filter(c,tp,rp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		-- 检查破坏原因是否为对方的效果破坏，或者对方怪兽的战斗破坏
		and ((c:IsReason(REASON_EFFECT) and rp==1-tp) or (c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp)))
end
-- 检查被破坏的卡片中是否存在满足过滤条件的怪兽
function c6568731.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c6568731.filter,1,nil,tp,rp)
end
-- 效果1的发动准备，设置伤害目标玩家和伤害数值，并注册操作信息
function c6568731.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害的数值为600
	Duel.SetTargetParam(600)
	-- 设置当前连锁的操作信息为给与对方600点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,600)
end
-- 效果1的处理，获取目标玩家和伤害数值并执行伤害处理
function c6568731.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 效果2的发动条件判断，检查是否在战斗阶段、自身未被战破、对方发动效果且自己场上有其他怪兽
function c6568731.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	if not (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) then return false end
	-- 检查自身未被战斗破坏、该连锁效果可以被无效，且发动效果的玩家为对方
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainDisablable(ev) and ep==1-tp
		-- 检查自己场上是否存在除自身以外的其他怪兽
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,c)
end
-- 效果2的发动准备，设置无效和破坏的操作信息
function c6568731.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为使该发动效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置当前连锁的操作信息为破坏该发动效果的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果2的处理，尝试无效该效果，若成功则将其破坏
function c6568731.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功无效该效果，且该卡在连锁处理时仍与效果相关联
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动效果的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
