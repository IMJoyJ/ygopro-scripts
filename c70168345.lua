--黒・魔・導・連・弾
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「黑魔术师」为对象才能发动。那只怪兽的攻击力直到回合结束时上升双方的场上·墓地的「黑魔术少女」的攻击力的合计数值。
function c70168345.initial_effect(c)
	-- 注册卡片记有「黑魔术师」和「黑魔术少女」的代码列表
	aux.AddCodeList(c,46986414,38033121)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只「黑魔术师」为对象才能发动。那只怪兽的攻击力直到回合结束时上升双方的场上·墓地的「黑魔术少女」的攻击力的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,70168345+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c70168345.target)
	e1:SetOperation(c70168345.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：双方场上表侧表示或墓地存在的「黑魔术少女」
function c70168345.filter(c)
	return c:IsCode(38033121) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 过滤条件：自己场上表侧表示的「黑魔术师」
function c70168345.tgfilter(c)
	return c:IsCode(46986414) and c:IsFaceup()
end
-- 效果发动的目标选择与合法性检查
function c70168345.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c70168345.tgfilter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示「黑魔术师」
	if chk==0 then return Duel.IsExistingTarget(c70168345.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查双方的场上或墓地是否存在至少1只「黑魔术少女」
		and Duel.IsExistingMatchingCard(c70168345.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「黑魔术师」作为效果对象
	Duel.SelectTarget(tp,c70168345.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理的执行函数
function c70168345.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的「黑魔术师」
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 获取双方场上及墓地的所有「黑魔术少女」
		local g=Duel.GetMatchingGroup(c70168345.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)
		local atk=g:GetSum(Card.GetAttack)
		-- 那只怪兽的攻击力直到回合结束时上升双方的场上·墓地的「黑魔术少女」的攻击力的合计数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
