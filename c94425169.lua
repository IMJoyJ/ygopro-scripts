--エレメントの泉
-- 效果：
-- 场上的怪兽回到持有者手卡的场合，每1次自己回复500基本分。
function c94425169.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上的怪兽回到持有者手卡的场合，每1次自己回复500基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c94425169.condition)
	e2:SetTarget(c94425169.target)
	e2:SetOperation(c94425169.operation)
	c:RegisterEffect(e2)
end
-- 过滤出原本在场上且是怪兽的卡片（即从场上回到手卡的怪兽）
function c94425169.filter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsType(TYPE_MONSTER)
end
-- 检查回到手卡的卡片中是否存在满足过滤条件的怪兽
function c94425169.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c94425169.filter,1,nil)
end
-- 设置回复效果的对象玩家为自己，回复数值为500，并向系统宣告该回复操作
function c94425169.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己（发动效果的玩家）
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为500（回复的基本分数）
	Duel.SetTargetParam(500)
	-- 设置当前连锁的操作信息，宣告此效果包含“自己回复500基本分”的操作
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 获取连锁信息中的对象玩家和回复数值，并执行回复基本分的操作
function c94425169.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和对象参数（回复数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复对应的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
