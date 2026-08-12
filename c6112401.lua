--身剣一体
-- 效果：
-- 自己场上存在的怪兽只有表侧表示的名字带有「X-剑士」的怪兽1只的场合才能发动。发动后这张卡变成攻击力上升800的装备卡，给那1只怪兽装备。装备怪兽战斗破坏对方怪兽的场合，从自己卡组抽1张卡。
function c6112401.initial_effect(c)
	-- 自己场上存在的怪兽只有表侧表示的名字带有「X-剑士」的怪兽1只的场合才能发动。发动后这张卡变成攻击力上升800的装备卡，给那1只怪兽装备。装备怪兽战斗破坏对方怪兽的场合，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c6112401.condition)
	e1:SetCost(c6112401.cost)
	e1:SetTarget(c6112401.target)
	e1:SetOperation(c6112401.operation)
	c:RegisterEffect(e1)
end
-- 定义发动条件：检查自己场上是否仅存在1只表侧表示的「X-剑士」怪兽，并暂存该怪兽
function c6112401.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 在伤害步骤中，如果已经计算过战斗伤害，则不能发动此卡
	if Duel.GetCurrentPhase()==PHASE_DAMAGE and Duel.IsDamageCalculated() then return false end
	-- 获取自己场上怪兽区域的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return g:GetCount()==1 and tc:IsFaceup() and tc:IsSetCard(0x100d)
end
-- 定义发动代价：设置此卡发动后留在场上，并注册连锁被无效时送去墓地的辅助效果
function c6112401.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 发动后这张卡变成...装备卡，给那1只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 发动后这张卡变成...装备卡，给那1只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c6112401.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册连锁无效时将此卡送去墓地的全局效果
	Duel.RegisterEffect(e2,tp)
end
-- 定义连锁无效时的处理：如果此卡的发动被无效，则取消留在场上的状态，正常送去墓地
function c6112401.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 定义效果的目标：以之前暂存的那1只「X-剑士」怪兽为对象，并设置装备效果的操作信息
function c6112401.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:IsCostChecked()
		and e:GetLabelObject():IsCanBeEffectTarget(e) end
	-- 将暂存的「X-剑士」怪兽设为当前连锁的对象
	Duel.SetTargetCard(e:GetLabelObject())
	-- 设置操作信息：将这张卡作为装备卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 定义效果处理：将此卡装备给目标怪兽，并赋予其攻击力上升和战斗破坏抽卡的效果
function c6112401.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 装备怪兽战斗破坏对方怪兽的场合，从自己卡组抽1张卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCategory(CATEGORY_DRAW)
		e1:SetDescription(aux.Stringid(6112401,0))  --"抽卡"
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCondition(c6112401.drcon)
		e1:SetTarget(c6112401.drtg)
		e1:SetOperation(c6112401.drop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 攻击力上升800
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(800)
		c:RegisterEffect(e2)
		-- 给那1只怪兽装备。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(c6112401.eqlimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	else
		c:CancelToGrave(false)
	end
end
-- 定义装备限制：只能装备给当前已装备的怪兽，且该怪兽必须是场上唯一的表侧表示「X-剑士」怪兽
function c6112401.eqlimit(e,c)
	if e:GetHandler():GetEquipTarget()==c then return true end
	-- 获取装备卡持有者场上的所有怪兽
	local g=Duel.GetFieldGroup(e:GetHandlerPlayer(),LOCATION_MZONE,0)
	local tc=g:GetFirst()
	return g:GetCount()==1 and tc==c and c:IsSetCard(0x100d)
end
-- 定义抽卡效果的发动条件：被战斗破坏的怪兽是由装备怪兽所破坏
function c6112401.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler():GetEquipTarget())
end
-- 定义抽卡效果的触发目标：设置抽卡玩家为自己，抽卡数量为1张，并设置抽卡的操作信息
function c6112401.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的对象参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置操作信息：玩家从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义抽卡效果的处理：执行抽卡操作
function c6112401.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
