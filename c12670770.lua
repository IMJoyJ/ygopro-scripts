--サイバー・ネットワーク
-- 效果：
-- 这张卡发动后，第3次的自己准备阶段破坏。
-- ①：1回合1次，场上有「电子龙」存在的场合才能发动。从卡组把1只机械族·光属性怪兽除外。
-- ②：这张卡从场上送去墓地的场合发动。除外的自己的机械族·光属性怪兽尽可能特殊召唤，自己场上的魔法·陷阱卡全部破坏。这个效果特殊召唤的怪兽不能把效果发动。这个效果发动的回合，自己不能进行战斗阶段。
function c12670770.initial_effect(c)
	-- 创建并注册一个永续效果，使此卡在发动时能触发准备阶段破坏效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c12670770.target1)
	e1:SetOperation(c12670770.operation)
	c:RegisterEffect(e1)
	-- 创建并注册一个诱发即时效果，允许在满足条件时从卡组除外一只机械族·光属性怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12670770,2))  --"从卡组把1只机械族·光属性怪兽除外"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(c12670770.condition)
	e2:SetTarget(c12670770.target2)
	e2:SetOperation(c12670770.operation)
	c:RegisterEffect(e2)
	-- 创建并注册一个诱发必发效果，当此卡被送去墓地时发动，将除外的怪兽特殊召唤并破坏场上魔法·陷阱卡
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12670770,3))  --"除外的怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c12670770.spcon)
	e3:SetCost(c12670770.spcost)
	e3:SetTarget(c12670770.sptg)
	e3:SetOperation(c12670770.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在电子龙（70095154）
function c12670770.filter1(c)
	return c:IsFaceup() and c:IsCode(70095154)
end
-- 过滤函数，用于判断卡组中是否存在机械族·光属性怪兽
function c12670770.filter2(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemove()
end
-- 判断条件函数，检查场上是否存在电子龙
function c12670770.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在电子龙
	return Duel.IsExistingMatchingCard(c12670770.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 设置效果目标函数，用于处理发动时的准备阶段计数和效果选择
function c12670770.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 创建并注册一个持续效果，用于记录准备阶段次数并在第3次时破坏此卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12670770,4))  --"回合计数"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(c12670770.sdescon)
	e1:SetOperation(c12670770.sdesop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,3)
	c:RegisterEffect(e1)
	c:SetTurnCounter(0)
	-- 检查场上是否存在电子龙
	if Duel.IsExistingMatchingCard(c12670770.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 检查卡组中是否存在机械族·光属性怪兽
		and Duel.IsExistingMatchingCard(c12670770.filter2,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否使用此卡效果
		and Duel.SelectYesNo(tp,aux.Stringid(12670770,0)) then  --"是否现在使用「电子网络」的效果？"
		-- 设置操作信息，表示将要除外一张卡
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
		c:RegisterFlagEffect(12670770,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		c:RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(12670770,1))  --"使用效果"
	end
end
-- 设置效果目标函数，用于处理二速效果的除外操作
function c12670770.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(12670770)==0
		-- 检查卡组中是否存在机械族·光属性怪兽
		and Duel.IsExistingMatchingCard(c12670770.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要除外一张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	e:GetHandler():RegisterFlagEffect(12670770,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 设置效果操作函数，用于执行除外操作
function c12670770.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(12670770)==0 or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 提示玩家选择除外卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 从卡组中选择一只机械族·光属性怪兽除外
	local g=Duel.SelectMatchingCard(tp,c12670770.filter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 准备阶段计数条件函数，判断是否为当前回合玩家
function c12670770.sdescon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 准备阶段计数操作函数，用于增加回合计数并在第3次时破坏此卡
function c12670770.sdesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		-- 在第3次准备阶段时破坏此卡
		Duel.Destroy(c,REASON_RULE)
	end
end
-- 特殊召唤条件函数，判断此卡是否从场上送去墓地
function c12670770.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 特殊召唤过滤函数，用于筛选可特殊召唤的机械族·光属性怪兽
function c12670770.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤费用函数，设置不能进行战斗阶段
function c12670770.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前回合玩家是否已进行过战斗阶段
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 创建并注册一个场地区域效果，禁止当前玩家进行战斗阶段
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册战斗阶段禁止效果
	Duel.RegisterEffect(e1,tp)
end
-- 设置特殊召唤目标函数，用于确定特殊召唤的怪兽
function c12670770.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 破坏过滤函数，用于筛选场上的魔法·陷阱卡
function c12670770.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 特殊召唤操作函数，用于执行特殊召唤和破坏操作
function c12670770.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取可特殊召唤的机械族·光属性怪兽组
	local tg=Duel.GetMatchingGroup(c12670770.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if ft<=0 or tg:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=tg:Select(tp,ft,ft,nil)
	local tc=g:GetFirst()
	while tc do
		-- 特殊召唤一张怪兽
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 创建并注册一个单体效果，使特殊召唤的怪兽不能发动效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
	-- 获取场上的魔法·陷阱卡组
	local dg=Duel.GetMatchingGroup(c12670770.desfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 破坏所有场上的魔法·陷阱卡
	Duel.Destroy(dg,REASON_EFFECT)
end
