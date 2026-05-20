--ダイノルフィア・インタクト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「恐啡肽狂龙」卡存在，怪兽的效果发动时，把基本分支付一半才能发动。那个发动无效并破坏。这个回合，自己受到的战斗伤害变成那个时候的自己基本分一半的数值。
-- ②：自己基本分是2000以下，自己要受到战斗伤害的伤害计算时，把墓地的这张卡除外才能发动。那次战斗发生的对自己的战斗伤害变成0。
function c7336745.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「恐啡肽狂龙」卡存在，怪兽的效果发动时，把基本分支付一半才能发动。那个发动无效并破坏。这个回合，自己受到的战斗伤害变成那个时候的自己基本分一半的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,7336745+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c7336745.condition)
	e1:SetCost(c7336745.cost)
	e1:SetTarget(c7336745.target)
	e1:SetOperation(c7336745.activate)
	c:RegisterEffect(e1)
	-- ②：自己基本分是2000以下，自己要受到战斗伤害的伤害计算时，把墓地的这张卡除外才能发动。那次战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c7336745.damcon)
	-- 把墓地的这张卡除外作为发动代价。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c7336745.damop)
	c:RegisterEffect(e2)
end
-- 检查①效果的发动条件：怪兽效果发动时，自己场上有「恐啡肽狂龙」卡存在，且该发动可以被无效。
function c7336745.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁的发动是否为怪兽效果，且该发动是否可以被无效。
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在表侧表示的「恐啡肽狂龙」卡。
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_ONFIELD,0,1,nil,0x173)
end
-- 支付一半基本分作为①效果的发动代价。
function c7336745.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 玩家支付当前基本分一半的数值（向下取整）。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 设置①效果处理的分类为“无效发动”和“破坏”。
function c7336745.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：如果该卡可以被破坏且仍存在于关联状态，则将其破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行①效果处理：使发动无效并破坏，并注册一个本回合内改变自己受到的战斗伤害的全局效果。
function c7336745.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使发动无效，且该卡在场上/关联状态。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
	-- 这个回合，自己受到的战斗伤害变成那个时候的自己基本分一半的数值。②：自己基本分是2000以下，自己要受到战斗伤害的伤害计算时，把墓地的这张卡除外才能发动。那次战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c7336745.val)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内改变玩家受到的战斗伤害的全局效果。
	Duel.RegisterEffect(e1,tp)
end
-- 计算并返回当前基本分一半的数值（向上取整）作为受到的战斗伤害。
function c7336745.val(e,re,val,r,rp,rc)
	-- 获取当前玩家的生命值。
	local lp=Duel.GetLP(e:GetHandlerPlayer())
	return math.ceil(lp/2)
end
-- 检查②效果的发动条件：自己基本分在2000以下，且要受到战斗伤害。
function c7336745.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己基本分是否在2000以下，且本次战斗中自己受到的战斗伤害是否大于0。
	return Duel.GetLP(tp)<=2000 and Duel.GetBattleDamage(tp)>0
end
-- 执行②效果处理：使本次战斗发生的对自己的战斗伤害变成0。
function c7336745.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 那次战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册使本次战斗伤害变成0的全局效果。
	Duel.RegisterEffect(e1,tp)
end
