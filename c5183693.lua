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
	-- 这张卡被送去墓地时，这张卡可以回到卡组最上面。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c5183693.eqlimit)
	c:RegisterEffect(e3)
	-- 通常怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(5183693,0))  --"回到卡组最上面"
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetTarget(c5183693.tdtg)
	e4:SetOperation(c5183693.tdop)
	c:RegisterEffect(e4)
end
-- 限制只能装备到通常怪兽上
function c5183693.eqlimit(e,c)
	return c:IsType(TYPE_NORMAL)
end
-- 筛选场上正面表示的通常怪兽
function c5183693.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
-- 选择装备目标怪兽
function c5183693.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c5183693.filter(chkc) end
	-- 判断是否满足装备条件
	if chk==0 then return Duel.IsExistingTarget(c5183693.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标
	Duel.SelectTarget(tp,c5183693.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c5183693.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断是否在伤害计算阶段且满足攻击力提升条件
function c5183693.atkcon(e)
	-- 判断当前是否为伤害计算时
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL then return false end
	local eqc=e:GetHandler():GetEquipTarget()
	local bc=eqc:GetBattleTarget()
	return eqc:GetLevel()>0 and bc and bc:GetLevel()>eqc:GetLevel()
end
-- 计算并增加攻击力
function c5183693.atkval(e,c)
	local bc=c:GetBattleTarget()
	return (bc:GetLevel()-c:GetLevel())*500
end
-- 设置回到卡组的处理条件
function c5183693.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置效果处理信息为回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 执行将装备卡送回卡组最上面的操作
function c5183693.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将装备卡送回卡组最顶端
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
