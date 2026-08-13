--彼岸の悪鬼 グラバースニッチ
-- 效果：
-- 这个卡名的①③的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
-- ③：这张卡被送去墓地的场合才能发动。从卡组把「彼岸的恶鬼 格拉菲亚卡内」以外的1只「彼岸」怪兽特殊召唤。
function c20758643.initial_effect(c)
	-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c20758643.sdcon)
	c:RegisterEffect(e1)
	-- 这个卡名的①③的效果1回合只能有1次使用其中任意1个。①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20758643,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,20758643)
	e2:SetCondition(c20758643.sscon)
	e2:SetTarget(c20758643.sstg)
	e2:SetOperation(c20758643.ssop)
	c:RegisterEffect(e2)
	-- 这个卡名的①③的效果1回合只能有1次使用其中任意1个。③：这张卡被送去墓地的场合才能发动。从卡组把「彼岸的恶鬼 格拉菲亚卡内」以外的1只「彼岸」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20758643,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,20758643)
	e3:SetTarget(c20758643.sptg)
	e3:SetOperation(c20758643.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：用于②效果的破坏判定，满足条件的怪兽为里侧表示或不是「彼岸」字段的怪兽。
function c20758643.sdfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xb1)
end
-- ②效果的适用条件：自己场上存在至少1只里侧表示或非「彼岸」字段的怪兽时，这张卡触发自我破坏。
function c20758643.sdcon(e)
	-- 检查自己场上是否存在至少1只里侧表示或非「彼岸」怪兽。
	return Duel.IsExistingMatchingCard(c20758643.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：魔法·陷阱卡，用于①效果检查自己场上是否没有魔法·陷阱卡。
function c20758643.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ①效果的发动条件：自己场上不存在魔法·陷阱卡。
function c20758643.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上没有任何魔法·陷阱卡。
	return not Duel.IsExistingMatchingCard(c20758643.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①效果发动时的合法性判定：自己主要怪兽区有空位，且这张卡在手牌可以被特殊召唤。
function c20758643.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将本次效果登记为特殊召唤这张卡，特殊召唤的对象为效果持有者自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果保持关联，则将其表侧表示特殊召唤到自己场上。
function c20758643.ssop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的检索目标条件：卡组中的「彼岸」怪兽，卡名不是「彼岸的恶鬼 格拉菲亚卡内」，且能够被这次效果特殊召唤。
function c20758643.spfilter(c,e,tp)
	return c:IsSetCard(0xb1) and not c:IsCode(20758643) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果发动时的合法性判定：自己主要怪兽区有空位，且卡组中存在能够特殊召唤的「彼岸」怪兽。
function c20758643.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ③效果检查：确认自己主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组中是否存在至少1只满足③效果条件的「彼岸」怪兽。
		and Duel.IsExistingMatchingCard(c20758643.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：登记为从卡组将1只怪兽特殊召唤，处理时再从卡组选择对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：若自己主要怪兽区有空位，则提示玩家从卡组选择1只符合条件的「彼岸」怪兽，并表侧特殊召唤到自己场上。
function c20758643.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有空位，则③效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的「彼岸」怪兽（不包括「彼岸的恶鬼 格拉菲亚卡内」自身）。
	local g=Duel.SelectMatchingCard(tp,c20758643.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
