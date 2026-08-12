--ガガガの脱出劇
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「我我我」怪兽存在，对方把怪兽的效果发动时才能发动。那个发动无效。那之后，以下效果可以适用。
-- ●选自己1张手卡丢弃，从卡组把1只「我我我」怪兽特殊召唤。
-- ②：把墓地的这张卡除外才能发动。自己场上的「我我我」怪兽全部变成守备表示，这个回合中，自己场上的「我我我」怪兽不会被战斗·效果破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（发动无效并可选特召）和②效果（墓地除外变守备表示并赋予破坏抗性）的注册。
function s.initial_effect(c)
	-- ①：自己场上有「我我我」怪兽存在，对方把怪兽的效果发动时才能发动。那个发动无效。那之后，以下效果可以适用。●选自己1张手卡丢弃，从卡组把1只「我我我」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_HANDES_SELF+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己场上的「我我我」怪兽全部变成守备表示，这个回合中，自己场上的「我我我」怪兽不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「我我我」怪兽。
function s.cfilter(c)
	return c:IsSetCard(0x54) and c:IsFaceup()
end
-- ①效果的发动条件：自己场上有「我我我」怪兽存在，且对方发动了可以被无效的怪兽效果。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「我我我」怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查发动的效果是否为怪兽效果、该发动是否可以被无效，且发动者为对方。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and rp==1-tp
end
-- ①效果的靶向/发动准备函数，设置无效发动的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 过滤条件：卡组中可以特殊召唤的「我我我」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x54) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理函数：使发动无效，并可选择丢弃1张手卡来从卡组特殊召唤1只「我我我」怪兽。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使对方的效果发动无效。
	if Duel.NegateActivation(ev) then
		-- 获取自己手卡中可以因效果丢弃的卡片组。
		local sg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil,REASON_EFFECT+REASON_DISCARD)
		if sg:GetCount()>0
			-- 且自己场上有可用的怪兽区域。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 且卡组中存在可以特殊召唤的「我我我」怪兽。
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 且玩家选择适用后续效果（丢弃手卡并特殊召唤）。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续的丢弃手卡和特殊召唤不与无效发动视为同时处理。
			Duel.BreakEffect()
			-- 提示玩家选择要丢弃的手卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			local dg=sg:Select(tp,1,1,nil)
			-- 洗切玩家的手卡。
			Duel.ShuffleHand(tp)
			-- 将选中的手卡因效果丢弃送去墓地。
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
			-- 提示玩家选择要特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从卡组中选择1只满足条件的「我我我」怪兽。
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 过滤条件：自己场上表侧攻击表示、且可以改变表示形式的「我我我」怪兽。
function s.posfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsSetCard(0x54) and c:IsCanChangePosition()
end
-- ②效果的靶向/发动准备函数，检查是否存在可改变表示形式的「我我我」怪兽并设置操作信息。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧攻击表示且可改变表示形式的「我我我」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上所有表侧攻击表示且可改变表示形式的「我我我」怪兽。
	local g=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置操作信息：改变这些怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- ②效果的处理函数：将自己场上的「我我我」怪兽全部变成守备表示，并赋予本回合不会被战斗·效果破坏的抗性。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前场上所有符合条件的「我我我」怪兽。
	local g=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,0,nil)
	-- 将这些怪兽全部变成守备表示，如果成功改变了至少1只怪兽的表示形式。
	if Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,0,0)>0 then
		-- 这个回合中，自己场上的「我我我」怪兽不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.etarget)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册战斗破坏抗性的效果。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		-- 注册效果破坏抗性的效果。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 破坏抗性的适用对象过滤：自己场上表侧表示的「我我我」怪兽。
function s.etarget(e,c)
	return c:IsFaceup() and c:IsSetCard(0x54)
end
