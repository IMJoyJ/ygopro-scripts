--スクラップ・ファクトリー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：场上的「废铁」怪兽的攻击力·守备力上升200。
-- ②：场上的表侧表示的「废铁」怪兽被效果破坏送去墓地时才能发动。自己从卡组把1只「废铁」怪兽特殊召唤。
function c28388296.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「废铁」怪兽的攻击力·守备力上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置效果目标为场上的「废铁」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x24))
	e2:SetValue(200)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：场上的表侧表示的「废铁」怪兽被效果破坏送去墓地时才能发动。自己从卡组把1只「废铁」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(28388296,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,28388296)
	e4:SetCondition(c28388296.condition)
	e4:SetTarget(c28388296.target)
	e4:SetOperation(c28388296.operation)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断被破坏送入墓地的卡是否为「废铁」怪兽且为表侧表示
function c28388296.cfilter(c,tp)
	return c:IsSetCard(0x24) and c:IsType(TYPE_MONSTER) and bit.band(c:GetReason(),0x41)==0x41
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 判断是否有满足条件的「废铁」怪兽被破坏送入墓地
function c28388296.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28388296.cfilter,1,nil,tp)
end
-- 过滤函数，用于选择可以特殊召唤的「废铁」怪兽
function c28388296.spfilter(c,e,tp)
	return c:IsSetCard(0x24) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的处理条件，检查是否满足特殊召唤的条件
function c28388296.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「废铁」怪兽
		and Duel.IsExistingMatchingCard(c28388296.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只「废铁」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，执行特殊召唤操作
function c28388296.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「废铁」怪兽
	local g=Duel.SelectMatchingCard(tp,c28388296.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
