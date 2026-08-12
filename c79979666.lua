--E・HERO バブルマン
-- 效果：
-- ①：手卡只有这1张卡的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·反转召唤·特殊召唤时才能发动（这个效果在自己的手卡·场上没有其他卡存在的场合才能发动和处理）。自己抽2张。
function c79979666.initial_effect(c)
	-- ①：手卡只有这1张卡的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c79979666.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·反转召唤·特殊召唤时才能发动（这个效果在自己的手卡·场上没有其他卡存在的场合才能发动和处理）。自己抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79979666,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c79979666.condition)
	e2:SetTarget(c79979666.target)
	e2:SetOperation(c79979666.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 特殊召唤规则的条件函数：检查手牌数量是否为1且怪兽区域是否有空位
function c79979666.spcon(e,c)
	if c==nil then return true end
	-- 检查自身手牌数量是否刚好为1张（即只有这张卡自身）
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)==1
		-- 检查自身怪兽区域是否有可用的空位
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 过滤函数：过滤掉处于“确认离开场上”状态的卡片（如即将送去墓地的通常魔法/通常陷阱卡）
function c79979666.filter(c)
	return not c:IsStatus(STATUS_LEAVE_CONFIRMED)
end
-- 抽卡效果的发动条件：检查自己手卡和场上除了这张卡以外是否没有其他卡
function c79979666.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己手卡和场上是否存在除这张卡以外的卡（排除即将离场的卡）
	return not Duel.IsExistingMatchingCard(c79979666.filter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler())
end
-- 抽卡效果的靶向与发动准备函数：检查是否能抽卡，并设置效果的对象玩家、抽卡数量及操作信息
function c79979666.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否具有抽2张卡的能力
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的对象玩家设置为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为：玩家tp抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 抽卡效果的执行函数：在效果处理时再次检查条件，若满足则执行抽卡
function c79979666.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，如果自己手卡或场上存在除这张卡以外的其他卡，则不处理效果
	if Duel.IsExistingMatchingCard(c79979666.filter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler()) then return end
	-- 获取当前连锁设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
