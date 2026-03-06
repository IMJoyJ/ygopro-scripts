--A・ジェネクス・クラッシャー
-- 效果：
-- ①：1回合1次，持有和这张卡相同属性的怪兽在自己场上召唤时，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
function c27827903.initial_effect(c)
	-- 效果原文内容：①：1回合1次，持有和这张卡相同属性的怪兽在自己场上召唤时，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27827903,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c27827903.descon)
	e1:SetTarget(c27827903.destg)
	e1:SetOperation(c27827903.desop)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断召唤成功的怪兽是否为同属性且控制者为自己且不是自身
function c27827903.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()~=e:GetHandler() and eg:GetFirst():GetControler()==e:GetHandler():GetControler()
		and eg:GetFirst():IsAttribute(e:GetHandler():GetAttribute())
end
-- 规则层面作用：设置效果目标选择逻辑，确保选择对方场上的卡
function c27827903.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 规则层面作用：检查是否有满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 规则层面作用：向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面作用：选择对方场上的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 规则层面作用：设置连锁操作信息，表明将要破坏卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 规则层面作用：处理效果的破坏操作
function c27827903.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁的效果目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 规则层面作用：以效果原因破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
