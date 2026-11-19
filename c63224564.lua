--サイバー・ボンテージ
-- 效果：
-- 「鹰身女郎」或「鹰身女郎三姐妹」才能装备。
-- ①：装备怪兽的攻击力上升500。
function c63224564.initial_effect(c)
	-- 记录这张卡的效果文本上记载了「鹰身女郎」(76812113)和「鹰身女郎三姐妹」(12206212)的卡名。
	aux.AddCodeList(c,76812113,12206212)
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
-- 定义装备对象限制函数，检查目标怪兽的当前卡名是否为「鹰身女郎」或「鹰身女郎三姐妹」。
function c63224564.eqlimit(e,c)
	return c:IsCode(76812113,12206212)
end
-- 定义对象过滤函数，检查场上怪兽是否为表侧表示且卡名为「鹰身女郎」或「鹰身女郎三姐妹」。
function c63224564.filter(c)
	return c:IsFaceup() and c:IsCode(76812113,12206212)
end
-- 发动对象检查与选择函数：验证双方怪兽区存在符合条件的目标怪兽，选择其中1只作为对象并登记装备操作信息。
function c63224564.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c63224564.filter(chkc) end
	-- 在检查能否发动时，确认双方怪兽区存在至少1只可成为效果对象的表侧表示「鹰身女郎」或「鹰身女郎三姐妹」。
	if chk==0 then return Duel.IsExistingTarget(c63224564.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择要装备对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方怪兽区选择1只满足条件的怪兽作为当前连锁的发动对象。
	Duel.SelectTarget(tp,c63224564.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 向引擎登记本次连锁确定将这张卡自身装备给目标怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理函数：确认这张卡与对象怪兽均与效果关联且对象表侧在场后，将这张卡装备给对象怪兽。
function c63224564.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的当前连锁的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备魔法卡装备给选中的对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
