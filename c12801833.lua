--蟲惑の園
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「虫惑魔」怪兽召唤。
-- ②：只要这张卡在场地区域存在，自己的昆虫族·植物族怪兽在1回合各有1次不会被战斗破坏。
-- ③：把自己场上1只怪兽除外才能发动。从自己的手卡·墓地选1只「虫惑魔」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册虫惑之园的全部效果：e1为场地魔法卡发动本身，e2实现①的额外通常召唤，e3实现②的昆虫族·植物族怪兽战斗破坏耐性，e4实现③的除外自身怪兽后从手卡·墓地特殊召唤「虫惑魔」。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「虫惑魔」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"使用「虫惑之园」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 限定额外召唤次数的加成仅适用于「虫惑魔」怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108a))
	c:RegisterEffect(e2)
	-- ②：只要这张卡在场地区域存在，自己的昆虫族·植物族怪兽在1回合各有1次不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 限定此抗破坏效果只对自己场上的昆虫族·植物族怪兽适用。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_INSECT+RACE_PLANT))
	e3:SetValue(s.indct)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：把自己场上1只怪兽除外才能发动。从自己的手卡·墓地选1只「虫惑魔」怪兽特殊召唤。
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
-- 为②效果提供免疫次数：当破坏原因为战斗时返回1，表示该怪兽本回合有1次不会被战斗破坏；非战斗破坏则返回0。
function s.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end
-- ③代价的过滤函数：选择自己场上可作为代价除外的怪兽，且除外后自己场上仍有空余的怪兽区。
function s.cfilter(c,tp)
	-- 要求该怪兽能被除外作为代价，并且除外后自己场上仍有至少1个空余怪兽区，以保证后续特殊召唤有格子可用。
	return c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- ③的代价处理：从自己场上选择1只满足条件的怪兽，将其正面表示除外作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测时，确认自己场上是否存在至少1只可被除外且除外后仍有怪兽区空位的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 弹出选择提示，提示当前玩家选择要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让当前玩家从自己场上选择1只满足代价过滤条件的怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 将所选怪兽正面表示除外，作为发动③效果的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ③特殊召唤的过滤函数：选择对象必须是「虫惑魔」怪兽，并且能够被正常特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x108a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③的发动目标检测：确认手卡·墓地存在可特殊召唤的「虫惑魔」怪兽，并登记特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检测时，确认手卡或墓地中是否存在至少1只满足特殊召唤过滤条件的「虫惑魔」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 将本次连锁登记为特殊召唤操作，预计从手卡·墓地特殊召唤1只「虫惑魔」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ③效果处理时的实际操作：在有空余怪兽区的前提下，从手卡·墓地选择1只「虫惑魔」怪兽特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前先检查自己场上是否存在空余怪兽区，若没有则直接终止处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，提示当前玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只满足条件的「虫惑魔」怪兽；使用NecroValleyFilter使墓地选择时排除受王家长眠之谷影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「虫惑魔」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
