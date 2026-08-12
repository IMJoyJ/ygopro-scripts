--運命の盤上
local s,id,o=GetID()
-- 初始化陷阱卡效果，创建两个效果：效果1为发动时特殊召唤，效果2为盖放时可发动
function s.initial_effect(c)
	-- 效果1：陷阱卡发动时触发，可以特殊召唤1只通常怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 效果2：陷阱卡盖放时触发，支付代价后可发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetValue(id)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断是否为通常怪兽且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果处理前的检查：确认场上是否有空位且手牌或墓地有满足条件的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，提示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 发动效果处理函数：计算可特殊召唤数量并执行特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct>5 then ct=5 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 检查是否有空位且可特殊召唤数量大于0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ct>0
		-- 检查是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,ct,nil,e,tp)
		-- 执行特殊召唤操作，将选中的怪兽以表侧攻击形式特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 注册一个永续效果，禁止对方在结束阶段时特殊召唤额外怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将该效果注册到玩家场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制不能特殊召唤额外怪兽区域的怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 判断陷阱卡是否处于盖放状态且在场上的条件
function s.condition(e)
	return e:GetHandler():IsStatus(STATUS_SET_TURN) and e:GetHandler():IsLocation(LOCATION_ONFIELD)
end
-- 过滤函数：判断是否为通常怪兽且未公开
function s.costfilter(c)
	return c:IsType(TYPE_NORMAL) and not c:IsPublic()
end
-- 发动时支付代价的处理函数：选择一张手牌确认给对方并洗切手牌
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的手牌
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要确认给对方的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择一张手牌确认给对方
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 确认对方查看所选卡牌
	Duel.ConfirmCards(1-tp,g)
	-- 将玩家手牌洗切
	Duel.ShuffleHand(tp)
end
