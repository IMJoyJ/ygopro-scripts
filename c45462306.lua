--X－セイバー ブルノ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从自己的手卡·场上（表侧表示）·墓地把这张卡以外的1只地属性怪兽除外才能发动。这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把1张「剑士」魔法·陷阱卡加入手卡。
-- ③：1回合1次，对方的主要阶段以及战斗阶段才能发动。只用包含这张卡的自己场上的地属性怪兽为素材进行同调召唤。
local s,id,o=GetID()
-- 注册卡片效果
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
-- 过滤Cost：可以除外且能空出怪兽区格子的地属性怪兽
function s.cfilter(c,tp)
	-- 检查卡片是否为地属性、表侧表示、可作为Cost除外且除外后怪兽区有空位
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsFaceupEx() and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 发动Cost：从自己的手卡·场上·墓地把这张卡以外的1只地属性怪兽除外
function s.spost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动Cost检查：手卡·场上·墓地是否存在可以除外以腾出位置的地属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),tp) end
	-- 提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择手卡·场上·墓地1只地属性怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,1,e:GetHandler(),tp)
	-- 将选中的怪兽表侧表示除外作为Cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 发动目标：自身在手卡存在且可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToChain() then
		-- 将自身表侧表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡组·墓地可以加入手卡的「剑士」魔法·陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0xd) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 发动目标：卡组·墓地存在可以加入手卡的「剑士」魔法·陷阱卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组·墓地是否存在可以加入手卡的「剑士」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 向对方提示选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：从卡组或墓地把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：从卡组·墓地把1张「剑士」魔法·陷阱卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组·墓地选择1张不受王家长眠之谷影响的「剑士」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 发动条件：对方的主要阶段以及战斗阶段
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方回合的主要阶段或战斗阶段
	return Duel.GetTurnPlayer()~=tp and (Duel.IsMainPhase() or Duel.IsBattlePhase())
end
-- 过滤素材：自己场上表侧表示的地属性怪兽
function s.mfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 发动目标：额外卡组存在只用包含这张卡的自己场上的地属性怪兽为素材可以同调召唤的怪兽
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 获取自己场上表侧表示的地属性怪兽
		local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
		-- 判断额外卡组是否存在可以同调召唤的怪兽
		return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,c,mg)
	end
	-- 向对方提示选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：只用包含这张卡的自己场上的地属性怪兽为素材进行同调召唤
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToChain() or c:IsFacedown() then return end
	-- 获取自己场上表侧表示的地属性怪兽
	local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取额外卡组中可进行同调召唤的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c,mg)
	if g:GetCount()>0 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以包含这张卡的地属性怪兽为素材进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),c,mg)
	end
end
