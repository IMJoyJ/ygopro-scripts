--RR－ファントム・クロー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：怪兽的效果发动时，把自己场上的暗属性超量怪兽1个超量素材取除才能发动。那个发动无效并破坏。为这张卡发动而取除的超量素材是「幻影骑士团」、「急袭猛禽」、「超量龙」卡的场合，再选自己场上1只「急袭猛禽」超量怪兽，那个攻击力上升这个效果破坏的怪兽的原本攻击力数值。
function c13486638.initial_effect(c)
	-- 效果发动时，把自己场上的暗属性超量怪兽1个超量素材取除才能发动。那个发动无效并破坏。为这张卡发动而取除的超量素材是「幻影骑士团」、「急袭猛禽」、「超量龙」卡的场合，再选自己场上1只「急袭猛禽」超量怪兽，那个攻击力上升这个效果破坏的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,13486638)
	e1:SetCondition(c13486638.condition)
	e1:SetCost(c13486638.cost)
	e1:SetTarget(c13486638.target)
	e1:SetOperation(c13486638.operation)
	c:RegisterEffect(e1)
end
-- 检查连锁是否为怪兽效果发动且可以无效
function c13486638.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 连锁发动的卡必须是怪兽类型且该连锁可以被无效
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 过滤函数，用于检查场上是否存在满足条件的暗属性超量怪兽
function c13486638.cfilter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ)
		and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
-- 支付费用时的处理函数
function c13486638.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在满足条件的暗属性超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c13486638.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要取除超量素材的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
	-- 选择场上满足条件的暗属性超量怪兽
	local c=Duel.SelectMatchingCard(tp,c13486638.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 获取实际被取除超量素材的怪兽
	local tc=Duel.GetOperatedGroup():GetFirst()
	if tc:IsSetCard(0xba,0x10db,0x2073) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
-- 设置效果目标时的处理函数
function c13486638.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁操作信息为破坏发动的怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 过滤函数，用于选择自己场上的「急袭猛禽」超量怪兽
function c13486638.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xba) and c:IsType(TYPE_XYZ)
end
-- 效果发动时的处理函数
function c13486638.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效并破坏对方怪兽，若取除的素材为指定卡组则继续处理
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 and e:GetLabel()==1 then
		-- 提示玩家选择要提升攻击力的「急袭猛禽」超量怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
		-- 选择场上满足条件的「急袭猛禽」超量怪兽
		local g=Duel.SelectMatchingCard(tp,c13486638.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 显示选中怪兽被选为对象的动画效果
			Duel.HintSelection(g)
			-- 为选中的「急袭猛禽」超量怪兽增加攻击力，数值等于被破坏怪兽的原本攻击力
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(eg:GetFirst():GetBaseAttack())
			tc:RegisterEffect(e1)
		end
	end
end
