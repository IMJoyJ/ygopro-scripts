--独奏の第1楽章
-- 效果：
-- 「独奏的第1乐章」在1回合只能发动1张，这张卡发动的回合，自己不是「幻奏」怪兽不能特殊召唤。
-- ①：自己场上没有怪兽存在的场合才能发动。从手卡·卡组把1只4星以下的「幻奏」怪兽特殊召唤。
function c44256816.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合才能发动。从手卡·卡组把1只4星以下的「幻奏」怪兽特殊召唤。
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
	-- 设置一个计数器，用于记录玩家在1回合内特殊召唤的「幻奏」怪兽数量
	Duel.AddCustomActivityCounter(44256816,ACTIVITY_SPSUMMON,c44256816.counterfilter)
end
-- 计数器过滤函数，判断卡片是否为「幻奏」系列
function c44256816.counterfilter(c)
	return c:IsSetCard(0x9b)
end
-- 效果发动条件：自己场上没有怪兽
function c44256816.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否没有怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 效果发动时的费用处理：检查是否在本回合内已经有过特殊召唤行为
function c44256816.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在本回合内是否已经进行过特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(44256816,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建一个影响全场的永续效果，使玩家不能特殊召唤非「幻奏」怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c44256816.splimit)
	-- 将上述效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标函数，用于判断是否为「幻奏」怪兽
function c44256816.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x9b)
end
-- 检索满足条件的「幻奏」怪兽的过滤函数
function c44256816.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x9b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动时处理，检查是否满足发动条件
function c44256816.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡和卡组中是否存在满足条件的「幻奏」怪兽
		and Duel.IsExistingMatchingCard(c44256816.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果发动时的操作信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_HAND)
end
-- 效果发动时的处理函数，执行特殊召唤操作
function c44256816.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「幻奏」怪兽
	local g=Duel.SelectMatchingCard(tp,c44256816.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
