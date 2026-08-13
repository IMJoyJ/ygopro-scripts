--細菌感染
-- 效果：
-- 机械族以外的怪兽装备可能。装备怪兽的攻击力在每次的自己的准备阶段攻击力下降300。
function c24668830.initial_effect(c)
	-- 机械族以外的怪兽装备可能。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c24668830.target)
	e1:SetOperation(c24668830.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力在每次的自己的准备阶段攻击力下降300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c24668830.atkcon)
	e2:SetOperation(c24668830.atkop)
	c:RegisterEffect(e2)
	-- 机械族以外的怪兽装备可能。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c24668830.eqlimit)
	c:RegisterEffect(e3)
end
-- 定义本卡的装备限制条件：只有不是机械族的怪兽才能装备本卡；机械族怪兽不能装备。
function c24668830.eqlimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end
-- 定义选择装备对象的过滤条件：对象必须是场上表侧表示且种族不是机械族的怪兽。
function c24668830.filter(c)
	return c:IsFaceup() and not c:IsRace(RACE_MACHINE)
end
-- 发动时的目标处理：先确认对象合法；若场上不存在符合条件的怪兽则不能发动；然后提示玩家选择，从双方怪兽区域选择1只表侧表示且非机械族的怪兽作为装备对象，并登记操作信息为本装备卡的装备处理。
function c24668830.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c24668830.filter(chkc) end
	-- 效果发动判定：检查场上是否存在至少1只表侧表示且非机械族的怪兽；若不存在，则本卡不能发动。
	if chk==0 then return Duel.IsExistingTarget(c24668830.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择要装备的卡”，用于选择装备对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方怪兽区域选择1只表侧表示且非机械族的怪兽，并将其登记为当前连锁的装备对象。
	Duel.SelectTarget(tp,c24668830.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：类别为装备（本卡装备到怪兽上），操作对象为本卡自身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：取得发动时选择的装备对象；若本卡和对象仍与效果关联且对象仍为表侧表示，则将本卡装备给对象怪兽。
function c24668830.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的装备对象卡。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡作为tp玩家的装备卡装备给对象怪兽，完成装备处理。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 准备阶段触发效果的判定：仅当当前回合玩家是本卡的控制者（即自己的准备阶段）时，才执行攻击力下降效果。
function c24668830.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于效果控制者，以限定只在“自己的准备阶段”处理下降效果。
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段下降攻击力的处理：取得本卡的装备怪兽，为其创建一个攻击力下降300的效果，并设置标准重置条件（装备怪兽离场、离开怪兽区域或本卡失去装备关系等情况下会消失）。
function c24668830.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	-- 装备怪兽的攻击力在每次的自己的准备阶段攻击力下降300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-300)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	ec:RegisterEffect(e1)
end
