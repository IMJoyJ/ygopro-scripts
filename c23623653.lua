--精霊獣使い レラ
-- 效果：
-- 自己对「精灵兽使 蕾拉」1回合只能有1次特殊召唤，那些①②③的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。进行手卡1只「灵兽」怪兽的召唤。
-- ②：自己场上的「灵兽」卡被战斗·效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
-- ③：这张卡被除外的场合才能发动。从卡组把「精灵兽使 蕾拉」以外的1只「灵兽」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：用SetSPSummonOnce限制同名卡1回合只能特殊召唤1次，然后依次注册①手牌丢弃自身进行灵兽召唤的起动效果、②场上·墓地的自身代替灵兽卡被破坏的代替破坏效果、③自身被除外时从卡组特殊召唤其他灵兽的诱发效果。
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	-- ①：把这张卡从手卡丢弃才能发动。进行手卡1只「灵兽」怪兽的召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"进行「灵兽」怪兽的召唤"
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.sumcost)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「灵兽」卡被战斗·效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE+LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的场合才能发动。从卡组把「精灵兽使 蕾拉」以外的1只「灵兽」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- ①效果的代价函数：检查这张卡在手牌中能否丢弃，若可以则作为代价将其丢弃。
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡以“代价+丢弃”的理由从手牌送去墓地。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：判断手牌中的卡是否属于「灵兽」字段且可以不解放怪兽进行通常召唤（用于选择要召唤的怪兽）。
function s.filter(c)
	return c:IsSetCard(0xb5) and c:IsSummonable(true,nil)
end
-- ①效果的发动目标判定：确认手牌中存在至少1只满足条件的「灵兽」怪兽（且不是这张卡自身），并设置操作信息为召唤类别。
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定时检查：手牌中是否存在至少1张满足s.filter且不是e:GetHandler()（这张卡自身）的「灵兽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 设置本次连锁的操作信息：声明将进行1次召唤，供后续相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ①效果的处理：提示玩家选择要召唤的卡，从手牌选出1只符合条件的「灵兽」怪兽，进行无视通常召唤次数限制的召唤。
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送“请选择要召唤的卡”的选择提示，并缓存选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手牌中选择1张满足s.filter的「灵兽」怪兽（不选择例外卡）。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽通常召唤，ignore_count=true表示不占用每回合的通常召唤次数，e=nil表示按一般召唤规则处理。
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end
-- 代替破坏的过滤条件：被破坏的卡必须是我方场上表侧表示、属于「灵兽」字段、破坏原因为战斗或效果，并且不是由“代替破坏”本身引起。
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField()
		and c:IsSetCard(0xb5) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- ②效果的发动判定：当前破坏事件中存在至少1张符合repfilter的「灵兽」卡，且这张卡（自身）可以从场上·墓地除外且未被预定破坏，则允许发动。
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,c,tp) and c:IsAbleToRemove()
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动代替破坏效果，用自身除外来代替「灵兽」卡被破坏。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏的值判定函数：判断某张卡是否满足s.repfilter，若满足则会被此效果代替破坏。
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- ②效果的处理：将这张卡以表侧表示除外（原因包含效果和代替），从而代替灵兽卡被破坏。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡以表侧表示除外，作为本次破坏的代替处理。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
-- 特殊召唤过滤：从卡组中选出属于「灵兽」字段的怪兽卡，且可以被效果特殊召唤，并且卡名不是「精灵兽使 蕾拉」自身。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xb5) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
-- ③效果的发动目标判定：自己主要怪兽区有空位，且卡组中存在至少1只满足spfilter的「灵兽」怪兽，满足则设置操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 先检查自己场上是否存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 再检查卡组中是否存在至少1张符合条件的「灵兽」怪兽（除外精灵兽使蕾拉自身）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③效果的处理：确认主怪兽区仍有空位后，提示玩家从卡组选择1只符合条件的「灵兽」怪兽，表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果主怪兽区没有空位，则直接终止特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 发送“请选择要特殊召唤的卡”的选择提示，并缓存选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张满足s.spfilter的「灵兽」怪兽（不选择「精灵兽使 蕾拉」自身）。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
