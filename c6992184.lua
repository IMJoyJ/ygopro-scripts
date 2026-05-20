--ペンデュラム・アンコール
--not fully implemented
-- 效果：
-- （注：暂时无法正常使用）
-- 
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方主要阶段，丢弃1张手卡才能发动。把灵摆怪兽灵摆召唤。这个回合，自己的灵摆区域的卡不能把效果发动，不会被自己的卡的效果破坏，结束阶段回到持有者卡组。
function c6992184.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：对方主要阶段，丢弃1张手卡才能发动。把灵摆怪兽灵摆召唤。这个回合，自己的灵摆区域的卡不能把效果发动，不会被自己的卡的效果破坏，结束阶段回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,6992184+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c6992184.condition)
	e1:SetCost(c6992184.cost)
	e1:SetTarget(c6992184.target)
	e1:SetOperation(c6992184.activate)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
end
-- 判定发动条件：对方的主要阶段1或主要阶段2
function c6992184.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
		-- 判定当前阶段是否为主要阶段1或主要阶段2
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 检查当前是否满足进行灵摆召唤的条件（排除指定卡片后）
function c6992184.check(e,tp,exc)
	-- 获取自己左侧灵摆区域的卡片（用于确定灵摆刻度）
	local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	if lpz==nil then return false end
	-- 获取自己手牌和额外卡组中除排除卡以外的所有灵摆怪兽
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND+LOCATION_EXTRA,0,exc,TYPE_PENDULUM)
	if #g==0 then return false end
	-- 调用系统函数判定当前是否可以对这些灵摆怪兽进行灵摆召唤
	return aux.PendCondition(e,lpz,g)
end
-- 过滤可以作为丢弃代价且丢弃后仍能满足灵摆召唤条件的手牌
function c6992184.cfilter(c,e,tp)
	return c:IsDiscardable() and c6992184.check(e,tp,c)
end
-- 发动代价处理：检查并丢弃1张手牌
function c6992184.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetLabel(100)
		-- 检查手牌或额外卡组是否存在至少1张灵摆怪兽
		if not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,TYPE_PENDULUM)
			-- 检查自己的灵摆区域是否放满了2张卡（必须有2张卡才能确定灵摆刻度）
			or Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)<2 then return false end
		-- 检查手牌中是否存在可以作为代价丢弃且丢弃后仍能进行灵摆召唤的卡
		return Duel.IsExistingMatchingCard(c6992184.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- 让玩家选择并丢弃1张满足条件的手牌
	Duel.DiscardHand(tp,c6992184.cfilter,1,1,REASON_COST+REASON_DISCARD,nil,e,tp)
end
-- 效果的目标处理：在发动时进行灵摆召唤可行性检测
function c6992184.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==100 then
			e:SetLabel(0)
			return true
		end
		return c6992184.check(e,tp,nil)
	end
	e:SetLabel(0)
end
-- 效果的处理核心：注册限制效果并执行灵摆召唤
function c6992184.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local c=e:GetHandler()
		-- 这个回合，自己的灵摆区域的卡不能把效果发动，不会被自己的卡的效果破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetTargetRange(LOCATION_PZONE,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册“自己的灵摆区域的卡不能把效果发动”的全局效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		-- 设置不会被自己卡的效果破坏的过滤条件
		e2:SetValue(aux.indsval)
		-- 注册“自己的灵摆区域的卡不会被自己的卡的效果破坏”的全局效果
		Duel.RegisterEffect(e2,tp)
		-- 把灵摆怪兽灵摆召唤。这个回合，自己的灵摆区域的卡...结束阶段回到持有者卡组。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCountLimit(1)
		e3:SetOperation(c6992184.retop)
		-- 注册“结束阶段灵摆区域的卡回到持有者卡组”的延迟触发效果
		Duel.RegisterEffect(e3,tp)
	end
	-- 获取自己左侧灵摆区域的卡片以确定灵摆刻度
	local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	if lpz==nil then return end
	-- 获取手牌和额外卡组中所有的灵摆怪兽
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND+LOCATION_EXTRA,0,nil,TYPE_PENDULUM)
	if #g==0 then return end
	local sg=Group.CreateGroup()
	-- 调用系统函数让玩家选择要进行灵摆召唤的怪兽
	aux.PendOperation(e,tp,eg,ep,ev,re,r,rp,lpz,sg,g)
	-- 触发灵摆召唤成功的相关事件时点
	Duel.RaiseEvent(sg,EVENT_SPSUMMON_SUCCESS_G_P,e,REASON_EFFECT,tp,tp,0)
	-- 将选中的怪兽以灵摆召唤的方式特殊召唤到场上
	Duel.SpecialSummon(sg,SUMMON_TYPE_PENDULUM,tp,tp,true,true,POS_FACEUP)
end
-- 结束阶段将灵摆区域的卡送回卡组的处理函数
function c6992184.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己灵摆区域的所有卡片
	local tg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 将灵摆区域的卡片洗回持有者的卡组
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
