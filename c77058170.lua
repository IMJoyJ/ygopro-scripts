--アンダークロックテイカー
-- 效果：
-- 效果怪兽2只
-- ①：1回合1次，以这张卡所连接区1只表侧表示怪兽和对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力直到回合结束时下降作为对象的所连接区的怪兽的攻击力数值。
function c77058170.initial_effect(c)
	-- 设置连接召唤手续，需要2只效果怪兽作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，以这张卡所连接区1只表侧表示怪兽和对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力直到回合结束时下降作为对象的所连接区的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77058170,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c77058170.atktg)
	e1:SetOperation(c77058170.atkop)
	c:RegisterEffect(e1)
end
-- 过滤自身场上所连接区内表侧表示且攻击力大于0的怪兽
function c77058170.atkfilter(c,g)
	return c:IsFaceup() and c:GetAttack()>0 and g:IsContains(c)
end
-- 效果发动的目标选择与合法性检测
function c77058170.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local lg=e:GetHandler():GetLinkedGroup()
	-- 检查自己场上是否存在1只符合条件的所连接区怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c77058170.atkfilter,tp,LOCATION_MZONE,0,1,nil,lg)
		-- 检查对方场上是否存在1只表侧表示怪兽作为对象
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择自己场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 选择自己场上所连接区内的1只表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c77058170.atkfilter,tp,LOCATION_MZONE,0,1,1,nil,lg)
	e:SetLabelObject(g:GetFirst())
	-- 提示玩家选择对方场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上1只表侧表示怪兽作为对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理，使选择的对方怪兽的攻击力下降选择的所连接区怪兽的攻击力数值
function c77058170.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	-- 获取当前连锁中被选择为对象的所有卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc2=g:GetFirst()
	if tc1==tc2 then tc2=g:GetNext() end
	if tc1:IsFaceup() and tc1:IsRelateToEffect(e) and tc2:IsFaceup() and tc2:IsRelateToEffect(e) then
		local atk=tc1:GetAttack()
		-- 那只对方怪兽的攻击力直到回合结束时下降作为对象的所连接区的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc2:RegisterEffect(e1)
	end
end
