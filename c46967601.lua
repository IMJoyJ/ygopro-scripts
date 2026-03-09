--呪いのお札
-- 效果：
-- 装备怪兽被破坏让这张卡送去墓地时，给与装备怪兽的控制者基本分送去墓地的装备怪兽的原本守备力数值的伤害。
function c46967601.initial_effect(c)
	-- 装备怪兽被破坏让这张卡送去墓地时，给与装备怪兽的控制者基本分送去墓地的装备怪兽的原本守备力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c46967601.target)
	e1:SetOperation(c46967601.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽被破坏让这张卡送去墓地时，给与装备怪兽的控制者基本分送去墓地的装备怪兽的原本守备力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 装备怪兽被破坏让这张卡送去墓地时，给与装备怪兽的控制者基本分送去墓地的装备怪兽的原本守备力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46967601,0))  --"LP伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c46967601.damcon)
	e3:SetTarget(c46967601.damtg)
	e3:SetOperation(c46967601.damop)
	c:RegisterEffect(e3)
end
-- 选择一个对方场上的表侧表示怪兽作为装备对象。
function c46967601.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在至少1只表侧表示的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一只对方场上的表侧表示怪兽作为装备对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理时将要装备的卡片信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 将装备卡装备给选中的怪兽。
function c46967601.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡片。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断是否满足发动条件：装备卡因失去装备对象而送去墓地，且装备的怪兽在墓地且被破坏。
function c46967601.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	if not ec then return end
	e:SetLabelObject(ec)
	e:SetLabel(ec:GetPreviousControler())
	return c:IsReason(REASON_LOST_TARGET) and ec:IsLocation(LOCATION_GRAVE) and ec:IsReason(REASON_DESTROY)
end
-- 设置伤害效果的目标玩家和伤害值。
function c46967601.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetLabelObject():GetTextDefense()
	if dam<0 then dam=0 end
	-- 设置伤害效果的目标玩家为装备怪兽的控制者。
	Duel.SetTargetPlayer(e:GetLabel())
	-- 设置伤害值为装备怪兽的原本守备力。
	Duel.SetTargetParam(dam)
	-- 设置伤害效果的对象卡片为装备怪兽。
	Duel.SetTargetCard(e:GetLabelObject())
	-- 设置效果处理时将要造成伤害的信息。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,e:GetLabel(),dam)
end
-- 执行伤害效果，对目标玩家造成伤害。
function c46967601.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中确定要处理的卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 获取当前连锁中确定要处理的目标玩家。
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		-- 以装备怪兽的原本守备力为基准，对目标玩家造成相应数值的伤害。
		Duel.Damage(p,g:GetFirst():GetTextDefense(),REASON_EFFECT)
	end
end
