--ヴィクティム・カウンター
-- 效果：
-- 自己场上表侧表示存在的1只二重怪兽变成里侧守备表示，对方的魔法卡的发动无效并破坏。
function c81601517.initial_effect(c)
	-- 自己场上表侧表示存在的1只二重怪兽变成里侧守备表示，对方的魔法卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_MSET+CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c81601517.condition)
	e1:SetTarget(c81601517.target)
	e1:SetOperation(c81601517.activate)
	c:RegisterEffect(e1)
end
c81601517.has_text_type=TYPE_DUAL
-- 定义效果发动条件判定函数
function c81601517.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否为对方发动的魔法卡的发动，且该发动可以被无效
	return rp==1-tp and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 过滤自己场上表侧表示且可以变成里侧守备表示的二重怪兽
function c81601517.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_DUAL) and c:IsCanTurnSet()
end
-- 定义效果发动的目标选择与操作信息设置函数
function c81601517.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c81601517.filter(chkc) end
	-- 判定自己场上是否存在符合条件的二重怪兽
	if chk==0 then return Duel.IsExistingTarget(c81601517.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的二重怪兽作为效果对象
	Duel.SelectTarget(tp,c81601517.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息为使该魔法卡的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息为破坏该魔法卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义效果处理的执行函数
function c81601517.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的二重怪兽对象
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍表侧表示存在且受此效果影响，则将其变成里侧守备表示
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)~=0 then
		-- 若成功无效该魔法卡的发动，且该卡仍与该连锁相关联
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 破坏被无效发动的魔法卡
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
