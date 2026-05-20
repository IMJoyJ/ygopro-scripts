--パワーアップ・コネクター
-- 效果：
-- 发动后这张卡变成装备卡，给自己场上表侧表示存在的1只名字带有「变形斗士」的怪兽装备。装备怪兽不能攻击。被这个效果装备时，选择装备怪兽以外的场上表侧表示存在的1只怪兽。选择的怪兽的攻击力上升装备怪兽的攻击力数值。
function c78586116.initial_effect(c)
	-- 发动后这张卡变成装备卡，给自己场上表侧表示存在的1只名字带有「变形斗士」的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c78586116.cost)
	e1:SetTarget(c78586116.target)
	e1:SetOperation(c78586116.operation)
	c:RegisterEffect(e1)
	-- 被这个效果装备时，选择装备怪兽以外的场上表侧表示存在的1只怪兽。选择的怪兽的攻击力上升装备怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetDescription(aux.Stringid(78586116,0))  --"攻击上升"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_CUSTOM+78586116)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c78586116.attg)
	e2:SetOperation(c78586116.atop)
	c:RegisterEffect(e2)
end
-- 装备魔法卡发动时的Cost处理，用于处理卡片留在场上以及发动被无效时的送墓规则
function c78586116.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 发动后这张卡变成装备卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 发动后这张卡变成装备卡，给自己场上表侧表示存在的1只名字带有「变形斗士」的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c78586116.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册用于处理连锁被无效时将卡片送去墓地的全局效果
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的效果处理，取消该卡送去墓地的状态（使其正常送去墓地）
function c78586116.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发事件的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤自己场上表侧表示的「变形斗士」怪兽
function c78586116.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x26)
end
-- 装备魔法卡发动时的效果对象选择与发动准备
function c78586116.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c78586116.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在可以作为装备对象的表侧表示「变形斗士」怪兽
		and Duel.IsExistingTarget(c78586116.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「变形斗士」怪兽作为装备对象
	Duel.SelectTarget(tp,c78586116.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的效果处理，将此卡装备给目标怪兽并赋予相关效果
function c78586116.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 装备怪兽不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 给自己场上表侧表示存在的1只名字带有「变形斗士」的怪兽装备。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(c78586116.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 触发自定义事件，用于触发“被这个效果装备时”的效果
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+78586116,e,0,0,0,0)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制条件：只能装备在自己场上的表侧表示「变形斗士」怪兽上
function c78586116.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x26)
end
-- 触发效果的对象选择，选择装备怪兽以外的场上1只表侧表示怪兽
function c78586116.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local eq=e:GetHandler():GetEquipTarget()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=eq end
	-- 检查场上是否存在除装备怪兽以外的表侧表示怪兽
	if chk==0 then return eq and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,eq) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择装备怪兽以外的场上1只表侧表示怪兽作为对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,eq)
end
-- 触发效果的效果处理，使选择的怪兽攻击力上升装备怪兽的攻击力数值
function c78586116.atop(e,tp,eg,ep,ev,re,r,rp)
	local eq=e:GetHandler():GetEquipTarget()
	if not eq then return end
	-- 获取选择的攻击力上升的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的怪兽的攻击力上升装备怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(eq:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
