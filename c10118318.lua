--トゥルース・リインフォース
-- 效果：
-- 这张卡发动的回合，自己不能进行战斗阶段。
-- ①：从卡组把1只2星以下的战士族怪兽特殊召唤。
function c10118318.initial_effect(c)
	-- ①：从卡组把1只2星以下的战士族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c10118318.cost)
	e1:SetTarget(c10118318.target)
	e1:SetOperation(c10118318.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价处理函数，用于处理发动时的誓约效果（本回合不能进行战斗阶段）
function c10118318.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动条件：本回合尚未进行过战斗阶段（ACTIVITY_BATTLE_PHASE计数为0）
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 这张卡发动的回合，自己不能进行战斗阶段。①：从卡组把1只2星以下的战士族怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册誓约效果到玩家，使本回合内该玩家不能进入战斗阶段
	Duel.RegisterEffect(e1,tp)
end
-- 定义过滤函数，用于筛选2星以下的战士族且可以特殊召唤的怪兽
function c10118318.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义目标处理函数，用于检查特殊召唤条件并设置操作信息
function c10118318.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动条件：自己场上存在可用的怪兽区域（空格数大于0）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽（2星以下战士族可特殊召唤）
		and Duel.IsExistingMatchingCard(c10118318.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，声明此效果将从卡组特殊召唤1只怪兽（此时目标不确定）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 定义效果处理函数，执行特殊召唤操作
function c10118318.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查怪兽区域是否已满，若无可用区域则终止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 让玩家从卡组中选择1张满足过滤条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,c10118318.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤到玩家自己的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
