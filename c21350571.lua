--幻獣の角
-- 效果：
-- 发动后这张卡变成攻击力上升800的装备卡，给自己场上存在的1只兽族·兽战士族怪兽装备。装备怪兽战斗破坏对方怪兽送去墓地时，从自己卡组抽1张卡。
function c21350571.initial_effect(c)
	-- 发动后这张卡变成攻击力上升800的装备卡，给自己场上存在的1只兽族·兽战士族怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetCost(c21350571.cost)
	e1:SetTarget(c21350571.target)
	e1:SetOperation(c21350571.operation)
	c:RegisterEffect(e1)
end
-- 设置此卡在发动时不会被无效，并在连锁被无效时取消其送入墓地
function c21350571.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 设置此卡发动后在场上停留
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 注册一个连锁被无效时的处理效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c21350571.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将效果注册给当前玩家
	Duel.RegisterEffect(e2,tp)
end
-- 当连锁被无效时，如果该连锁是当前效果的连锁，则取消其送入墓地
function c21350571.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效连锁的ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 筛选场上正面表示的兽族或兽战士族怪兽
function c21350571.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR)
end
-- 判断是否满足发动条件，即场上存在符合条件的怪兽
function c21350571.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c21350571.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 判断是否满足发动条件，即场上存在符合条件的怪兽
		and Duel.IsExistingTarget(c21350571.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c21350571.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示将装备卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给目标怪兽
function c21350571.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 装备怪兽战斗破坏对方怪兽送去墓地时，从自己卡组抽1张卡
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCategory(CATEGORY_DRAW)
		e1:SetDescription(aux.Stringid(21350571,0))  --"抽卡"
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EVENT_BATTLE_DESTROYED)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCondition(c21350571.drcon)
		e1:SetTarget(c21350571.drtg)
		e1:SetOperation(c21350571.drop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 装备怪兽的攻击力上升800
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(800)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 限制只能装备给指定的怪兽
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(c21350571.eqlimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	else
		c:CancelToGrave(false)
	end
end
-- 设置装备限制条件，只能装备给装备怪兽或己方的兽族/兽战士族怪兽
function c21350571.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR)
end
-- 筛选被战斗破坏送入墓地的卡片
function c21350571.drfilter(c,rc)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc
end
-- 判断被战斗破坏的卡片是否为装备怪兽所破坏
function c21350571.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c21350571.drfilter,1,nil,e:GetHandler():GetEquipTarget())
end
-- 设置抽卡效果的目标玩家和抽卡数量
function c21350571.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的目标参数为1
	Duel.SetTargetParam(1)
	-- 设置效果处理信息，表示将从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡操作，从卡组抽1张卡
function c21350571.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，从卡组抽1张卡
	Duel.Draw(p,d,REASON_EFFECT)
end
