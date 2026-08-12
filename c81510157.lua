--ソウルテイカー
-- 效果：
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽破坏。那之后，对方回复1000基本分。
function c81510157.initial_effect(c)
	-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽破坏。那之后，对方回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c81510157.target)
	e1:SetOperation(c81510157.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡片是否为表侧表示
function c81510157.filter(c)
	return c:IsFaceup()
end
-- 效果发动的目标选择与操作信息设置
function c81510157.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c81510157.filter(chkc) end
	-- 在发动阶段，检查对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c81510157.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 发送提示信息，提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c81510157.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：对方回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,1000)
end
-- 效果处理：破坏对象怪兽，之后对方回复基本分
function c81510157.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍表侧表示存在且与效果有关联，则将其破坏
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 中断效果处理，使后续的回复基本分处理不与破坏同时进行（造成错时点）
		Duel.BreakEffect()
		-- 使对方玩家回复1000基本分
		Duel.Recover(1-tp,1000,REASON_EFFECT)
	end
end
