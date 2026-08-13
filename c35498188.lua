--アクションマジック－ダブル・バンキング
-- 效果：
-- ①：丢弃1张手卡才能发动。自己场上的怪兽在这个回合战斗破坏对方怪兽的场合，只再1次可以继续攻击。
-- ②：这张卡在墓地存在的场合，自己主要阶段从手卡丢弃1张魔法卡才能发动。这张卡在自己的魔法与陷阱区域盖放。这个效果在这张卡送去墓地的回合不能发动。
function c35498188.initial_effect(c)
	-- ①：丢弃1张手卡才能发动。自己场上的怪兽在这个回合战斗破坏对方怪兽的场合，只再1次可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 设置效果①的发动条件为当前处于主要阶段或战斗阶段（aux.bpcon），限定该效果只能在可进入战斗阶段或正处于战斗阶段时发动。
	e1:SetCondition(aux.bpcon)
	e1:SetCost(c35498188.cost)
	e1:SetTarget(c35498188.target)
	e1:SetOperation(c35498188.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，自己主要阶段从手卡丢弃1张魔法卡才能发动。这张卡在自己的魔法与陷阱区域盖放。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35498188,0))  --"这张卡盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置效果②的发动条件为“这张卡送去墓地的回合不能发动”（aux.exccon），即本回合刚被送去墓地时不能发动该效果。
	e2:SetCondition(aux.exccon)
	e2:SetCost(c35498188.setcost)
	e2:SetTarget(c35498188.settg)
	e2:SetOperation(c35498188.setop)
	c:RegisterEffect(e2)
end
-- 效果①的代价函数：丢弃1张手卡才能发动，若满足条件则执行丢弃1张手卡的代价。
function c35498188.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己的手卡中是否存在1张可以被丢弃的手卡（除去这张卡自身），作为代价检测。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际从手卡丢弃1张手卡作为发动代价，丢弃原因同时为COST和DISCARD。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果①的发动目标确认：自己场上存在表侧表示怪兽即可发动，不取对象。
function c35498188.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己场上有至少1只表侧表示怪兽，满足发动前提。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果①处理时，获取自己场上全部表侧表示怪兽，为每只怪兽分别注册一个“战斗破坏对方怪兽时可追加攻击”的持续效果，持续到回合结束。
function c35498188.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示怪兽的集合，用于逐一赋予追加攻击效果。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的怪兽在这个回合战斗破坏对方怪兽的场合，只再1次可以继续攻击。
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
-- 追加攻击效果的触发条件：该怪兽与对方怪兽战斗并战斗破坏对方怪兽，且该怪兽仍可进行追加攻击。
function c35498188.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定条件由两部分组成：一是怪兽确实与对方怪兽战斗并破坏了对方怪兽（aux.bdocon），二是该怪兽当前还能继续攻击（IsChainAttackable）。
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
end
-- 追加攻击效果的处理：询问玩家是否让该怪兽继续攻击，选择是则执行再次攻击。
function c35498188.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出让玩家选择是否继续攻击的确认框，使用卡片规定的提示文本。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(35498188,1)) then  --"是否继续攻击？"
		-- 使当前触发效果的怪兽获得一次额外的攻击机会，执行追加攻击。
		Duel.ChainAttack()
	end
end
-- 效果②的代价过滤条件：手卡中的1张魔法卡且可以被丢弃。
function c35498188.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 效果②的代价函数：从手卡丢弃1张魔法卡才能发动，若满足条件则执行丢弃代价。
function c35498188.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认手卡中是否存在1张魔法卡且可以被丢弃，作为代价检测。
	if chk==0 then return Duel.IsExistingMatchingCard(c35498188.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际从手卡丢弃1张魔法卡作为发动代价，丢弃原因同时为COST和DISCARD。
	Duel.DiscardHand(tp,c35498188.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果②的发动目标确认：这张卡在墓地且可以盖放到魔法与陷阱区域，并设置操作信息表示这张卡将离开墓地。
function c35498188.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息为CATEGORY_LEAVE_GRAVE，用于连锁检测涉及墓地离场的效果（如王家长眠之谷等）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②处理时，若这张卡仍与效果相关（未被移走），则将其盖放到自己的魔法与陷阱区域。
function c35498188.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以里侧表示盖放到自己的魔法与陷阱区域。
		Duel.SSet(tp,c)
	end
end
