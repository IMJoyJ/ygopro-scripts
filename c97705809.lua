--スーパーチャージ
-- 效果：
-- ①：自己场上的怪兽只有机械族「机人」怪兽的场合，对方怪兽的攻击宣言时才能发动。自己从卡组抽2张。
function c97705809.initial_effect(c)
	-- ①：自己场上的怪兽只有机械族「机人」怪兽的场合，对方怪兽的攻击宣言时才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c97705809.condition)
	e1:SetTarget(c97705809.target)
	e1:SetOperation(c97705809.activate)
	c:RegisterEffect(e1)
end
-- 过滤非表侧表示、非「机人」或非机械族的怪兽（用于判断场上是否存在不符合条件的怪兽）
function c97705809.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x16) or not c:IsRace(RACE_MACHINE)
end
-- 发动条件：对方回合的攻击宣言时，且自己场上存在怪兽，且这些怪兽必须全部是机械族「机人」怪兽
function c97705809.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合，且自己场上存在怪兽
	return Duel.GetTurnPlayer()~=tp and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)~=0
		-- 检查自己场上是否存在不满足机械族「机人」条件的怪兽（若不存在，则说明只有机械族「机人」怪兽）
		and not Duel.IsExistingMatchingCard(c97705809.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的目标选择：检查自己是否能抽2张卡，并设置抽卡玩家和抽卡数量
function c97705809.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己是否能从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为：玩家从卡组抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：获取设定的目标玩家和抽卡数量，执行抽卡操作
function c97705809.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
