--No.104 仮面魔踏士シャイニング
-- 效果：
-- 4星怪兽×3
-- ①：1回合1次，自己主要阶段才能发动。对方卡组最上面的卡送去墓地。
-- ②：自己·对方的战斗阶段对方把怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效，给与对方800伤害。
function c2061963.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为4的怪兽进行3只叠放
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- ②：自己·对方的战斗阶段对方把怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效，给与对方800伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2061963,0))  --"效果无效"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c2061963.condition)
	e1:SetCost(c2061963.cost)
	e1:SetTarget(c2061963.target)
	e1:SetOperation(c2061963.operation)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。对方卡组最上面的卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2061963,1))  --"卡组破坏"
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c2061963.decktg)
	e2:SetOperation(c2061963.deckop)
	c:RegisterEffect(e2)
end
-- 设置该卡的XYZ编号为104
aux.xyz_number[2061963]=104
-- 效果发动时的条件判断，确保不是在战斗破坏后发动、对方发动、不在主要阶段1到2之间、对方发动的是怪兽类型且该连锁可以被无效
function c2061963.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp
		-- 判断当前阶段是否在主要阶段1之后、主要阶段2之前，且对方发动的是怪兽类型，且该连锁可以被无效
		and (ph>PHASE_MAIN1 and ph<PHASE_MAIN2) and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 支付效果的代价，移除1个超量素材
function c2061963.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果处理时的操作信息，包括使连锁无效和对对方造成800伤害
function c2061963.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置对对方造成800伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 执行效果操作，使连锁无效并造成伤害
function c2061963.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使连锁无效
	if Duel.NegateActivation(ev) then
		-- 对对方造成800伤害
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
-- 设置卡组破坏效果的目标和操作信息
function c2061963.decktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方是否可以将卡组最上面的1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,1) end
	-- 设置连锁的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁的目标参数为1
	Duel.SetTargetParam(1)
	-- 设置操作信息为卡组破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,1)
end
-- 执行卡组破坏效果，将对方卡组最上面的卡送去墓地
function c2061963.deckop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 将指定玩家卡组最上面的指定数量卡送去墓地
	Duel.DiscardDeck(p,d,REASON_EFFECT)
end
