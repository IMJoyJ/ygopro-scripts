--幻惑の巻物
-- 效果：
-- 装备的1只怪兽的属性，变成自己选择的属性。
function c10352095.initial_effect(c)
	-- 装备的1只怪兽的属性，变成自己选择的属性。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c10352095.target)
	e1:SetOperation(c10352095.operation)
	c:RegisterEffect(e1)
	-- 装备的1只怪兽的属性，变成自己选择的属性。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetCondition(c10352095.con)
	e2:SetValue(c10352095.value)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	-- 装备的1只怪兽的属性，变成自己选择的属性。
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 处理效果的发动时点选择目标怪兽
function c10352095.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否能选择到1只正面表示的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择1只正面表示的怪兽作为装备对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 提示玩家宣言一个属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	-- 让玩家宣言一个属性，不能宣言装备怪兽已有的属性
	local rc=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~g:GetFirst():GetAttribute())
	e:GetLabelObject():SetLabel(rc)
	e:GetHandler():SetHint(CHINT_ATTRIBUTE,rc)
	-- 设置效果处理时要装备的卡牌信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 处理装备效果的发动
function c10352095.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断装备效果是否生效
function c10352095.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()>0
end
-- 返回装备效果所设定的属性值
function c10352095.value(e,c)
	return e:GetLabel()
end
