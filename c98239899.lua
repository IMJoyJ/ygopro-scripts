--鎖付き爆弾
-- 效果：
-- ①：以自己场上1只表侧表示怪兽为对象才能把这张卡发动。这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
-- ②：当作装备卡使用的这张卡被效果破坏的场合，以场上1张卡为对象发动。那张卡破坏。
function c98239899.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能把这张卡发动。这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置发动条件：在伤害步骤中，只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c98239899.cost)
	e1:SetTarget(c98239899.target)
	e1:SetOperation(c98239899.operation)
	c:RegisterEffect(e1)
	-- ②：当作装备卡使用的这张卡被效果破坏的场合，以场上1张卡为对象发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98239899,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c98239899.descon)
	e2:SetTarget(c98239899.destg)
	e2:SetOperation(c98239899.desop)
	c:RegisterEffect(e2)
end
-- 发动代价（Cost）函数：处理陷阱卡发动时的留场及连锁无效时的送墓逻辑
function c98239899.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡当作攻击力上升500的装备卡使用
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只表侧表示怪兽为对象才能把这张卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c98239899.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册全局效果：用于在连锁被无效时将此卡送去墓地
	Duel.RegisterEffect(e2,tp)
end
-- 连锁无效时的处理函数：若此卡的发动被无效，则取消其留场状态并送去墓地
function c98239899.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发无效的连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：表侧表示的卡
function c98239899.filter(c)
	return c:IsFaceup()
end
-- 效果1的目标选择（Target）函数：验证并选择自己场上1只表侧表示怪兽作为装备对象
function c98239899.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c98239899.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在可以作为装备对象的表侧表示怪兽
		and Duel.IsExistingTarget(c98239899.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c98239899.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：此效果包含装备卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果1的运行（Operation）函数：将此卡装备给目标怪兽，并使其攻击力上升500
function c98239899.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 将此卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 攻击力上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 给那只自己怪兽装备。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(c98239899.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制函数：此卡只能装备给该怪兽或自己控制的怪兽
function c98239899.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c or c:IsControler(e:GetHandlerPlayer())
end
-- 效果2的发动条件：此卡作为装备卡被效果破坏
function c98239899.descon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41 and e:GetHandler():GetEquipTarget()~=nil
end
-- 效果2的目标选择（Target）函数：选择场上1张卡作为破坏对象
function c98239899.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上任意1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：此效果包含破坏卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果2的运行（Operation）函数：破坏选中的目标卡片
function c98239899.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要破坏的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
