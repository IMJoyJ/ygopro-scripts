--サイコ・ソード
-- 效果：
-- 念动力族怪兽才能装备。自己基本分比对方低的场合，装备怪兽的攻击力上升那个数值（最多2000）。
function c92346415.initial_effect(c)
	-- 念动力族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c92346415.target)
	e1:SetOperation(c92346415.operation)
	c:RegisterEffect(e1)
	-- 自己基本分比对方低的场合，装备怪兽的攻击力上升那个数值（最多2000）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c92346415.atkval)
	c:RegisterEffect(e2)
	-- 念动力族怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c92346415.eqlimit)
	c:RegisterEffect(e3)
end
-- 装备限制：只能装备给念动力族怪兽
function c92346415.eqlimit(e,c)
	return c:IsRace(RACE_PSYCHO)
end
-- 过滤条件：场上表侧表示的念动力族怪兽
function c92346415.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 效果发动的对象选择与处理
function c92346415.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c92346415.filter(chkc) end
	-- 在发动时，检查场上是否存在可以装备的合法怪兽
	if chk==0 then return Duel.IsExistingTarget(c92346415.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的念动力族怪兽作为装备对象
	Duel.SelectTarget(tp,c92346415.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：将这张卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：在装备魔法卡发动成功时，将其装备给目标怪兽
function c92346415.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 计算装备怪兽上升的攻击力数值（自己LP比对方低时，上升其差值，最大2000）
function c92346415.atkval(e,c)
	-- 计算对方LP与自己LP的差值
	local dif=Duel.GetLP(1-e:GetHandlerPlayer())-Duel.GetLP(e:GetHandlerPlayer())
	if dif>0 then
		return dif>2000 and 2000 or dif
	else return 0 end
end
