--No.104 仮面魔踏士シャイニング
-- 效果：
-- 4星怪兽×3
-- ①：1回合1次，自己主要阶段才能发动。对方卡组最上面的卡送去墓地。
-- ②：自己·对方的战斗阶段对方把怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效，给与对方800伤害。
function c2061963.initial_effect(c)
	-- 为这张卡添加XYZ召唤规则：用任意3只4星怪兽叠放来XYZ召唤（不限定素材种类）。
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
-- 将这张卡的卡号映射为No.104，使No.系列相关的规则与效果能正确识别这张卡。
aux.xyz_number[2061963]=104
-- ②效果的发动条件：这张卡未被战斗破坏、当前处于战斗阶段、对方发动了怪兽效果且该连锁效果可以被无效化。
function c2061963.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断是否处于战斗阶段。
	local ph=Duel.GetCurrentPhase()
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp
		-- 判断当前处于主要阶段1之后、主要阶段2之前的战斗阶段，且对方发动的是怪兽效果，并且该连锁可以被无效化。
		and (ph>PHASE_MAIN1 and ph<PHASE_MAIN2) and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- ②效果发动代价：取除这张卡的1个超量素材；chk==0时仅检查是否有素材可取，否则实际取除。
function c2061963.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果发动时无对象，仅设定操作信息：声明无效对象为对方发动的那个效果（eg），并对对方造成800伤害。
function c2061963.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定操作信息，声明本次连锁会使eg对应的那个效果发动无效，用于相关规则检测。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设定操作信息，声明会对对方玩家造成800点伤害，用于相关规则检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- ②效果处理：尝试无效对方发动的效果；无效成功后才给与对方800点伤害。
function c2061963.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.NegateActivation(ev)无效当前连锁ev，判断无效是否成功。
	if Duel.NegateActivation(ev) then
		-- 给与对方玩家（1-tp）800点效果伤害。
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
-- ①效果的发动条件与设定：检查对方能否从卡组顶把1张卡送去墓地，并记录对象玩家与数量。
function c2061963.decktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：对方玩家是否可以从卡组顶端将1张卡送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,1) end
	-- 将当前连锁的对象玩家设为对方玩家（1-tp），即卡组要被送墓的玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设为1，表示需要从卡组顶送去墓地的卡数为1张。
	Duel.SetTargetParam(1)
	-- 设定操作信息，声明将对方卡组顶端1张卡送去墓地，用于相关规则检测。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,1)
end
-- ①效果处理：从连锁信息中取出之前设定的对象玩家和卡数，执行从卡组顶送墓。
function c2061963.deckop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家（对方）和对象参数（要送墓的卡数1）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因将对象玩家卡组顶端的d张卡送去墓地。
	Duel.DiscardDeck(p,d,REASON_EFFECT)
end
