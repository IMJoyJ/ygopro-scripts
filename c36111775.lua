--ペンデュラム・ホルト
-- 效果：
-- ①：自己的额外卡组有表侧表示的灵摆怪兽3种类以上存在的场合才能发动。自己从卡组抽2张。这张卡的发动后，直到回合结束时自己不能从卡组把卡加入手卡。
function c36111775.initial_effect(c)
	-- ①：自己的额外卡组有表侧表示的灵摆怪兽3种类以上存在的场合才能发动。自己从卡组抽2张。这张卡的发动后，直到回合结束时自己不能从卡组把卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c36111775.condition)
	e1:SetTarget(c36111775.target)
	e1:SetOperation(c36111775.activate)
	c:RegisterEffect(e1)
end
-- 筛选满足条件的卡：必须是表侧表示且为灵摆怪兽，用于检查额外卡组中符合条件的灵摆怪兽。
function c36111775.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 发动条件判定：获取自己额外卡组中满足条件的灵摆怪兽，按卡名统计种类数，若种类数达到3种以上则满足发动条件。
function c36111775.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己额外卡组中所有表侧表示的灵摆怪兽的集合，作为后续种类数统计的基础。
	local g=Duel.GetMatchingGroup(c36111775.filter,tp,LOCATION_EXTRA,0,nil)
	return g:GetClassCount(Card.GetCode)>=3
end
-- 效果发动时的目标与合法性处理：确认自己可以抽2张卡，将连锁的目标玩家设为自己，抽卡数设为2，并声明本效果为抽卡效果。
function c36111775.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时点（chk==0）检查自己是否能够抽2张卡，若不能则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的效果对象玩家设置为自己，表示后续抽卡操作的对象是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果参数设置为2，表示后续抽卡的数量为2张。
	Duel.SetTargetParam(2)
	-- 设置操作信息，声明本连锁包含抽卡效果，目标玩家为自己，预计抽卡数为2张。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理阶段：按照连锁信息让目标玩家抽2张，然后给自己附加本回合“不能从卡组把卡加入手卡”的限制（分别通过不能加入手卡和不能抽卡两个效果实现）。
function c36111775.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设置的目标玩家和抽卡数量，分别赋给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家p以效果原因抽取d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不能从卡组把卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 将该限制效果的作用对象限定为位于卡组中的卡，即卡组中的卡不能被加入手卡。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把“不能从卡组把卡加入手卡”的限制效果注册给自己，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	-- 这张卡的发动后，直到回合结束时自己不能从卡组把卡加入手卡。（对抽卡动作的限制部分）
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 把“不能抽卡”的限制效果注册给自己，持续到回合结束，以阻止通过抽卡从卡组加入手卡。
	Duel.RegisterEffect(e2,tp)
end
