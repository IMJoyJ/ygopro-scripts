--魔導師の力
-- 效果：
-- ①：装备怪兽的攻击力·守备力上升自己场上的魔法·陷阱卡数量×500。
function c83746708.initial_effect(c)
	-- ①：装备怪兽的攻击力·守备力上升自己场上的魔法·陷阱卡数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c83746708.target)
	e1:SetOperation(c83746708.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力·守备力上升自己场上的魔法·陷阱卡数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c83746708.value)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击力·守备力上升自己场上的魔法·陷阱卡数量×500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(c83746708.value)
	c:RegisterEffect(e3)
	-- ①：装备怪兽的攻击力·守备力上升自己场上的魔法·陷阱卡数量×500。
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 装备魔法卡发动时的效果处理，确认发动合法性并选择装备对象
function c83746708.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在发动阶段，检测场上是否存在可以作为装备对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，表示该效果的操作分类为装备卡片
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的效果处理，将自身装备给目标怪兽
function c83746708.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 计算装备怪兽攻击力·守备力上升数值的辅助函数
function c83746708.value(e,c)
	-- 返回自己场上的魔法·陷阱卡数量乘以500的数值
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil,TYPE_SPELL+TYPE_TRAP)*500
end
