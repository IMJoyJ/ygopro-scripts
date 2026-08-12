--シャドウ・ダイバー
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当通常召唤使用的再度召唤，这张卡当作效果怪兽使用并得到以下效果。
-- ●选择自己场上表侧表示存在的1只暗属性·4星以下怪兽发动。选择怪兽这个回合可以直接攻击对方玩家。这个效果1回合只能使用1次。
function c57827484.initial_effect(c)
	-- 为卡片添加二重怪兽的通用属性与规则处理
	aux.EnableDualAttribute(c)
	-- ●选择自己场上表侧表示存在的1只暗属性·4星以下怪兽发动。选择怪兽这个回合可以直接攻击对方玩家。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57827484,0))  --"直接攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c57827484.condition)
	e1:SetTarget(c57827484.target)
	e1:SetOperation(c57827484.operation)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件函数：自身处于再度召唤状态且当前为主要阶段1
function c57827484.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否处于再度召唤状态，并且当前阶段是否为主要阶段1
	return aux.IsDualState(e) and Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 过滤出自己场上表侧表示、4星以下、暗属性且未拥有直接攻击效果的怪兽
function c57827484.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_DARK) and not c:IsHasEffect(EFFECT_DIRECT_ATTACK)
end
-- 定义效果的目标选择（Target）逻辑
function c57827484.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c57827484.filter(chkc) end
	-- 在发动阶段（chk==0）检查自己场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c57827484.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c57827484.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义效果的处理（Operation）逻辑
function c57827484.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择怪兽这个回合可以直接攻击对方玩家。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
