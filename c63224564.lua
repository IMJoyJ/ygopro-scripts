--サイバー・ボンテージ
-- 效果：
-- 「鹰身女郎」或「鹰身女郎三姐妹」才能装备。
-- ①：装备怪兽的攻击力上升500。
function c63224564.initial_effect(c)
	-- 在卡片中记录其效果关联了「鹰身女郎三姐妹」的卡名
	aux.AddCodeList(c,12206212)
	-- 「鹰身女郎」或「鹰身女郎三姐妹」才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c63224564.target)
	e1:SetOperation(c63224564.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 「鹰身女郎」或「鹰身女郎三姐妹」才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c63224564.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备给卡名为「鹰身女郎」或「鹰身女郎三姐妹」的怪兽
function c63224564.eqlimit(e,c)
	return c:IsCode(76812113,12206212)
end
-- 过滤条件：场上表侧表示的「鹰身女郎」或「鹰身女郎三姐妹」
function c63224564.filter(c)
	return c:IsFaceup() and c:IsCode(76812113,12206212)
end
-- 魔法卡发动时的对象选择处理
function c63224564.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c63224564.filter(chkc) end
	-- 在发动时，检查场上是否存在可以装备的合法怪兽
	if chk==0 then return Duel.IsExistingTarget(c63224564.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c63224564.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息，表明此效果的处理包含将自身装备给怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 魔法卡发动成功后的效果处理，执行装备操作
function c63224564.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
