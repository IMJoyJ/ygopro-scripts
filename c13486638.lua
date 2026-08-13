--RR－ファントム・クロー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：怪兽的效果发动时，把自己场上的暗属性超量怪兽1个超量素材取除才能发动。那个发动无效并破坏。为这张卡发动而取除的超量素材是「幻影骑士团」、「急袭猛禽」、「超量龙」卡的场合，再选自己场上1只「急袭猛禽」超量怪兽，那个攻击力上升这个效果破坏的怪兽的原本攻击力数值。
function c13486638.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：怪兽的效果发动时，把自己场上的暗属性超量怪兽1个超量素材取除才能发动。那个发动无效并破坏。为这张卡发动而取除的超量素材是「幻影骑士团」、「急袭猛禽」、「超量龙」卡的场合，再选自己场上1只「急袭猛禽」超量怪兽，那个攻击力上升这个效果破坏的怪兽的原本攻击力数值。
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
-- 本卡的发动条件：仅在连锁中发动的效果是怪兽效果且该效果发动能够被无效时，本卡才可以发动。
function c13486638.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前连锁中的效果是否为怪兽效果，同时该连锁是否可被无效。
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 代价选择的过滤器：选择自己场上表侧表示、暗属性、超量怪兽，且能够取除1个超量素材作为代价。
function c13486638.cfilter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ)
		and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
-- 支付发动代价：选择自己场上1只符合条件的暗属性超量怪兽，取除其1个超量素材；然后检查取除的素材是否为「幻影骑士团」「急袭猛禽」「超量龙」之一，通过标签记录以便后续追加攻击力效果。
function c13486638.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价确认阶段：检查自己场上是否存在至少1只符合条件的暗属性超量怪兽，若不存在则无法支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c13486638.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 显示选择提示，要求玩家选择要取除超量素材的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
	-- 从自己场上选择1只符合条件的暗属性超量怪兽，并取得该卡对象。
	local c=Duel.SelectMatchingCard(tp,c13486638.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 取得刚才取除超量素材操作中实际被取除的那张素材卡。
	local tc=Duel.GetOperatedGroup():GetFirst()
	if tc:IsSetCard(0xba,0x10db,0x2073) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
-- 发动时目标设定：本卡发动时不取对象，但需将无效与破坏信息登记到连锁处理中；若对象怪兽仍可被破坏，则补充破坏信息。
function c13486638.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本次连锁将无效该怪兽效果的发动，对象为连锁中的该组卡。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记操作信息：在可破坏的情况下，将该怪兽也登记为将被破坏的对象。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 追加效果选择对象的过滤器：选择自己场上表侧表示的「急袭猛禽」超量怪兽。
function c13486638.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xba) and c:IsType(TYPE_XYZ)
end
-- 发动处理：先无效该怪兽效果；若成功且该怪兽仍存在并关联，则将其破坏；若破坏成功且代价取除的素材符合指定系列，则继续选择自己1只「急袭猛禽」超量怪兽，使其攻击力上升被破坏怪兽的原本攻击力。
function c13486638.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否满足无效成功、怪兽仍关联、破坏成功以及代价素材符合条件，四个条件同时成立才执行追加攻击力上升。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 and e:GetLabel()==1 then
		-- 显示选择提示，要求玩家选择要提升攻击力的自己的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
		-- 从自己场上选择1只表侧表示的「急袭猛禽」超量怪兽作为攻击力上升对象。
		local g=Duel.SelectMatchingCard(tp,c13486638.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 显示所选对象的选中动画，并记录该卡被选为对象。
			Duel.HintSelection(g)
			-- 再选自己场上1只「急袭猛禽」超量怪兽，那个攻击力上升这个效果破坏的怪兽的原本攻击力数值。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(eg:GetFirst():GetBaseAttack())
			tc:RegisterEffect(e1)
		end
	end
end
