--電幻機塊コンセントロール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「机块」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡已在怪兽区域存在的状态，自己场上有其他的「电幻机块 插座小人」特殊召唤的场合才能发动。从卡组把1只「电幻机块 插座小人」特殊召唤。
function c78447174.initial_effect(c)
	-- ①：自己场上有「机块」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78447174,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,78447174)
	e1:SetCondition(c78447174.spcon1)
	e1:SetTarget(c78447174.sptg1)
	e1:SetOperation(c78447174.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡已在怪兽区域存在的状态，自己场上有其他的「电幻机块 插座小人」特殊召唤的场合才能发动。从卡组把1只「电幻机块 插座小人」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78447174,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,78447175)
	e2:SetCondition(c78447174.spcon2)
	e2:SetTarget(c78447174.sptg2)
	e2:SetOperation(c78447174.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「机块」怪兽
function c78447174.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x14b)
end
-- 效果①的发动条件：自己场上有「机块」怪兽存在
function c78447174.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「机块」怪兽
	return Duel.IsExistingMatchingCard(c78447174.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的靶向/发动准备：检查怪兽区域空位并确认自身能否特殊召唤
function c78447174.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将自身特殊召唤
function c78447174.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：自己场上表侧表示的「电幻机块 插座小人」
function c78447174.cfilter2(c,tp)
	return c:IsFaceup() and c:IsCode(78447174) and c:IsControler(tp)
end
-- 效果②的发动条件：自身已在怪兽区域存在，且自己场上有其他的「电幻机块 插座小人」特殊召唤成功
function c78447174.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c78447174.cfilter2,1,nil,tp)
end
-- 过滤条件：卡组中可以特殊召唤的「电幻机块 插座小人」
function c78447174.spfilter(c,e,tp)
	return c:IsCode(78447174) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向/发动准备：检查怪兽区域空位并确认卡组中是否存在可特殊召唤的「电幻机块 插座小人」
function c78447174.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的「电幻机块 插座小人」
		and Duel.IsExistingMatchingCard(c78447174.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组将1只「电幻机块 插座小人」特殊召唤
function c78447174.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的「电幻机块 插座小人」
	local g=Duel.SelectMatchingCard(tp,c78447174.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
