--ブレイク・ドロー
-- 效果：
-- 机械族怪兽才能装备。装备怪兽战斗破坏对方怪兽送去墓地时，从自己卡组抽1张卡。这张卡在发动后第3次的自己的结束阶段时破坏。
function c63851864.initial_effect(c)
	-- 机械族怪兽才能装备。这张卡在发动后第3次的自己的结束阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c63851864.target)
	e1:SetOperation(c63851864.operation)
	c:RegisterEffect(e1)
	-- 机械族怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c63851864.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽战斗破坏对方怪兽送去墓地时，从自己卡组抽1张卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63851864,0))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c63851864.drcon)
	e3:SetTarget(c63851864.drtg)
	e3:SetOperation(c63851864.drop)
	c:RegisterEffect(e3)
end
-- 装备限制：只能装备给机械族怪兽
function c63851864.eqlimit(e,c)
	return c:IsRace(RACE_MACHINE)
end
-- 过滤条件：场上表侧表示的机械族怪兽
function c63851864.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 装备魔法卡发动时的效果处理，选择装备对象并注册发动后第3个自己结束阶段破坏的效果
function c63851864.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c63851864.filter(chkc) end
	-- 检查场上是否存在可以装备的表侧表示机械族怪兽
	if chk==0 then return Duel.IsExistingTarget(c63851864.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local c=e:GetHandler()
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的机械族怪兽作为装备对象
	Duel.SelectTarget(tp,c63851864.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	-- 这张卡在发动后第3次的自己的结束阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c63851864.descon)
	e1:SetOperation(c63851864.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,3)
	c:SetTurnCounter(0)
	c:RegisterEffect(e1)
end
-- 装备魔法卡发动成功时的效果处理，将此卡装备给目标怪兽
function c63851864.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 破坏效果的触发条件：当前回合是自己的回合
function c63851864.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 破坏效果的执行：在结束阶段增加回合计数器，达到3次时破坏此卡
function c63851864.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		-- 因效果破坏这张卡
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 抽卡效果的触发条件：装备怪兽战斗破坏对方怪兽并送去墓地
function c63851864.drcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	return e:GetHandler():GetEquipTarget()==eg:GetFirst() and ec:IsControler(tp)
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
end
-- 抽卡效果的靶向处理：设置抽卡玩家和抽卡数量
function c63851864.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置抽卡效果的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为1张
	Duel.SetTargetParam(1)
	-- 设置操作信息为玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的执行：从自己卡组抽1张卡
function c63851864.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取抽卡效果的对象玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
