--A・ジェネクス・クラッシャー
-- 效果：
-- ①：1回合1次，持有和这张卡相同属性的怪兽在自己场上召唤时，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
function c27827903.initial_effect(c)
	-- ①：1回合1次，持有和这张卡相同属性的怪兽在自己场上召唤时，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
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
-- 判定效果发动条件：当有怪兽召唤成功时，该怪兽不是这张卡自身、控制者是这张卡的控制者，且属性与这张卡相同。
function c27827903.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()~=e:GetHandler() and eg:GetFirst():GetControler()==e:GetHandler():GetControler()
		and eg:GetFirst():IsAttribute(e:GetHandler():GetAttribute())
end
-- 效果发动时的取对象处理：确认对方场上有可选择的卡后，提示玩家选择对方场上1张卡作为对象，并设置破坏1张卡的操作信息。
function c27827903.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 效果发动合法性检查：对方场上存在任意1张可作为对象的卡时，该效果才满足发动条件。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示“请选择要破坏的卡”的提示信息，用于选择卡片的操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 令玩家选择对方场上1张卡作为效果对象（不限制卡种），并将该卡登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的操作信息，标明要破坏的对象卡及数量，供相关卡牌效果（如星尘龙等）进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时的执行动作：取得之前选择的对象卡，若该卡仍与效果关联且仍在对方场上，则将其破坏。
function c27827903.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁中已选择的那张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 以卡的效果为缘由破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
