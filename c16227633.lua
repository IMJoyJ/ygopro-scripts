--メメント・ボーン・バック
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示的「莫忘」怪兽因对方从场上离开的场合才能发动。从手卡·卡组把1只「冥骸合龙-莫忘冥地王灵」无视召唤条件特殊召唤。
-- ②：这张卡在墓地存在的状态，自己墓地的「莫忘」怪兽因对方从墓地离开的场合，把这张卡除外才能发动。从手卡·卡组把「莫忘」怪兽尽可能特殊召唤（同名卡最多1张）。
local s,id,o=GetID()
-- 注册这张卡的①②两个效果：e1为①效果（卡的发动，自己场上的表侧表示「莫忘」怪兽因对方从场上离场时，从手卡·卡组将1只「冥骸合龙-莫忘冥地王灵」无视召唤条件特殊召唤）；e2为②效果（这张卡在墓地存在期间，自己墓地的「莫忘」怪兽因对方从墓地离场时，除外自身并从手卡·卡组尽可能特殊召唤「莫忘」怪兽，同名卡最多1张）。两效果各自1回合1次。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上的表侧表示的「莫忘」怪兽因对方从场上离开的场合才能发动。从手卡·卡组把1只「冥骸合龙-莫忘冥地王灵」无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己墓地的「莫忘」怪兽因对方从墓地离开的场合，把这张卡除外才能发动。从手卡·卡组把「莫忘」怪兽尽可能特殊召唤（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.spcon)
	-- 设置②效果的发动代价：将墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①发动条件的怪兽判定：该怪兽离场前是自己场上表侧表示的「莫忘」怪兽，位于主要怪兽区域，其之前控制者为发动玩家，且导致其离场的玩家是对方。
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0x1a1) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- ①效果的触发条件：本次离场事件中，存在至少1只满足 s.cfilter 的怪兽，即自己场上的表侧表示「莫忘」怪兽因对方而从场上离开。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 筛选①效果要特殊召唤的卡：卡号为23288411的「冥骸合龙-莫忘冥地王灵」，且能够被当前效果无视召唤条件特殊召唤。
function s.filter(c,e,tp)
	return c:IsCode(23288411) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ①效果发动时的合法性检查：自己场上有空余的怪兽区域，且手卡·卡组中存在至少1只满足 s.filter 的「冥骸合龙-莫忘冥地王灵」。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组中是否存在至少1只满足 s.filter 的「冥骸合龙-莫忘冥地王灵」。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记该连锁的操作信息：涉及特殊召唤，预计从手卡·卡组特殊召唤1只怪兽；具体对象在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ①效果处理：若自己场上仍有空余怪兽区域，则选择1只符合条件的「冥骸合龙-莫忘冥地王灵」，无视召唤条件表侧表示特殊召唤到自己场上。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若处理时自己场上没有空余怪兽区域，则不进行特殊召唤并结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给出选择提示，提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·卡组中选择1张满足 s.filter 的卡（即「冥骸合龙-莫忘冥地王灵」）。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选择的那只怪兽无视召唤条件（nocheck=true）表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
end
-- ②发动条件的怪兽判定：该怪兽是「莫忘」字段的怪兽卡，且其之前控制者为发动玩家（即从自己墓地离开的「莫忘」怪兽）。
function s.mfilter(c,tp)
	return c:IsSetCard(0x1a1) and c:IsType(TYPE_MONSTER) and c:IsPreviousControler(tp)
end
-- ②效果的触发条件：本次离开墓地的原因玩家是对方，且离开的怪兽中存在至少1只满足 s.mfilter 的「莫忘」怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(s.mfilter,1,nil,tp)
end
-- 筛选②效果要特殊召唤的卡：持有「莫忘」字段，且能够被当前效果通常地特殊召唤（不无视召唤条件和苏生限制）。
function s.sfilter(c,e,tp)
	return c:IsSetCard(0x1a1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时的合法性检查：自己场上有空余的怪兽区域，且手卡·卡组中存在至少1只满足 s.sfilter 的「莫忘」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组中是否存在至少1只满足 s.sfilter 的「莫忘」怪兽。
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记该连锁的操作信息：涉及特殊召唤，预计从手卡·卡组特殊召唤1只怪兽；实际数量在处理时再决定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ②效果处理：从手卡·卡组选出所有可特殊召唤的「莫忘」怪兽，计算可召唤数量（不超过空余区域和不同卡名数，若「青眼精灵龙」效果适用中则最多1只），由玩家选择该数量的不同卡名怪兽，表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得手卡·卡组中所有满足 s.sfilter 的「莫忘」怪兽，作为候选集合。
	local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 计算本次最多可特殊召唤的数量：取空余怪兽区域数与候选集合中不同卡名数的较小值（因同名卡最多1张）。
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),g:GetClassCount(Card.GetCode))
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 给出选择提示，提示玩家选择要特殊召唤的「莫忘」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从候选集合中选出 ft 张卡名各不相同的「莫忘」怪兽（aux.dncheck 保证卡名互不相同），若玩家完成选择则返回所选分组。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,ft,ft)
	-- 若选择成功，则将所选的「莫忘」怪兽以表侧表示特殊召唤到自己场上。
	if sg then Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP) end
end
