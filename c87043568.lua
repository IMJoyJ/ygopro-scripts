--アサルト・スピリッツ
-- 效果：
-- 发动后这张卡变成装备卡，给自己场上存在的1只怪兽装备。装备怪兽攻击的场合，那次伤害步骤时可以从手卡把1只攻击力1000以下的怪兽送去墓地，装备怪兽的攻击力直到结束阶段时上升送去墓地的怪兽的攻击力数值。这个效果1回合只能使用1次。
function c87043568.initial_effect(c)
	-- 发动后这张卡变成装备卡，给自己场上存在的1只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c87043568.cost)
	e1:SetTarget(c87043568.target)
	e1:SetOperation(c87043568.operation)
	c:RegisterEffect(e1)
end
-- 卡片发动时的Cost处理，注册该卡发动后留在场上以及连锁被无效时送去墓地的效果
function c87043568.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前发动的连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 发动后这张卡变成装备卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 发动后这张卡变成装备卡，给自己场上存在的1只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c87043568.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册用于处理连锁被无效时将卡片送去墓地的全局效果
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的效果处理：如果该卡因连锁被无效而无法留在场上，则将其送去墓地
function c87043568.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 卡片发动时的效果处理：检查场上是否存在可以装备的怪兽，并选择1只怪兽作为装备对象
function c87043568.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在表侧表示的怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置选择装备对象的提示信息为‘请选择要装备的卡’
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息为：将这张卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 卡片发动时的效果处理：将这张卡装备给选择的怪兽，并注册装备怪兽攻击时可以上升攻击力的效果
function c87043568.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 装备怪兽攻击的场合，那次伤害步骤时可以从手卡把1只攻击力1000以下的怪兽送去墓地，装备怪兽的攻击力直到结束阶段时上升送去墓地的怪兽的攻击力数值。这个效果1回合只能使用1次。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(87043568,0))  --"攻击上升"
		e1:SetCategory(CATEGORY_ATKCHANGE)
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetHintTiming(TIMING_DAMAGE_STEP)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		e1:SetCondition(c87043568.atkcon)
		e1:SetCost(c87043568.atkcost)
		e1:SetOperation(c87043568.atkop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 给自己场上存在的1只怪兽装备
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(c87043568.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制：只能装备给自己场上的怪兽
function c87043568.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c or c:IsControler(e:GetHandlerPlayer())
end
-- 攻击力上升效果的发动条件：装备怪兽进行攻击的伤害步骤内，且未进行伤害计算时
function c87043568.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return a==e:GetHandler():GetEquipTarget()
		-- 判定当前处于伤害步骤，且尚未进行伤害计算
		and ph==PHASE_DAMAGE and not Duel.IsDamageCalculated()
end
-- 过滤条件：手卡中攻击力1000以下且能送去墓地的怪兽
function c87043568.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttackBelow(1000) and c:IsAbleToGraveAsCost()
end
-- 攻击力上升效果的Cost处理：从手卡选择1只攻击力1000以下的怪兽送去墓地，并记录其攻击力
function c87043568.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c87043568.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置选择送去墓地的卡的提示信息为‘请选择要送去墓地的卡’
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c87043568.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetAttack())
	-- 将选择的怪兽作为Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 攻击力上升效果的操作处理：使装备怪兽的攻击力直到结束阶段时上升送去墓地的怪兽的攻击力数值
function c87043568.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前进行攻击的怪兽
	local a=Duel.GetAttacker()
	if c:IsRelateToEffect(e) and a:IsRelateToBattle() and a:IsFaceup() then
		-- 装备怪兽的攻击力直到结束阶段时上升送去墓地的怪兽的攻击力数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(e:GetLabel())
		a:RegisterEffect(e1)
	end
end
