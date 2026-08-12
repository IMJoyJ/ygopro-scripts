--登竜華転生紋
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：作为这张卡的发动时的效果处理，从卡组选恐龙族·海龙族·幻龙族怪兽各1只，那之内的1只加入手卡，另1只除外，剩余送去墓地。这个回合，自己不是龙族·恐龙族·海龙族·幻龙族怪兽不能特殊召唤。
-- ②：自己的额外卡组有表侧的「创星龙华-光巴」存在的场合才能发动。从自己的卡组·墓地·除外状态各把1只「龙华」怪兽特殊召唤（相同种族最多1只）。
local s,id,o=GetID()
-- 初始化卡片效果，注册①效果（发动时的效果处理）和②效果（场地区起动效果）。
function s.initial_effect(c)
	-- 记录这张卡上记载着「创星龙华-光巴」的卡名。
	aux.AddCodeList(c,92487128)
	-- ①：作为这张卡的发动时的效果处理，从卡组选恐龙族·海龙族·幻龙族怪兽各1只，那之内的1只加入手卡，另1只除外，剩余送去墓地。这个回合，自己不是龙族·恐龙族·海龙族·幻龙族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己的额外卡组有表侧的「创星龙华-光巴」存在的场合才能发动。从自己的卡组·墓地·除外状态各把1只「龙华」怪兽特殊召唤（相同种族最多1只）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可以加入手卡、送去墓地或除外的恐龙族、海龙族、幻龙族怪兽。
function s.hgrfilter(c)
	return c:IsRace(RACE_DINOSAUR+RACE_SEASERPENT+RACE_WYRM)
		and (c:IsAbleToHand() or c:IsAbleToGrave() or c:IsAbleToRemove())
end
-- 检查选出的3张卡是否包含恐龙族、海龙族、幻龙族怪兽各1只，且满足后续的手卡、除外、送墓操作条件。
function s.gcheck(g,tp)
	return g:FilterCount(Card.IsRace,nil,RACE_DINOSAUR)==1
		and g:FilterCount(Card.IsRace,nil,RACE_SEASERPENT)==1
		and g:FilterCount(Card.IsRace,nil,RACE_WYRM)==1
		and g:IsExists(s.thfiter,1,nil,g)
end
-- 检查选出的卡中是否存在可以加入手卡的卡，且剩余的卡中存在可以除外的卡。
function s.thfiter(c,g)
	return c:IsAbleToHand() and g:IsExists(s.rmfiter,1,c,g,c)
end
-- 检查选出的卡中是否存在可以除外的卡，且剩余的卡中存在可以送去墓地的卡。
function s.rmfiter(c,g,tc)
	return c:IsAbleToRemove() and g:IsExists(s.tgfiter,1,Group.FromCards(c,tc))
end
-- 检查选出的卡中是否存在可以送去墓地的卡。
function s.tgfiter(c)
	return c:IsAbleToGrave()
end
-- ①效果的发动准备与合法性检测，设置检索、送墓、除外的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有符合条件的恐龙族、海龙族、幻龙族怪兽。
	local g=Duel.GetMatchingGroup(s.hgrfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:CheckSubGroup(s.gcheck,3,3,tp) end
	-- 设置连锁信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置连锁信息：从卡组将1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置连锁信息：从卡组将1张卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组选3种族怪兽各1只，分别加入手卡、除外、送去墓地，并适用特殊召唤限制。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有符合条件的恐龙族、海龙族、幻龙族怪兽。
	local g=Duel.GetMatchingGroup(s.hgrfilter,tp,LOCATION_DECK,0,nil)
	-- 提示玩家选择要处理效果的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要处理效果的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,3,3,tp)
	if sg and sg:GetCount()>2 then
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local g1=sg:FilterSelect(tp,s.thfiter,1,1,nil,sg)
		-- 提示玩家选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local g2=sg:FilterSelect(tp,s.rmfiter,1,1,g1,sg,g1:GetFirst())
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g3=sg:FilterSelect(tp,s.tgfiter,1,1,g1+g2)
		-- 将选中的第1张卡加入手牌。
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g1)
		-- 将选中的第2张卡表侧表示除外。
		Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
		-- 将选中的第3张卡送去墓地。
		Duel.SendtoGrave(g3,REASON_EFFECT)
	end
	-- 这个回合，自己不是龙族·恐龙族·海龙族·幻龙族怪兽不能特殊召唤。②：自己的额外卡组有表侧的「创星龙华-光巴」存在的场合才能发动。从自己的卡组·墓地·除外状态各把1只「龙华」怪兽特殊召唤（相同种族最多1只）。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该特殊召唤限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制玩家不能特殊召唤龙族、恐龙族、海龙族、幻龙族以外的怪兽。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_DRAGON+RACE_DINOSAUR+RACE_SEASERPENT+RACE_WYRM)
end
-- 过滤额外卡组中表侧表示的「创星龙华-光巴」。
function s.cfilter(c,e,tp)
	return c:IsCode(92487128) and c:IsFaceup()
end
-- ②效果的发动条件：检测额外卡组是否存在表侧表示的「创星龙华-光巴」。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查额外卡组是否存在至少1张表侧表示的「创星龙华-光巴」。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil)
end
-- 过滤可以特殊召唤的「龙华」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1c0) and c:IsFaceupEx()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查选出的3张卡是否分别来自卡组、墓地、除外状态，且种族互不相同。
function s.spgcheck(g,tp)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)==1
		and g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==1
		and g:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)==1
		and g:GetClassCount(Card.GetRace)==#g
end
-- ②效果的发动准备与合法性检测，检查怪兽区域空位数、精灵龙限制以及是否存在满足条件的3张卡。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组、墓地、除外状态中所有符合条件的「龙华」怪兽。
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己的主要怪兽区域是否有3个以上的空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		and g:CheckSubGroup(s.spgcheck,3,3,tp) end
	-- 设置连锁信息：从卡组、墓地、除外状态将3只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ②效果的处理：从卡组、墓地、除外状态各选择1只种族不同的「龙华」怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取卡组、墓地（受王家之谷影响）、除外状态中所有符合条件的「龙华」怪兽。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	if g:CheckSubGroup(s.spgcheck,3,3,tp) then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:SelectSubGroup(tp,s.spgcheck,false,3,3,tp)
		if sg:GetCount()>2 then
			-- 将选中的3只怪兽以表侧表示特殊召唤。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
