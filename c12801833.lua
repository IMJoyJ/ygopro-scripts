--蟲惑の園
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「虫惑魔」怪兽召唤。
-- ②：只要这张卡在场地区域存在，自己的昆虫族·植物族怪兽在1回合各有1次不会被战斗破坏。
-- ③：把自己场上1只怪兽除外才能发动。从自己的手卡·墓地选1只「虫惑魔」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册场地魔法卡的通用发动效果，使卡可以被正常发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「虫惑魔」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 设置效果目标为持有虫惑魔卡族的卡
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108a))
	c:RegisterEffect(e2)
	-- ②：只要这张卡在场地区域存在，自己的昆虫族·植物族怪兽在1回合各有1次不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为昆虫族或植物族怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_INSECT+RACE_PLANT))
	e3:SetValue(s.indct)
	c:RegisterEffect(e3)
	-- ③：把自己场上1只怪兽除外才能发动。从自己的手卡·墓地选1只「虫惑魔」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 设置战斗破坏时的不被破坏次数为1次
function s.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end
-- 过滤函数，检查场上是否有可以作为除外代价的怪兽
function s.cfilter(c,tp)
	-- 检查怪兽是否可以除外作为代价且场上存在可用怪兽区
	return c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 处理效果发动的除外代价，选择并除外场上1只怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外代价条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择场上1只可以除外的怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 将选中的怪兽除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，检查手牌或墓地是否有可特殊召唤的虫惑魔怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x108a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动条件，检查手牌或墓地是否存在虫惑魔怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理信息，确定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 处理效果的发动，从手牌或墓地特殊召唤虫惑魔怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从手牌或墓地选择1只虫惑魔怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的虫惑魔怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
