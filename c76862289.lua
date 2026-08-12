--八俣大蛇
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡给与对方战斗伤害的场合发动。自己直到手卡变成5张为止从卡组抽卡。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c76862289.initial_effect(c)
	-- 使用辅助函数注册灵魂怪兽在召唤、翻转的回合结束阶段回到持有者手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为恒不满足，从而实现不能特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：这张卡给与对方战斗伤害的场合发动。自己直到手卡变成5张为止从卡组抽卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(76862289,1))  --"抽卡"
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(c76862289.drcon)
	e4:SetTarget(c76862289.drtg)
	e4:SetOperation(c76862289.drop)
	c:RegisterEffect(e4)
end
-- 判断受到战斗伤害的是否为对方玩家
function c76862289.drcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 抽卡效果的发动准备，设置目标玩家并根据当前手卡数量设置抽卡的操作信息
function c76862289.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 获取自己手卡数量
	local ht=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if ht<5 then
		-- 设置操作信息为抽卡，数量为5减去当前手卡数
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,5-ht)
	end
end
-- 抽卡效果的实际处理，使目标玩家抽卡直到手卡变成5张
function c76862289.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取目标玩家当前的手卡数量
	local ht=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
	if ht<5 then
		-- 让目标玩家因效果抽卡，抽卡数量为5减去当前手卡数
		Duel.Draw(p,5-ht,REASON_EFFECT)
	end
end
