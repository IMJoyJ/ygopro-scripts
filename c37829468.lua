--RAI－JIN
-- 效果：
-- 只要这张卡在场上表侧表示存在，自己场上表侧表示存在的光属性怪兽的攻击力上升自己墓地存在的光属性怪兽数量×100的数值。自己的结束阶段时，把自己场上表侧表示存在的1只光属性怪兽破坏。「雷-神」在场上只能有1只表侧表示存在。
function c37829468.initial_effect(c)
	c:SetUniqueOnField(1,1,37829468)
	-- 效果原文：只要这张卡在场上表侧表示存在，自己场上表侧表示存在的光属性怪兽的攻击力上升自己墓地存在的光属性怪兽数量×100的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c37829468.atktg)
	e1:SetValue(c37829468.atkval)
	c:RegisterEffect(e1)
	-- 效果原文：自己的结束阶段时，把自己场上表侧表示存在的1只光属性怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37829468,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c37829468.descon)
	e2:SetTarget(c37829468.destg)
	e2:SetOperation(c37829468.desop)
	c:RegisterEffect(e2)
end
-- 规则层面：设置效果目标为场上表侧表示存在的光属性怪兽
function c37829468.atktg(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 规则层面：计算自己墓地光属性怪兽数量并乘以100作为攻击力加成
function c37829468.atkval(e,c)
	-- 规则层面：检索自己墓地光属性怪兽数量
	return Duel.GetMatchingGroupCount(Card.IsAttribute,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,ATTRIBUTE_LIGHT)*100
end
-- 规则层面：判断是否为自己的结束阶段
function c37829468.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 规则层面：过滤场上光属性表侧表示怪兽
function c37829468.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 规则层面：选择并设置破坏对象
function c37829468.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c37829468.filter(chkc) end
	if chk==0 then return true end
	-- 规则层面：提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面：选择场上1只光属性表侧表示怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,c37829468.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 规则层面：设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 规则层面：执行破坏操作
function c37829468.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取连锁中选定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 规则层面：将目标怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
