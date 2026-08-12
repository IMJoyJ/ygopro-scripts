--剣の煌き
-- 效果：
-- 名字带有「X-剑士」的怪兽才能装备。装备怪兽战斗破坏对方怪兽的场合，可以把对方场上存在的1张卡破坏。此外，可以把自己场上存在的1只怪兽解放，自己墓地存在的这张卡回到卡组最上面。
function c48447192.initial_effect(c)
	-- 名字带有「X-剑士」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c48447192.target)
	e1:SetOperation(c48447192.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽战斗破坏对方怪兽的场合，可以把对方场上存在的1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(48447192,0))  --"对方场上存在的1张卡破坏"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c48447192.descon)
	e2:SetTarget(c48447192.destg)
	e2:SetOperation(c48447192.desop)
	c:RegisterEffect(e2)
	-- 此外，可以把自己场上存在的1只怪兽解放，自己墓地存在的这张卡回到卡组最上面。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c48447192.eqlimit)
	c:RegisterEffect(e3)
	-- 名字带有「X-剑士」的怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetDescription(aux.Stringid(48447192,1))  --"回到卡组最上面"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(c48447192.retcost)
	e4:SetTarget(c48447192.rettg)
	e4:SetOperation(c48447192.retop)
	c:RegisterEffect(e4)
end
-- 限制只能装备到名字带有「X-剑士」的怪兽上
function c48447192.eqlimit(e,c)
	return c:IsSetCard(0x100d)
end
-- 过滤出场上名字带有「X-剑士」的表侧表示怪兽
function c48447192.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x100d)
end
-- 选择场上名字带有「X-剑士」的表侧表示怪兽作为装备对象
function c48447192.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c48447192.filter(chkc) end
	-- 检查是否有名字带有「X-剑士」的表侧表示怪兽可以被选为装备对象
	if chk==0 then return Duel.IsExistingTarget(c48447192.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上名字带有「X-剑士」的表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,c48447192.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示将要进行装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给选中的怪兽
function c48447192.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 判断装备的怪兽是否在战斗破坏对方怪兽时触发效果
function c48447192.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and eg:IsContains(ec)
end
-- 选择对方场上的1张卡作为破坏对象
function c48447192.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可选的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，表示将要进行破坏操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏操作，破坏选中的对方场上卡
function c48447192.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 执行破坏操作，破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 支付解放怪兽的费用
function c48447192.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,aux.TRUE,1,nil) end
	-- 选择场上1只怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,1,1,nil)
	-- 将选中的怪兽解放作为效果的费用
	Duel.Release(g,REASON_COST)
end
-- 设置将卡送回卡组的效果处理信息
function c48447192.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置将卡送回卡组的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 执行将卡送回卡组的操作
function c48447192.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡送回卡组最上面
		Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
