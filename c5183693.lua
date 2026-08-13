--下克上の首飾り
-- 效果：
-- 通常怪兽才能装备。和比装备怪兽等级高的怪兽进行战斗的场合，装备怪兽的攻击力只在伤害计算时上升等级差×500的数值。这张卡被送去墓地时，这张卡可以回到卡组最上面。
function c5183693.initial_effect(c)
	-- 通常怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c5183693.target)
	e1:SetOperation(c5183693.operation)
	c:RegisterEffect(e1)
	-- 和比装备怪兽等级高的怪兽进行战斗的场合，装备怪兽的攻击力只在伤害计算时上升等级差×500的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c5183693.atkcon)
	e2:SetValue(c5183693.atkval)
	c:RegisterEffect(e2)
	-- 通常怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c5183693.eqlimit)
	c:RegisterEffect(e3)
	-- 这张卡被送去墓地时，这张卡可以回到卡组最上面。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(5183693,0))  --"回到卡组最上面"
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetTarget(c5183693.tdtg)
	e4:SetOperation(c5183693.tdop)
	c:RegisterEffect(e4)
end
-- 检查候选装备对象是否为通常怪兽，作为装备限制条件，只有通常怪兽才能装备此卡。
function c5183693.eqlimit(e,c)
	return c:IsType(TYPE_NORMAL)
end
-- 过滤条件：对象必须是表侧表示且为通常怪兽，用于选择可装备的怪兽。
function c5183693.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
-- 装备魔法卡发动时的取对象处理：若被连锁检查对象，则验证对象为场上表侧通常怪兽；若发动检查则确认存在符合条件的通常怪兽；随后提示玩家选择1只通常怪兽作为装备对象，并设定装备操作信息。
function c5183693.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c5183693.filter(chkc) end
	-- 发动条件判定：场上是否存在至少1只表侧表示且为通常怪兽的怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c5183693.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择要装备的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从双方怪兽区选择1只表侧表示的通常怪兽作为装备对象，并将其登记为当前连锁的取对象目标。
	Duel.SelectTarget(tp,c5183693.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次连锁将进行装备操作，对象为这张装备魔法卡自身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动处理：取得对象怪兽，确认这张卡仍与效果关联且对象怪兽合法后，将这张卡装备给对象怪兽。
function c5183693.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备魔法卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 攻击力上升效果的适用条件：仅在伤害计算阶段，装备怪兽与比自己等级更高的怪兽进行战斗时才适用该效果。
function c5183693.atkcon(e)
	-- 阶段限制：只有在伤害计算时效果才可能发动/适用。
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL then return false end
	local eqc=e:GetHandler():GetEquipTarget()
	local bc=eqc:GetBattleTarget()
	return eqc:GetLevel()>0 and bc and bc:GetLevel()>eqc:GetLevel()
end
-- 计算攻击力上升数值：战斗对象等级减去装备怪兽等级，再乘以500。
function c5183693.atkval(e,c)
	local bc=c:GetBattleTarget()
	return (bc:GetLevel()-c:GetLevel())*500
end
-- 墓地回收效果的发动条件：此卡被送去墓地后，若可以返回卡组，则满足发动条件，并设置回卡组的操作信息。
function c5183693.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置操作信息：此效果将把这张卡返回卡组（CATEGORY_TODECK）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 墓地回收效果处理：若此卡仍与效果关联，则执行将其返回卡组最上面的操作。
function c5183693.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以效果原因返回持有者卡组最顶端。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
