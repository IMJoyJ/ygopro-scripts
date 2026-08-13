--呪いのお札
-- 效果：
-- 装备怪兽被破坏让这张卡送去墓地时，给与装备怪兽的控制者基本分送去墓地的装备怪兽的原本守备力数值的伤害。
function c46967601.initial_effect(c)
	-- 装备怪兽（装备魔法的发动，将这张卡装备给目标怪兽）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c46967601.target)
	e1:SetOperation(c46967601.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽（装备对象为怪兽的限制）
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
-- 装备效果发动时的目标选择：选择场上1只表侧表示怪兽作为装备对象，并登记装备操作信息。
function c46967601.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动时确认场上是否存在至少1只表侧表示怪兽可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1只场上表侧表示怪兽作为装备对象，并将其设为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：此次连锁将进行装备处理，要装备的卡为这张装备魔法卡本身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备处理阶段：确认这张卡和目标怪兽仍与效果相关且怪兽表侧表示后，将这张卡装备给目标怪兽。
function c46967601.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的装备对象（目标怪兽）。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 让发动玩家tp将这张卡作为装备魔法卡装备给目标怪兽tc。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 伤害诱发条件：这张卡因失去装备对象被送去墓地，且原装备怪兽被破坏并处于墓地；记录原装备怪兽和其原控制者。
function c46967601.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	if not ec then return end
	e:SetLabelObject(ec)
	e:SetLabel(ec:GetPreviousControler())
	return c:IsReason(REASON_LOST_TARGET) and ec:IsLocation(LOCATION_GRAVE) and ec:IsReason(REASON_DESTROY)
end
-- 伤害目标处理：确定伤害值为原装备怪兽的原本守备力（小于0按0计），并设置伤害对象玩家、伤害数值及对象卡，登记伤害操作信息。
function c46967601.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetLabelObject():GetTextDefense()
	if dam<0 then dam=0 end
	-- 将伤害对象玩家设置为原装备怪兽之前的控制者（即装备怪兽的控制者）。
	Duel.SetTargetPlayer(e:GetLabel())
	-- 将伤害数值参数设置为原本守备力数值。
	Duel.SetTargetParam(dam)
	-- 将当前连锁的对象卡设置为原装备怪兽。
	Duel.SetTargetCard(e:GetLabelObject())
	-- 设置操作信息：对指定玩家造成指定数值的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,e:GetLabel(),dam)
end
-- 伤害处理：从连锁对象中筛选仍与效果关联的卡，若存在则对原控制者造成该怪兽原本守备力数值的伤害。
function c46967601.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁对象中筛选出仍与这个伤害效果相关联的卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 取得当前连锁中登记的伤害对象玩家（原装备怪兽的控制者）。
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		-- 对原控制者给予原装备怪兽原本守备力数值的效果伤害。
		Duel.Damage(p,g:GetFirst():GetTextDefense(),REASON_EFFECT)
	end
end
