--バブル・ショット
-- 效果：
-- 「元素英雄 水泡侠」才能装备。装备怪兽的攻击力上升800。装备怪兽被战斗破坏的场合，这张卡代替破坏，装备怪兽的控制者的战斗伤害为0。
function c53586134.initial_effect(c)
	-- 为卡片添加系列编码0x3008，用于后续判断是否属于指定系列
	aux.AddSetNameMonsterList(c,0x3008)
	-- 「元素英雄 水泡侠」才能装备。装备怪兽的攻击力上升800。装备怪兽被战斗破坏的场合，这张卡代替破坏，装备怪兽的控制者的战斗伤害为0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c53586134.target)
	e1:SetOperation(c53586134.operation)
	c:RegisterEffect(e1)
	-- 「元素英雄 水泡侠」才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c53586134.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽的攻击力上升800。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(800)
	c:RegisterEffect(e3)
	-- 装备怪兽被战斗破坏的场合，这张卡代替破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e4:SetValue(c53586134.repval)
	c:RegisterEffect(e4)
	-- 装备怪兽的控制者的战斗伤害为0。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 限制装备对象只能是卡号为79979666的怪兽（即元素英雄 水泡侠）
function c53586134.eqlimit(e,c)
	return c:IsCode(79979666)
end
-- 筛选出场上表侧表示且卡号为79979666的怪兽（即元素英雄 水泡侠）
function c53586134.filter(c)
	return c:IsFaceup() and c:IsCode(79979666)
end
-- 处理装备魔法发动时的目标选择和操作信息设置
function c53586134.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c53586134.filter(chkc) end
	-- 检查是否存在可以作为装备对象的怪兽（元素英雄 水泡侠）
	if chk==0 then return Duel.IsExistingTarget(c53586134.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择一个符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c53586134.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为装备效果，并指定装备卡本身为处理对象
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡实际装备给目标怪兽
function c53586134.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取之前选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将当前装备魔法卡装备给指定的目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断代替破坏的触发条件是否为战斗破坏
function c53586134.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
