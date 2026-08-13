--RAI－JIN
-- 效果：
-- 只要这张卡在场上表侧表示存在，自己场上表侧表示存在的光属性怪兽的攻击力上升自己墓地存在的光属性怪兽数量×100的数值。自己的结束阶段时，把自己场上表侧表示存在的1只光属性怪兽破坏。「雷-神」在场上只能有1只表侧表示存在。
function c37829468.initial_effect(c)
	c:SetUniqueOnField(1,1,37829468)
	-- 只要这张卡在场上表侧表示存在，自己场上表侧表示存在的光属性怪兽的攻击力上升自己墓地存在的光属性怪兽数量×100的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c37829468.atktg)
	e1:SetValue(c37829468.atkval)
	c:RegisterEffect(e1)
	-- 自己的结束阶段时，把自己场上表侧表示存在的1只光属性怪兽破坏。
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
-- 攻击力上升效果的适用对象判定：筛选自己场上的光属性怪兽作为攻击力增减对象。
function c37829468.atktg(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 计算攻击力上升数值：统计效果控制者墓地中光属性怪兽的数量，每只使其攻击力上升100。
function c37829468.atkval(e,c)
	-- 统计自己墓地中光属性怪兽的数量并乘以100，作为攻击力的上升数值。
	return Duel.GetMatchingGroupCount(Card.IsAttribute,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,ATTRIBUTE_LIGHT)*100
end
-- 破坏效果的发动条件：仅在自己的结束阶段且当前回合玩家为此卡控制者时满足。
function c37829468.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为这张卡的控制者，若是则满足发动条件。
	return Duel.GetTurnPlayer()==tp
end
-- 筛选可作为破坏对象的怪兽：必须是表侧表示的光属性怪兽。
function c37829468.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 破坏效果的目标选择处理：检查被指定对象是否合法；若为发动时则提示玩家从自己场上表侧表示的光属性怪兽中选择1张作为对象，并设置破坏的操作信息。
function c37829468.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c37829468.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家发送“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上表侧表示的光属性怪兽中选择1张，并将其指定为效果对象。
	local g=Duel.SelectTarget(tp,c37829468.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置本连锁的操作信息，标记该效果将进行破坏，目标为已选择的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果处理：取得效果对象，若其仍表侧表示且与效果关联，则将其破坏。
function c37829468.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中第一个被指定为对象的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
