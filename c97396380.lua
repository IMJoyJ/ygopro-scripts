--火舞太刀
-- 效果：
-- ①：这张卡被破坏送去墓地的场合，以对方场上1只表侧表示怪兽为对象发动。那只对方的表侧表示怪兽破坏，给与对方500伤害。
function c97396380.initial_effect(c)
	-- ①：这张卡被破坏送去墓地的场合，以对方场上1只表侧表示怪兽为对象发动。那只对方的表侧表示怪兽破坏，给与对方500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97396380,0))  --"破坏并伤害"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c97396380.condition)
	e1:SetTarget(c97396380.target)
	e1:SetOperation(c97396380.operation)
	c:RegisterEffect(e1)
end
-- 确认这张卡是否因破坏而送去墓地
function c97396380.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤表侧表示卡片的条件函数
function c97396380.filter(c)
	return c:IsFaceup()
end
-- 效果①的发动准备与目标选择
function c97396380.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c97396380.filter(chkc) end
	if chk==0 then return true end
	-- 在界面上提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c97396380.filter,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 设置破坏操作的信息，包含目标怪兽和数量
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		-- 设置伤害操作的信息，包含受伤害玩家和伤害数值
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
	end
end
-- 效果①的效果处理（破坏对象怪兽并给与伤害）
function c97396380.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽在场且仍适用此效果，则将其因效果破坏，并判断是否成功破坏
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 给与对方玩家500点效果伤害
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
