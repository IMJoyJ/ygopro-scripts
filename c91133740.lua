--スノーマンイーター
-- 效果：
-- 这张卡反转时，选择场上表侧表示存在的1只怪兽破坏。
function c91133740.initial_effect(c)
	-- 这张卡反转时，选择场上表侧表示存在的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91133740,0))  --"破坏"
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCode(EVENT_FLIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c91133740.destg)
	e1:SetOperation(c91133740.desop)
	c:RegisterEffect(e1)
end
-- 过滤条件：判断卡片是否为表侧表示
function c91133740.filter(c)
	return c:IsFaceup()
end
-- 效果发动的目标选择与操作信息设置（必发效果，若有合法对象则必须选择并设置破坏信息）
function c91133740.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c91133740.filter(chkc) end
	if chk==0 then return true end
	-- 给玩家发送“选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择双方场上表侧表示的1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c91133740.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：若目标怪兽仍表侧表示存在且与效果有关联，则将其破坏
function c91133740.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 因效果将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
