--天盃龍チュンドラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有龙族·炎属性怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：怪兽进行战斗的伤害步骤开始时才能发动。除「天杯龙 中龙」外的1只4星以下的龙族·炎属性怪兽从卡组特殊召唤。
-- ③：1回合1次，自己·对方的战斗阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
function c91810826.initial_effect(c)
	-- ①：自己场上有龙族·炎属性怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91810826,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,91810826)
	e1:SetCondition(c91810826.spcon)
	e1:SetTarget(c91810826.sptg)
	e1:SetOperation(c91810826.spop)
	c:RegisterEffect(e1)
	-- ②：怪兽进行战斗的伤害步骤开始时才能发动。除「天杯龙 中龙」外的1只4星以下的龙族·炎属性怪兽从卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91810826,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,91810827)
	e2:SetTarget(c91810826.sptg2)
	e2:SetOperation(c91810826.spop2)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己·对方的战斗阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91810826,2))  --"同调召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_STEP_END+TIMING_BATTLE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c91810826.sccon)
	e3:SetTarget(c91810826.sctg)
	e3:SetOperation(c91810826.scop)
	c:RegisterEffect(e3)
end
-- 过滤条件：表侧表示的龙族·炎属性怪兽
function c91810826.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 效果①的发动条件：自己场上存在龙族·炎属性怪兽
function c91810826.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的龙族·炎属性怪兽
	return Duel.IsExistingMatchingCard(c91810826.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备：检查怪兽区域空格及自身是否能特殊召唤，并设置操作信息
function c91810826.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：特殊召唤自身
function c91810826.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：卡组中除「天杯龙 中龙」以外的4星以下的龙族·炎属性怪兽
function c91810826.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevelBelow(4) and not c:IsCode(91810826)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查怪兽区域空格及卡组中是否存在符合条件的怪兽，并设置操作信息
function c91810826.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c91810826.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向对方玩家提示发动了“从卡组特殊召唤”的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(91810826,1))  --"从卡组特殊召唤"
	-- 设置从卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组特殊召唤怪兽
function c91810826.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c91810826.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的发动条件：自己或对方的战斗阶段
function c91810826.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 效果③的发动准备：检查额外卡组是否存在可以以这张卡为素材同调召唤的怪兽，并设置操作信息
function c91810826.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在可以以这张卡为素材进行同调召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 向对方玩家提示发动了“同调召唤”的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(91810826,2))  --"同调召唤"
	-- 设置从额外卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果③的效果处理：进行同调召唤
function c91810826.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有可以以这张卡为素材进行同调召唤的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以这张卡为素材，对选中的怪兽进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
