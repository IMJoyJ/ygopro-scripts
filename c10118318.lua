--トゥルース・リインフォース
-- 效果：
-- 这张卡发动的回合，自己不能进行战斗阶段。
-- ①：从卡组把1只2星以下的战士族怪兽特殊召唤。
function c10118318.initial_effect(c)
	-- 这张卡发动的回合，自己不能进行战斗阶段。①：从卡组把1只2星以下的战士族怪兽特殊召唤。
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
-- 卡片发动的限制与誓约处理函数
function c10118318.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动检查时，检查自己本回合是否已进入过战斗阶段
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 这张卡发动的回合，自己不能进行战斗阶段。①：从卡组把1只2星以下的战士族怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册本回合不能进行战斗阶段的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤卡组中2星以下战士族且可特殊召唤的怪兽
function c10118318.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 卡片发动的靶向与可行性检查
function c10118318.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动检查时，检查主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在效果发动检查时，检查自己卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c10118318.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤操作的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 卡片效果的实际处理
function c10118318.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，检查主要怪兽区域是否有空位，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c10118318.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
