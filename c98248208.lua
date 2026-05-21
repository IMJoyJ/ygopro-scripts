--暗黒海龍－ドライアグル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，自己的场上·墓地·除外状态的10星怪兽是3只以上的场合才能发动。这张卡特殊召唤。
-- ②：这张卡特殊召唤的场合，把自己卡组最上面的卡送去墓地才能发动。这张卡的攻击力上升500。那之后，送去墓地的卡是怪兽的场合，给与对方1000伤害。不是的场合，可以把自己卡组最上面的卡送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（手卡特殊召唤）和②效果（特殊召唤成功时加攻及追加效果）。
function s.initial_effect(c)
	-- ①：这张卡在手卡存在，自己的场上·墓地·除外状态的10星怪兽是3只以上的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合，把自己卡组最上面的卡送去墓地才能发动。这张卡的攻击力上升500。那之后，送去墓地的卡是怪兽的场合，给与对方1000伤害。不是的场合，可以把自己卡组最上面的卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地发动"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id+o)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示、墓地或除外状态的10星怪兽。
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsLevel(10)
end
-- ①效果的发动条件：检查自己的场上、墓地、除外状态是否存在3只以上的10星怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的场上、墓地、除外状态是否存在至少3张满足过滤条件（10星）的卡。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
end
-- ①效果的发动准备：检查怪兽区域是否有空位、自身是否能特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身是否可以特殊召唤到自己的主要怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示此效果会特殊召唤1张卡（自身）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：将自身特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到发动效果的玩家场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动代价：将卡组最上面的卡送去墓地，并根据送去墓地的卡是否为怪兽卡来设置标记（Label）。
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能将卡组最上面的1张卡作为代价送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	-- 作为发动代价，将玩家卡组最上面的1张卡送去墓地。
	Duel.DiscardDeck(tp,1,REASON_COST)
	-- 获取刚才因代价送去墓地的卡片组。
	local g=Duel.GetOperatedGroup()
	if g:GetFirst():IsType(TYPE_MONSTER) then
		e:SetLabel(100)
	else
		e:SetLabel(200)
	end
end
-- ②效果的发动准备：根据Cost送墓的卡片种类，动态调整效果分类。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:GetLabel()==100 then
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	elseif e:GetLabel()==200 then
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	end
end
-- ②效果的处理：使自身攻击力上升500，然后根据Cost送墓的卡片种类，追加给予伤害或再次送墓的处理。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			if e:GetLabel()==100 then
				-- 中断当前效果处理，使后续的伤害处理与攻击力上升不视为同时处理。
				Duel.BreakEffect()
				-- 给予对方玩家1000点效果伤害。
				Duel.Damage(1-tp,1000,REASON_EFFECT)
			-- 如果送去墓地的卡不是怪兽，且卡组有卡，则由玩家选择是否将卡组最上面的卡送去墓地。
			elseif e:GetLabel()==200 and Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡组最上面的卡送去墓地？"
				-- 中断当前效果处理，使后续的送墓处理与攻击力上升不视为同时处理。
				Duel.BreakEffect()
				-- 因效果处理将玩家卡组最上面的1张卡送去墓地。
				Duel.DiscardDeck(tp,1,REASON_EFFECT)
			end
		end
	end
end
