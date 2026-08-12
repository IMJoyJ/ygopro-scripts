--叛逆の帝王
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡才能发动。攻击力是2400以上或800而守备力是1000的卡组3只怪兽给对方观看，对方从那之中选1只。那1只怪兽加入自己手卡，剩余送去墓地。这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从手卡把1只攻击力800/守备力1000的怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（卡组检索/送墓）和②效果（墓地除外手卡特召）。
function s.initial_effect(c)
	-- ①：丢弃1张手卡才能发动。攻击力是2400以上或800而守备力是1000的卡组3只怪兽给对方观看，对方从那之中选1只。那1只怪兽加入自己手卡，剩余送去墓地。这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从手卡把1只攻击力800/守备力1000的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价（Cost）处理函数：丢弃1张手卡。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手卡作为发动代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中攻击力是2400以上或800且守备力是1000的怪兽，且该怪兽能加入手卡并能送去墓地。
function s.filter(c)
	return (c:IsAttackAbove(2400) or c:IsAttack(800)) and c:IsDefense(1000) and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand() and c:IsAbleToGrave()
end
-- ①效果的发动准备（Target）函数：检查卡组中是否存在3只满足条件的怪兽，并设置检索和送墓的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少3张满足条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置连锁的操作信息为：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置连锁的操作信息为：从卡组将卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的效果处理（Operation）函数：从卡组选3只怪兽给对方观看并由对方选1只加入手卡，其余送墓，并适用不能从额外卡组特召的限制。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件的怪兽。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 提示自己选择要给对方确认的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 将选出的3只怪兽给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
		-- 提示对方玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tc=sg:Select(1-tp,1,1,nil):GetFirst()
		-- 将对方选中的那1只怪兽加入自己手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 再次向对方确认加入手卡的卡片（确保规则合规性）。
		Duel.ConfirmCards(1-tp,tc)
		sg:RemoveCard(tc)
		-- 将剩余的2只怪兽送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。/②：把墓地的这张卡除外才能发动。从手卡把1只攻击力800/守备力1000的怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册不能从额外卡组特殊召唤怪兽的玩家限制效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制特殊召唤的怪兽来源为额外卡组。
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 过滤手卡中攻击力800且守备力1000且可以特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsAttack(800) and c:IsDefense(1000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备（Target）函数：检查怪兽区域是否有空位，以及手卡中是否存在满足特召条件的怪兽，并设置特召的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手卡中是否存在至少1只满足特召条件的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁的操作信息为：从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果的效果处理（Operation）函数：从手卡将1只攻击力800/守备力1000的怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域是否已无空位，若无则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示自己选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足特召条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
