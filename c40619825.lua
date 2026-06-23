--デーモンの斧
-- 效果：
-- ①：装备怪兽的攻击力上升1000。
-- ②：这张卡从场上送去墓地时，把自己场上1只怪兽解放才能发动。这张卡回到卡组最上面。
function c40619825.initial_effect(c)
	-- ①：装备怪兽的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c40619825.target)
	e1:SetOperation(c40619825.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：这张卡从场上送去墓地时，把自己场上1只怪兽解放才能发动。这张卡回到卡组最上面。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(40619825,0))  --"回到卡组的最上面"
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c40619825.tdcon)
	e4:SetCost(c40619825.tdcost)
	e4:SetTarget(c40619825.tdtg)
	e4:SetOperation(c40619825.tdop)
	c:RegisterEffect(e4)
end
-- 选择装备目标怪兽
function c40619825.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否满足装备目标条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择装备目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，记录装备效果
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡效果处理
function c40619825.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备目标
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断此卡是否从场上送去墓地
function c40619825.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 支付效果代价，解放场上1只怪兽
function c40619825.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 准备将此卡送回卡组
function c40619825.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置效果处理信息，记录送回卡组效果
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 将此卡送回卡组最上面
function c40619825.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡送回卡组最顶端
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
