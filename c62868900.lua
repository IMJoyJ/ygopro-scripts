--D－シールド
-- 效果：
-- 自己场上攻击表示存在的名字带有「命运英雄」的怪兽成为攻击对象时才能发动。这张卡变成装备卡，把成为攻击对象的怪兽变成守备表示并装备这张卡。装备怪兽不会被战斗破坏。
function c62868900.initial_effect(c)
	-- 自己场上攻击表示存在的名字带有「命运英雄」的怪兽成为攻击对象时才能发动。这张卡变成装备卡，把成为攻击对象的怪兽变成守备表示并装备这张卡。装备怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c62868900.condition)
	e1:SetCost(c62868900.cost)
	e1:SetTarget(c62868900.target)
	e1:SetOperation(c62868900.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：检查成为攻击对象的怪兽是否为自己场上表侧攻击表示的「命运英雄」怪兽，且可以改变表示形式
function c62868900.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(tp) and tc:IsPosition(POS_FACEUP_ATTACK) and tc:IsCanChangePosition() and tc:IsSetCard(0xc008)
end
-- 发动代价：使此卡在发动后留在场上作为装备卡，并注册连锁被无效时防止送去墓地的效果
function c62868900.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡变成装备卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 这张卡变成装备卡，把成为攻击对象的怪兽变成守备表示并装备这张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c62868900.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册全局效果，用于在连锁被无效时处理该卡不送去墓地
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理：如果该卡仍与该连锁相关，则取消送去墓地（使其留在场上）
function c62868900.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 效果靶向：检查并设定成为攻击对象的怪兽为效果对象，并声明装备分类的操作信息
function c62868900.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc==eg:GetFirst() end
	if chk==0 then return e:IsCostChecked()
		and eg:GetFirst():IsCanBeEffectTarget(e) end
	-- 将成为攻击对象的怪兽设为当前连锁的效果对象
	Duel.SetTargetCard(eg)
	-- 设置当前连锁的操作信息为：将自身作为装备卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：将对象怪兽变成表侧守备表示，并将这张卡作为装备卡装备给该怪兽，赋予其战破抗性
function c62868900.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	-- 获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将对象怪兽变成表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给对象怪兽
		Duel.Equip(tp,c,tc)
		-- 装备怪兽不会被战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 并装备这张卡。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(c62868900.eqlimit)
		e2:SetLabelObject(tc)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制：此卡只能装备给作为此卡效果对象的怪兽
function c62868900.eqlimit(e,c)
	return c==e:GetLabelObject()
end
