--ガガガ学園の緊急連絡網
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能作超量召唤以外的特殊召唤。
-- ①：只有对方场上才有怪兽存在的场合才能发动。从卡组把1只「我我我」怪兽特殊召唤。
function c21715135.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能作超量召唤以外的特殊召唤。①：只有对方场上才有怪兽存在的场合才能发动。从卡组把1只「我我我」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,21715135+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c21715135.condition)
	e1:SetCost(c21715135.cost)
	e1:SetTarget(c21715135.target)
	e1:SetOperation(c21715135.activate)
	c:RegisterEffect(e1)
	-- 注册代号为21715135的特殊召唤活动计数器，counterfilter作为过滤条件，用于记录本回合是否进行过超量召唤以外的特殊召唤。
	Duel.AddCustomActivityCounter(21715135,ACTIVITY_SPSUMMON,c21715135.counterfilter)
end
-- 计数器过滤函数：若特殊召唤的怪兽是超量召唤则返回true（不计入违规），否则返回false使计数器增加，表示发生过非超量特殊召唤。
function c21715135.counterfilter(c)
	return c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 发动条件判断：对方场上有怪兽存在且自己场上没有怪兽，满足“只有对方场上才有怪兽存在的场合”。
function c21715135.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体检查对方主要怪兽区有怪兽，且自己主要怪兽区没有怪兽。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 代价处理：先检查本回合尚未进行过非超量特殊召唤，然后给自己附加持续到结束阶段的誓约效果，禁止作超量召唤以外的特殊召唤。
function c21715135.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：仅当本回合非超量特殊召唤计数为0时才能发动。
	if chk==0 then return Duel.GetCustomActivityCount(21715135,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不能作超量召唤以外的特殊召唤。①：只有对方场上才有怪兽存在的场合才能发动。从卡组把1只「我我我」怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c21715135.splimit)
	-- 将“不能作超量召唤以外的特殊召唤”的誓约效果注册到玩家tp，以限制其本回合后续的特殊召唤行为。
	Duel.RegisterEffect(e1,tp)
end
-- 该限制效果的条件：若特殊召唤不是超量召唤，且不是由本卡自身①效果发起的特殊召唤，则禁止进行。
function c21715135.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return sumtype~=SUMMON_TYPE_XYZ and e:GetLabelObject()~=se
end
-- 筛选特殊召唤对象：卡名属于「我我我」字段，且能被玩家tp用效果e特殊召唤（满足苏生限制）。
function c21715135.filter(c,e,tp)
	return c:IsSetCard(0x54) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标检查：自己主要怪兽区有空位，且卡组中存在至少1只符合条件的「我我我」怪兽，才能发动。
function c21715135.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在1只满足filter条件的「我我我」怪兽。
		and Duel.IsExistingMatchingCard(c21715135.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽，对象在处理时确定，因此targets为nil，count为1，持有者为tp，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若自己场上仍有空位，则从卡组选择1只符合条件的「我我我」怪兽，正面表示特殊召唤到自己的主要怪兽区。
function c21715135.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区有空位，否则处理失败。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1张满足filter条件的「我我我」怪兽。
	local g=Duel.SelectMatchingCard(tp,c21715135.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽正面表示特殊召唤到玩家tp的场上（不检查召唤条件，不检查苏生限制，sumtype为0）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
