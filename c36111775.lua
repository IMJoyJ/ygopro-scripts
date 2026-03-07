--ペンデュラム・ホルト
-- 效果：
-- ①：自己的额外卡组有表侧表示的灵摆怪兽3种类以上存在的场合才能发动。自己从卡组抽2张。这张卡的发动后，直到回合结束时自己不能从卡组把卡加入手卡。
function c36111775.initial_effect(c)
	-- 效果原文内容：①：自己的额外卡组有表侧表示的灵摆怪兽3种类以上存在的场合才能发动。自己从卡组抽2张。这张卡的发动后，直到回合结束时自己不能从卡组把卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c36111775.condition)
	e1:SetTarget(c36111775.target)
	e1:SetOperation(c36111775.activate)
	c:RegisterEffect(e1)
end
-- 规则层面操作：定义一个过滤函数，用于筛选表侧表示的灵摆怪兽
function c36111775.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 规则层面操作：判断玩家额外卡组中是否存在至少3种不同的表侧表示灵摆怪兽
function c36111775.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取玩家额外卡组中所有表侧表示的灵摆怪兽
	local g=Duel.GetMatchingGroup(c36111775.filter,tp,LOCATION_EXTRA,0,nil)
	return g:GetClassCount(Card.GetCode)>=3
end
-- 规则层面操作：设置效果的发动条件，检查玩家是否可以抽2张卡
function c36111775.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断在当前连锁处理阶段中是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 规则层面操作：设置效果的目标玩家为当前处理效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 规则层面操作：设置效果的目标参数为2（表示抽2张卡）
	Duel.SetTargetParam(2)
	-- 规则层面操作：设置效果操作信息为抽卡效果，目标玩家为当前玩家，抽卡数量为2
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 规则层面操作：执行效果的发动处理，包括抽卡并设置后续不能抽卡和不能加入手牌的效果
function c36111775.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁的目标玩家和目标参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面操作：让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 效果原文内容：这张卡的发动后，直到回合结束时自己不能从卡组把卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 规则层面操作：设置效果目标为位于卡组中的卡
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面操作：将效果注册到指定玩家的场上
	Duel.RegisterEffect(e1,tp)
	-- 效果原文内容：这张卡的发动后，直到回合结束时自己不能从卡组把卡加入手卡。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面操作：将效果注册到指定玩家的场上
	Duel.RegisterEffect(e2,tp)
end
