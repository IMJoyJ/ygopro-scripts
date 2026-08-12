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
	-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
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
	-- ③：这张卡被送去墓地的场合才能发动。从卡组把「彼岸的恶鬼 格拉菲亚卡内」以外的1只「彼岸」怪兽特殊召唤。
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
-- 过滤函数，用于判断场上是否存在非「彼岸」怪兽或里侧表示的怪兽。
function c20758643.sdfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xb1)
end
-- 效果条件函数，判断场上是否存在非「彼岸」怪兽或里侧表示的怪兽。
function c20758643.sdcon(e)
	-- 判断场上是否存在非「彼岸」怪兽或里侧表示的怪兽。
	return Duel.IsExistingMatchingCard(c20758643.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断场上是否存在魔法·陷阱卡。
function c20758643.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果条件函数，判断自己场上是否没有魔法·陷阱卡存在。
function c20758643.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否没有魔法·陷阱卡存在。
	return not Duel.IsExistingMatchingCard(c20758643.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤效果的发动时点处理函数，检查是否满足特殊召唤条件。
function c20758643.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的发动处理函数，将卡片特殊召唤到场上。
function c20758643.ssop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将卡片以正面表示的形式特殊召唤到场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于筛选卡组中符合条件的「彼岸」怪兽。
function c20758643.spfilter(c,e,tp)
	return c:IsSetCard(0xb1) and not c:IsCode(20758643) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 墓地触发效果的发动时点处理函数，检查是否满足特殊召唤条件。
function c20758643.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在符合条件的「彼岸」怪兽。
		and Duel.IsExistingMatchingCard(c20758643.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置墓地触发效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 墓地触发效果的发动处理函数，从卡组选择并特殊召唤符合条件的怪兽。
function c20758643.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择符合条件的「彼岸」怪兽。
	local g=Duel.SelectMatchingCard(tp,c20758643.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以正面表示的形式特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
