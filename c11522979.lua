--CNo.69 紋章死神カオス・オブ・アームズ
-- 效果：
-- 5星怪兽×4
-- ①：对方怪兽的攻击宣言时才能发动。对方场上的卡全部破坏。
-- ②：这张卡有「No.69 纹章神 盾徽」在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡1个超量素材取除，以对方场上1只超量怪兽为对象才能发动。直到结束阶段，这张卡的攻击力上升那只怪兽的原本攻击力数值，这张卡得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
function c11522979.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为5的怪兽4只进行叠放
	aux.AddXyzProcedure(c,nil,5,4)
	c:EnableReviveLimit()
	-- 对方怪兽的攻击宣言时才能发动。对方场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11522979,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c11522979.descon)
	e1:SetTarget(c11522979.destg)
	e1:SetOperation(c11522979.desop)
	c:RegisterEffect(e1)
	-- 这张卡有「No.69 纹章神 盾徽」在作为超量素材的场合，得到以下效果。●1回合1次，把这张卡1个超量素材取除，以对方场上1只超量怪兽为对象才能发动。直到结束阶段，这张卡的攻击力上升那只怪兽的原本攻击力数值，这张卡得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11522979,1))  --"获得效果"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c11522979.condition)
	e2:SetCost(c11522979.cost)
	e2:SetTarget(c11522979.target)
	e2:SetOperation(c11522979.operation)
	c:RegisterEffect(e2)
end
-- 设置该卡为No.69系列怪兽
aux.xyz_number[11522979]=69
-- 攻击宣言时的条件判断函数
function c11522979.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽是否为对方控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 破坏效果的目标设定函数
function c11522979.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，指定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行函数
function c11522979.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因破坏指定卡
	Duel.Destroy(g,REASON_EFFECT)
end
-- 效果发动条件判断函数
function c11522979.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,2407234)
end
-- 效果发动的费用支付函数
function c11522979.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选对象怪兽的过滤函数
function c11522979.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 效果目标选择函数
function c11522979.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c11522979.filter(chkc) end
	-- 检查对方场上是否存在满足条件的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c11522979.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择对方场上的1只超量怪兽作为目标
	Duel.SelectTarget(tp,c11522979.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果执行函数
function c11522979.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCode()
		local atk=tc:GetBaseAttack()
		if atk<0 then atk=0 end
		-- 使自身卡名变为目标怪兽的原始卡名
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 使自身攻击力上升目标怪兽的原本攻击力数值
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(atk)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
	end
end
