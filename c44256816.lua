--独奏の第1楽章
-- 效果：
-- 「独奏的第1乐章」在1回合只能发动1张，这张卡发动的回合，自己不是「幻奏」怪兽不能特殊召唤。
-- ①：自己场上没有怪兽存在的场合才能发动。从手卡·卡组把1只4星以下的「幻奏」怪兽特殊召唤。
function c44256816.initial_effect(c)
	-- 「独奏的第1乐章」在1回合只能发动1张，这张卡发动的回合，自己不是「幻奏」怪兽不能特殊召唤。①：自己场上没有怪兽存在的场合才能发动。从手卡·卡组把1只4星以下的「幻奏」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,44256816+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c44256816.condition)
	e1:SetCost(c44256816.cost)
	e1:SetTarget(c44256816.target)
	e1:SetOperation(c44256816.activate)
	c:RegisterEffect(e1)
	-- 注册一个特殊召唤活动计数器，统计本方进行过的非「幻奏」怪兽特殊召唤次数，用于后续发动条件与自肃的检查。
	Duel.AddCustomActivityCounter(44256816,ACTIVITY_SPSUMMON,c44256816.counterfilter)
end
-- 计数器过滤函数：若怪兽不是「幻奏」系列则返回false，使计数器加1，即记录一次违规特殊召唤。
function c44256816.counterfilter(c)
	return c:IsSetCard(0x9b)
end
-- 效果的发动条件判定函数：自己场上没有怪兽存在的场合才能发动。
function c44256816.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区域（含额外怪兽区）的怪兽数量是否为0，即自己场上没有怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 效果的发动代价/自肃处理：若本回合尚未进行过非「幻奏」怪兽的特殊召唤，则给自己附加『不能特殊召唤「幻奏」以外的怪兽』的誓约效果，持续到回合结束。
function c44256816.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查阶段：确认本方本回合的非「幻奏」特殊召唤计数为0，即尚未进行过非「幻奏」怪兽的特殊召唤。
	if chk==0 then return Duel.GetCustomActivityCount(44256816,tp,ACTIVITY_SPSUMMON)==0 end
	-- ①：自己场上没有怪兽存在的场合才能发动。从手卡·卡组把1只4星以下的「幻奏」怪兽特殊召唤。且这张卡发动的回合，自己不是「幻奏」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c44256816.splimit)
	-- 将自肃效果注册到场上，作用于玩家自身（tp），并在回合结束阶段重置。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定函数：被特殊召唤的怪兽不是「幻奏」系列时，禁止该特殊召唤行为（返回true即禁止）。
function c44256816.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x9b)
end
-- 特殊召唤候选卡的过滤条件：等级4以下、属于「幻奏」系列，且能够被玩家tp以表侧表示特殊召唤。
function c44256816.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x9b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标判定/选择处理：确认自己场上有空位，且手牌·卡组中存在符合条件的「幻奏」怪兽，并设置特殊召唤的操作信息。
function c44256816.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否有空位，作为发动条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌·卡组中是否存在至少1只满足条件的4星以下「幻奏」怪兽（不取对象），作为发动条件之一。
		and Duel.IsExistingMatchingCard(c44256816.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次效果操作信息：从手卡·卡组特殊召唤1只怪兽（分类为特殊召唤，数量为1，来源为手卡·卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理：从手卡·卡组选择1只符合条件的「幻奏」怪兽，以表侧表示特殊召唤到自己场上。
function c44256816.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上是否有可用的主要怪兽区域，若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择卡片提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组中选择1张满足条件的「幻奏」怪兽（4星以下且可特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c44256816.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
