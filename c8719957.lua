--アビスケイル－クラーケン
-- 效果：
-- 名字带有「水精鳞」的怪兽才能装备。装备怪兽的攻击力上升400。只要这张卡在场上存在，对方场上发动的效果怪兽的效果无效。那之后，这张卡送去墓地。
function c8719957.initial_effect(c)
	-- 名字带有「水精鳞」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c8719957.target)
	e1:SetOperation(c8719957.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升400。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(400)
	c:RegisterEffect(e2)
	-- 名字带有「水精鳞」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c8719957.eqlimit)
	c:RegisterEffect(e3)
	-- 只要这张卡在场上存在，对方场上发动的效果怪兽的效果无效。那之后，这张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c8719957.negcon)
	e4:SetOperation(c8719957.negop)
	c:RegisterEffect(e4)
end
-- 限制装备对象为名字带有「水精鳞」的怪兽
function c8719957.eqlimit(e,c)
	return c:IsSetCard(0x74)
end
-- 过滤场上表侧表示的名字带有「水精鳞」的怪兽
function c8719957.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x74)
end
-- 装备魔法卡发动时的效果处理，选择场上1只表侧表示的「水精鳞」怪兽作为装备对象
function c8719957.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c8719957.filter(chkc) end
	-- 检查场上是否存在可以作为装备对象的表侧表示的「水精鳞」怪兽
	if chk==0 then return Duel.IsExistingTarget(c8719957.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的「水精鳞」怪兽作为装备对象
	Duel.SelectTarget(tp,c8719957.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果的处理为将自身作为装备卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功时的效果处理，将自身装备给选择的怪兽
function c8719957.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 对方在场上发动效果怪兽的效果时，作为无效效果的触发条件
function c8719957.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方在怪兽区（场上）发动的效果
	return rp==1-tp and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE
		-- 检查发动效果的卡是否为怪兽，且该效果是否可以被无效
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 无效对方发动的怪兽效果，并将这张卡送去墓地
function c8719957.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功无效了该效果
	if Duel.NegateEffect(ev) then
		-- 将这张卡送去墓地
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
