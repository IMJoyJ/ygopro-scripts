--ドラゴンの秘宝
-- 效果：
-- 龙族才能装备。1只装备怪兽的攻击力·守备力上升300。
function c1435851.initial_effect(c)
	-- 注册装备魔法卡的标准发动效果与装备限制条件，设置只能装备给龙族怪兽
	aux.AddEquipSpellEffect(c,true,true,c1435851.filter,c1435851.eqlimit)
	-- 1只装备怪兽的攻击力上升300
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 1只装备怪兽的守备力上升300
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(300)
	c:RegisterEffect(e3)
end
-- 装备卡的装备限制条件函数，用于判断目标是否为龙族
function c1435851.eqlimit(e,c)
	return c:IsRace(RACE_DRAGON)
end
-- 选择装备目标的过滤函数，筛选表侧表示的龙族怪兽
function c1435851.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 发动效果的选择目标处理函数
function c1435851.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1435851.filter(chkc) end
	-- 判断是否满足选择目标的条件，检查场上是否存在符合条件的龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c1435851.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择装备目标的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择一个符合条件的怪兽作为装备目标
	Duel.SelectTarget(tp,c1435851.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表明本次效果将执行装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 发动效果的处理函数
function c1435851.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
