--野生の咆哮
-- 效果：
-- 自己场上存在的怪兽战斗破坏对方怪兽送去墓地时，自己场上表侧表示存在的兽族怪兽每有1只给与对方基本分300分伤害。
function c97922283.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上存在的怪兽战斗破坏对方怪兽送去墓地时，自己场上表侧表示存在的兽族怪兽每有1只给与对方基本分300分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97922283,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c97922283.condition)
	e2:SetTarget(c97922283.target)
	e2:SetOperation(c97922283.operation)
	c:RegisterEffect(e2)
end
-- 判断触发条件：自己场上的怪兽战斗破坏对方怪兽并送去墓地
function c97922283.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return tc:IsRelateToBattle() and tc:IsControler(tp)
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE) and bc:IsType(TYPE_MONSTER)
end
-- 过滤条件：自己场上表侧表示的兽族怪兽
function c97922283.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
-- 效果发动的目标：设置对方为伤害对象，并根据自己场上表侧表示的兽族怪兽数量计算并设置伤害数值
function c97922283.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置对方玩家为受到伤害的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 计算伤害值：自己场上表侧表示的兽族怪兽数量 × 300
	local dam=Duel.GetMatchingGroupCount(c97922283.filter,tp,LOCATION_MZONE,0,nil)*300
	-- 设置伤害数值为效果处理的对象参数
	Duel.SetTargetParam(dam)
	-- 设置操作信息为给与对方玩家指定数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理：获取对象玩家，并根据当前场上表侧表示的兽族怪兽数量给与对方伤害
function c97922283.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家（即对方玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算当前自己场上表侧表示的兽族怪兽数量对应的伤害值
	local dam=Duel.GetMatchingGroupCount(c97922283.filter,tp,LOCATION_MZONE,0,nil)*300
	-- 因效果给与对象玩家对应的伤害
	Duel.Damage(p,dam,REASON_EFFECT)
end
