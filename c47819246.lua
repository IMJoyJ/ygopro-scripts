--超量機神剣－マグナスレイヤー
-- 效果：
-- ①：以自己场上1只「超级量子」超量怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：这张卡装备的怪兽攻击力上升那只怪兽的阶级数值×100，向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：自己战斗阶段，把装备的这张卡送去墓地才能发动。这张卡装备过的怪兽在这个回合在同1次的战斗阶段中可以作3次攻击。
function c47819246.initial_effect(c)
	-- ①：以自己场上1只「超级量子」超量怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 限制效果不能在伤害计算后进行
	e1:SetCondition(aux.dscon)
	e1:SetCost(c47819246.cost)
	e1:SetTarget(c47819246.target)
	e1:SetOperation(c47819246.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡装备的怪兽攻击力上升那只怪兽的阶级数值×100，向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c47819246.atkval)
	c:RegisterEffect(e2)
	-- ②：这张卡装备的怪兽攻击力上升那只怪兽的阶级数值×100，向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	-- ③：自己战斗阶段，把装备的这张卡送去墓地才能发动。这张卡装备过的怪兽在这个回合在同1次的战斗阶段中可以作3次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(47819246,0))  --"3次攻击"
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c47819246.mtcon)
	e4:SetCost(c47819246.mtcost)
	e4:SetTarget(c47819246.mttg)
	e4:SetOperation(c47819246.mtop)
	c:RegisterEffect(e4)
end
-- 设置效果发动时的条件检查函数，用于判断是否满足发动时机
function c47819246.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 使此卡在发动后不会因其他效果被送入墓地
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
	e2:SetOperation(c47819246.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将效果e2注册给玩家tp
	Duel.RegisterEffect(e2,tp)
end
-- 当连锁被无效时，取消此卡进入墓地的操作
function c47819246.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 筛选场上表侧表示的「超级量子」超量怪兽
function c47819246.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xdc) and c:IsType(TYPE_XYZ)
end
-- 设置效果的目标选择函数
function c47819246.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c47819246.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 判断是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(c47819246.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c47819246.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理时的操作信息，包括装备卡的类别
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将此卡装备给目标怪兽
function c47819246.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- ②：这张卡装备的怪兽攻击力上升那只怪兽的阶级数值×100，向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c47819246.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	else
		c:CancelToGrave(false)
	end
end
-- 设置装备限制条件，确保只有特定怪兽可以装备此卡
function c47819246.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0xdc) and c:IsType(TYPE_XYZ)
end
-- 计算装备怪兽的攻击力提升值，为阶级数乘以100
function c47819246.atkval(e,c)
	return c:GetRank()*100
end
-- ③：自己战斗阶段，把装备的这张卡送去墓地才能发动。这张卡装备过的怪兽在这个回合在同1次的战斗阶段中可以作3次攻击。
function c47819246.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于己方战斗阶段且为装备状态
	return e:GetHandler():IsType(TYPE_EQUIP) and Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- ③：自己战斗阶段，把装备的这张卡送去墓地才能发动。这张卡装备过的怪兽在这个回合在同1次的战斗阶段中可以作3次攻击。
function c47819246.mtcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 设置此效果处理时的目标卡片
	Duel.SetTargetCard(c:GetEquipTarget())
	-- 将此卡送入墓地作为发动代价
	Duel.SendtoGrave(c,REASON_COST)
end
-- ③：自己战斗阶段，把装备的这张卡送去墓地才能发动。这张卡装备过的怪兽在这个回合在同1次的战斗阶段中可以作3次攻击。
function c47819246.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec and ec:IsControler(tp) and not ec:IsHasEffect(EFFECT_EXTRA_ATTACK) end
end
-- ③：自己战斗阶段，把装备的这张卡送去墓地才能发动。这张卡装备过的怪兽在这个回合在同1次的战斗阶段中可以作3次攻击。
function c47819246.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local ec=Duel.GetFirstTarget()
	if ec:IsLocation(LOCATION_MZONE) and ec:IsFaceup() and ec:IsRelateToEffect(e) then
		-- ③：自己战斗阶段，把装备的这张卡送去墓地才能发动。这张卡装备过的怪兽在这个回合在同1次的战斗阶段中可以作3次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		ec:RegisterEffect(e1)
	end
end
