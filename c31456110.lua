--ヴェルズ・ゴーレム
-- 效果：
-- 1回合1次，可以选择场上表侧表示存在的1只暗属性以外的5星以上的怪兽破坏。
function c31456110.initial_effect(c)
	-- 1回合1次，可以选择场上表侧表示存在的1只暗属性以外的5星以上的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31456110,0))  --"怪兽破坏"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c31456110.destg)
	e1:SetOperation(c31456110.desop)
	c:RegisterEffect(e1)
end
-- 定义可选对象过滤条件：怪兽须表侧表示、属性不是暗属性、等级5以上。
function c31456110.filter(c)
	return c:IsFaceup() and c:IsNonAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(5)
end
-- 效果的发动时点处理：确认是否存在合法的可选对象，并让玩家选择1只符合条件的场上表侧怪兽作为效果对象，同时登记破坏的操作信息。
function c31456110.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31456110.filter(chkc) end
	-- 判定发动时是否存在至少1只符合条件的表侧怪兽可供选择（效果能否发动）。
	if chk==0 then return Duel.IsExistingTarget(c31456110.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向当前玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上表侧表示中选择1只满足条件的怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c31456110.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记本次连锁将破坏1张已被选择的卡，破坏分类为破坏效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时的操作：取得效果对象，若对象仍与效果相关且依旧满足条件，则将其破坏。
function c31456110.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时所选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c31456110.filter(tc) then
		-- 以效果原因将对象怪兽破坏送入墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
