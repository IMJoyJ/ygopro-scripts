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
	-- ①：场上的「废铁」怪兽的攻击力上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置该效果的适用对象为场上所有含「废铁」字段的怪兽（仅对这类怪兽适用攻击力上升效果）。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x24))
	e2:SetValue(200)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果1回合只能使用1次。②：场上的表侧表示的「废铁」怪兽被效果破坏送去墓地时才能发动。自己从卡组把1只「废铁」怪兽特殊召唤。
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
-- 过滤函数：判断被送去墓地的怪兽是否为场上的表侧表示的「废铁」怪兽，且是被效果破坏而送去墓地（要求字段为废铁、是怪兽、破坏原因为效果破坏、破坏前位于主要怪兽区且为表侧表示）。
function c28388296.cfilter(c,tp)
	return c:IsSetCard(0x24) and c:IsType(TYPE_MONSTER) and bit.band(c:GetReason(),0x41)==0x41
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 发动条件：本次送去墓地的怪兽组中存在至少1只满足上述条件的「废铁」怪兽。
function c28388296.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28388296.cfilter,1,nil,tp)
end
-- 筛选函数：检查卡组中的卡是否为「废铁」怪兽，并且能够被当前效果特殊召唤。
function c28388296.spfilter(c,e,tp)
	return c:IsSetCard(0x24) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性检查：自己场上存在可用的主要怪兽区，且卡组中存在可特殊召唤的「废铁」怪兽；同时设置本次操作信息。
function c28388296.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动检查阶段（chk==0）判定：自己场上主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 再有，卡组中是否有至少1只满足spfilter的「废铁」怪兽（用于特殊召唤）。
		and Duel.IsExistingMatchingCard(c28388296.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理信息：本次效果将进行特殊召唤处理，从卡组特殊召唤1只「废铁」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若自己场上仍有空位，则从卡组选择1只「废铁」怪兽并特殊召唤。
function c28388296.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上已没有可用主要怪兽区，则不再处理特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示，用于选择卡组中要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组中选出1只满足spfilter的「废铁」怪兽（必须选1张）。
	local g=Duel.SelectMatchingCard(tp,c28388296.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「废铁」怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
