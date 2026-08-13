--X－セイバー ブルノ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从自己的手卡·场上（表侧表示）·墓地把这张卡以外的1只地属性怪兽除外才能发动。这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把1张「剑士」魔法·陷阱卡加入手卡。
-- ③：1回合1次，对方的主要阶段以及战斗阶段才能发动。只用包含这张卡的自己场上的地属性怪兽为素材进行同调召唤。
local s,id,o=GetID()
-- 定义初始效果注册函数，为卡注册①手牌起动特殊召唤、②召唤/特殊召唤时检索「剑士」魔陷、③对方主要阶段/战斗阶段同调召唤三个效果。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡存在的场合，从自己的手卡·场上（表侧表示）·墓地把这张卡以外的1只地属性怪兽除外才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把1张「剑士」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：1回合1次，对方的主要阶段以及战斗阶段才能发动。只用包含这张卡的自己场上的地属性怪兽为素材进行同调召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"同调召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.sccon)
	e4:SetTarget(s.sctg)
	e4:SetOperation(s.scop)
	c:RegisterEffect(e4)
end
-- 定义①效果代价的筛选函数，用来筛选可作为代价除外的地属性怪兽，并确保除外后仍有怪兽区可用。
function s.cfilter(c,tp)
	-- 判断目标为地属性、表侧表示、可作为代价除外，且以目标为对象计算除外后自己仍有可用怪兽区。
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsFaceupEx() and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- ①效果的代价函数：从自己的手卡、表侧表示的场上、墓地选择1只本卡以外的地属性怪兽表侧表示除外作为发动代价。
function s.spost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在可供除外的地属性怪兽（不包含本卡），且除外后仍有空位可特殊召唤。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),tp) end
	-- 显示“请选择要除外的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只符合条件的地属性怪兽（手卡·表侧场上·墓地，不包含本卡）。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,1,e:GetHandler(),tp)
	-- 将选中的怪兽表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的目标函数：确认本卡能够特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁在效果处理时进行特殊召唤本卡的操作信息，供相关卡检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数：若本卡仍然关联当前连锁，则将其表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToChain() then
		-- 将这张卡表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的检索筛选函数：筛选卡名含有「剑士」的魔法·陷阱卡，且能够加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0xd) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的目标函数：检查卡组或墓地存在符合条件的检索目标，向对方提示发动，并设置加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时需要卡组或墓地存在至少1张符合条件的「剑士」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 向对方玩家提示本卡发动了检索效果（显示效果描述）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理时从卡组·墓地中选1张卡加入手卡，张数为1，位置为卡组+墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果的处理函数：从卡组·墓地选择1张符合条件的「剑士」魔法·陷阱卡加入手卡，并让对方确认；墓地选择受王家长眠之谷限制。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组和墓地中选择1张符合条件的「剑士」魔法·陷阱卡，墓地部分会排除受王家长眠之谷影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的发动条件函数：只在对方回合的主要阶段或战斗阶段可以发动。
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家不是自己，并且处于主要阶段或战斗阶段。
	return Duel.GetTurnPlayer()~=tp and (Duel.IsMainPhase() or Duel.IsBattlePhase())
end
-- ③效果的目标函数：确认自己场上存在地属性怪兽，且额外卡组存在能用本卡和这些地属性怪兽进行同调召唤的怪兽；随后设置同调召唤的操作信息。
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 取得自己场上所有地属性怪兽，作为同调素材候选组。
		local mg=Duel.GetMatchingGroup(Card.IsAttribute,tp,LOCATION_MZONE,0,nil,ATTRIBUTE_EARTH)
		-- 检查额外卡组是否存在能够以c和mg为素材进行同调召唤的怪兽。
		return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,c,mg)
	end
	-- 向对方玩家提示本卡发动了③效果（显示效果描述）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理时从额外卡组进行1只同调怪兽的特殊召唤（同调召唤）的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ③效果的处理函数：确认本卡仍在自己场上且与连锁相关，从可同调召唤的额外怪兽中选择1只，用本卡和场上的地属性怪兽为素材进行同调召唤。
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToChain() or c:IsFacedown() then return end
	-- 取得自己场上所有地属性怪兽（包含本卡）作为同调素材候选组。
	local mg=Duel.GetMatchingGroup(Card.IsAttribute,tp,LOCATION_MZONE,0,nil,ATTRIBUTE_EARTH)
	-- 取得额外卡组中所有能够以本卡和mg为素材进行同调召唤的同调怪兽。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c,mg)
	if g:GetCount()>0 then
		-- 显示“请选择要特殊召唤的卡”的选卡提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以这张卡作为调整，从候选素材中选择必要素材，执行同调召唤。
		Duel.SynchroSummon(tp,sg:GetFirst(),c,mg)
	end
end
