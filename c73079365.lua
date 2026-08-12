--突風
-- 效果：
-- 对方的卡的效果让自己场上的魔法卡被破坏送去墓地时才能发动。选择场上1张魔法·陷阱卡破坏。
function c73079365.initial_effect(c)
	-- 对方的卡的效果让自己场上的魔法卡被破坏送去墓地时才能发动。选择场上1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c73079365.condition)
	e1:SetTarget(c73079365.target)
	e1:SetOperation(c73079365.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的卡：原本在自己魔陷区且由自己控制的魔法卡，并且因效果被破坏送去墓地
function c73079365.filter(c,tp)
	return c:IsType(TYPE_SPELL) and c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousControler(tp)
		and bit.band(c:GetReason(),0x41)==0x41
end
-- 发动条件：由对方卡片的效果导致自己场上的魔法卡被破坏送去墓地时
function c73079365.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(c73079365.filter,1,nil,tp)
end
-- 过滤可以破坏的卡：魔法卡或陷阱卡
function c73079365.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动时的效果处理：选择场上1张魔法·陷阱卡作为对象，并设置破坏的操作信息
function c73079365.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c73079365.desfilter(chkc) and chkc~=e:GetHandler() end
	-- 在发动阶段，检查场上是否存在除此卡自身以外的、可作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c73079365.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向发动效果的玩家发送提示信息，要求选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为该效果的对象
	local g=Duel.SelectTarget(tp,c73079365.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置当前连锁的操作信息，表明该效果的处理为破坏所选的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：获取选中的对象卡，若该卡仍与效果相关联，则将其破坏
function c73079365.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果破坏的方式将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
