--降格処分
-- 效果：
-- 装备怪兽的等级下降2星。
function c72575145.initial_effect(c)
	-- （这张卡的发动）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c72575145.target)
	e1:SetOperation(c72575145.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的等级下降2星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetValue(-2)
	c:RegisterEffect(e2)
	-- （装备限制）
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 效果发动的目标过滤与选择，确认场上是否有可装备的表侧表示怪兽并取对象
function c72575145.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在发动效果时，检测场上是否存在可以作为装备对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为这张卡的效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，表明该效果包含装备卡的操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将这张卡装备给选择的目标怪兽
function c72575145.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
