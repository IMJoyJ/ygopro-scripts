--地帝グランマーグ
-- 效果：
-- ①：这张卡上级召唤成功的场合，以场上盖放的1张卡为对象发动。盖放的那张卡破坏。
function c60229110.initial_effect(c)
	-- ①：这张卡上级召唤成功的场合，以场上盖放的1张卡为对象发动。盖放的那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60229110,0))  --"选择场上1张盖伏的卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c60229110.condition)
	e1:SetTarget(c60229110.target)
	e1:SetOperation(c60229110.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否是通过上级召唤成功来满足效果发动条件
function c60229110.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果发动的对象选择与操作信息设置，确认场上是否存在盖放的卡并将其作为对象
function c60229110.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFacedown() end
	if chk==0 then return true end
	-- 向玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择双方场上合计1张里侧表示（盖放）的卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理的操作信息，准备破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理的执行函数，将作为对象的盖放卡片破坏
function c60229110.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 将目标卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
