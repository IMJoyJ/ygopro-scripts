--リチュアル・ウェポン
-- 效果：
-- 6星以下的仪式怪兽才能装备。装备怪兽的攻击力·守备力上升1500。
function c54351224.initial_effect(c)
	-- 6星以下的仪式怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c54351224.target)
	e1:SetOperation(c54351224.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力·守备力上升1500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1500)
	c:RegisterEffect(e2)
	-- 装备怪兽的攻击力·守备力上升1500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(1500)
	c:RegisterEffect(e3)
	-- 6星以下的仪式怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c54351224.eqlimit)
	c:RegisterEffect(e4)
end
-- 定义装备限制：只能装备给6星以下的仪式怪兽
function c54351224.eqlimit(e,c)
	return c:IsType(TYPE_RITUAL) and c:IsLevelBelow(6)
end
-- 过滤条件：场上表侧表示的6星以下的仪式怪兽
function c54351224.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsLevelBelow(6)
end
-- 效果发动的目标选择与处理
function c54351224.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c54351224.filter(chkc) end
	-- 在发动阶段，检查场上是否存在可以装备的合法目标
	if chk==0 then return Duel.IsExistingTarget(c54351224.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c54351224.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将自身作为装备卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：执行装备操作
function c54351224.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
