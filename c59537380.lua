--守護竜アガーペイン
-- 效果：
-- 龙族怪兽2只
-- 自己对「守护龙 阿迦佩因」1回合只能有1次特殊召唤，那个②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己不是龙族怪兽不能特殊召唤。
-- ②：自己主要阶段才能发动。从额外卡组把1只龙族怪兽往作为受2只以上的连接怪兽所连接区的，额外怪兽区域或者自己场上特殊召唤。
function c59537380.initial_effect(c)
	c:SetSPSummonOnce(59537380)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：龙族怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_DRAGON),2,2)
	-- ①：只要这张卡在怪兽区域存在，自己不是龙族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c59537380.splimit)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从额外卡组把1只龙族怪兽往作为受2只以上的连接怪兽所连接区的，额外怪兽区域或者自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59537380,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,59537380)
	e2:SetTarget(c59537380.sptg)
	e2:SetOperation(c59537380.spop)
	c:RegisterEffect(e2)
end
-- 限制特殊召唤的怪兽必须为龙族怪兽
function c59537380.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsRace(RACE_DRAGON)
end
-- 过滤场上表侧表示的连接怪兽
function c59537380.lkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 过滤额外卡组中可以特殊召唤到指定区域的龙族怪兽
function c59537380.spfilter(c,e,tp,zone)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
		-- 检查额外卡组的怪兽是否有可用的特殊召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的发动准备与合法性检测（检查是否存在受2只以上连接怪兽连接的区域，以及额外卡组是否有可特召的龙族怪兽）
function c59537380.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家场上受2只以上连接怪兽所连接的区域
	local zone=aux.GetMultiLinkedZone(tp)
	if chk==0 then return zone~=0
		-- 检查额外卡组是否存在至少1只可以特殊召唤到上述区域的龙族怪兽
		and Duel.IsExistingMatchingCard(c59537380.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,zone) end
	-- 设置特殊召唤的操作信息，表示该效果会从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的执行处理（在受2只以上连接怪兽连接的区域特殊召唤额外卡组的1只龙族怪兽）
function c59537380.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取当前玩家场上受2只以上连接怪兽所连接的区域
	local zone=aux.GetMultiLinkedZone(tp)
	if zone==0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c59537380.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,zone)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤到受2只以上连接怪兽连接的区域
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
