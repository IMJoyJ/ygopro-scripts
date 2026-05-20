--守護竜エルピィ
-- 效果：
-- 4星以下的龙族怪兽1只
-- 自己对「守护龙 厄尔庇」1回合只能有1次特殊召唤，那个②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己不是龙族怪兽不能特殊召唤。
-- ②：自己主要阶段才能发动。从手卡·卡组把1只龙族怪兽往作为受2只以上的连接怪兽所连接区的自己场上特殊召唤。
function c86148577.initial_effect(c)
	c:SetSPSummonOnce(86148577)
	c:EnableReviveLimit()
	-- 设置连接召唤手续，需要1只满足过滤条件的怪兽作为素材。
	aux.AddLinkProcedure(c,c86148577.matfilter,1,1)
	-- ①：只要这张卡在怪兽区域存在，自己不是龙族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c86148577.splimit)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从手卡·卡组把1只龙族怪兽往作为受2只以上的连接怪兽所连接区的自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86148577,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,86148577)
	e2:SetTarget(c86148577.sptg)
	e2:SetOperation(c86148577.spop)
	c:RegisterEffect(e2)
end
-- 过滤连接素材，必须是4星以下的龙族怪兽。
function c86148577.matfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkRace(RACE_DRAGON)
end
-- 限制自己不能特殊召唤龙族以外的怪兽。
function c86148577.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsRace(RACE_DRAGON)
end
-- 过滤场上表侧表示的连接怪兽。
function c86148577.lkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 过滤手卡或卡组中可以特殊召唤到指定区域的龙族怪兽。
function c86148577.spfilter(c,e,tp,zone)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果②的发动准备与可行性检查。
function c86148577.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上被2只以上连接怪兽指向的区域。
	local zone=aux.GetMultiLinkedZone(tp)
	-- 检查手卡或卡组中是否存在至少1只可以特殊召唤到多指向区域的龙族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c86148577.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,zone) end
	-- 设置连锁处理的操作信息，表示将从手卡或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的执行处理。
function c86148577.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上被2只以上连接怪兽指向的区域。
	local zone=aux.GetMultiLinkedZone(tp)
	-- 检查多指向区域中是否有可用的怪兽区域，若无则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只可以特殊召唤到多指向区域的龙族怪兽。
	local g=Duel.SelectMatchingCard(tp,c86148577.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,zone)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到指定的多指向区域。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
