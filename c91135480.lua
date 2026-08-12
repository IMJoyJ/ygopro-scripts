--クロノダイバー・ダブルバレル
-- 效果：
-- 4星怪兽×2
-- 这个卡名的效果1回合只能使用1次。
-- ①：对方把效果发动时才能发动。这张卡的超量素材最多3种类（怪兽·魔法·陷阱）取除。那之后，以下适用。
-- ●怪兽：这张卡的攻击力上升400。
-- ●魔法：选对方场上1只表侧表示怪兽直到结束阶段得到控制权。这个回合，那只怪兽不能攻击宣言，不能把效果发动。
-- ●陷阱：选场上1只效果怪兽，那个效果直到回合结束时无效。
function c91135480.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续：4星怪兽×2。
	aux.AddXyzProcedure(c,nil,4,2)
	-- ①：对方把效果发动时才能发动。这张卡的超量素材最多3种类（怪兽·魔法·陷阱）取除。那之后，以下适用。●怪兽：这张卡的攻击力上升400。●魔法：选对方场上1只表侧表示怪兽直到结束阶段得到控制权。这个回合，那只怪兽不能攻击宣言，不能把效果发动。●陷阱：选场上1只效果怪兽，那个效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91135480,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,91135480)
	e1:SetCondition(c91135480.condition)
	e1:SetTarget(c91135480.target)
	e1:SetOperation(c91135480.operation)
	c:RegisterEffect(e1)
end
-- 检查发动效果的玩家是否为对方。
function c91135480.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 效果发动的可行性检查，判断是否能去除超量素材以及是否存在可适用的效果对象。
function c91135480.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		if not c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) then return false end
		local g=c:GetOverlayGroup()
		if g:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
			then return true end
		if g:IsExists(Card.IsType,1,nil,TYPE_SPELL)
			-- 检查对方场上是否存在可以转移控制权的表侧表示怪兽。
			and Duel.IsExistingMatchingCard(c91135480.ctfilter,tp,0,LOCATION_MZONE,1,nil) then return true end
		if g:IsExists(Card.IsType,1,nil,TYPE_TRAP)
			-- 检查场上是否存在可以无效其效果的效果怪兽。
			and Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then return true end
		return false
	end
end
-- 检查所选的超量素材组中，怪兽、魔法、陷阱卡是否各自最多只有1张。
function c91135480.check(g)
	return g:FilterCount(Card.IsType,nil,TYPE_MONSTER)<=1
		and g:FilterCount(Card.IsType,nil,TYPE_SPELL)<=1
		and g:FilterCount(Card.IsType,nil,TYPE_TRAP)<=1
end
-- 过滤出对方场上表侧表示且可以转移控制权的怪兽。
function c91135480.ctfilter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 效果处理的核心逻辑，根据去除的超量素材种类依次适用对应的效果。
function c91135480.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) then return end
	local g=c:GetOverlayGroup()
	local tg=Group.CreateGroup()
	if c:IsFaceup() then
		tg:Merge(g:Filter(Card.IsType,nil,TYPE_MONSTER))
	end
	-- 检查对方场上是否存在可夺取控制权的怪兽，以决定是否能将魔法卡作为素材去除。
	if Duel.IsExistingMatchingCard(c91135480.ctfilter,tp,0,LOCATION_MZONE,1,nil) then
		tg:Merge(g:Filter(Card.IsType,nil,TYPE_SPELL))
	end
	-- 检查场上是否存在效果怪兽，以决定是否能将陷阱卡作为素材去除。
	if Duel.IsExistingMatchingCard(c91135480.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
		tg:Merge(g:Filter(Card.IsType,nil,TYPE_TRAP))
	end
	-- 提示玩家选择要作为超量素材去除的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
	local sg=tg:SelectSubGroup(tp,c91135480.check,false,1,3)
	if not sg then return end
	-- 将选中的超量素材送去墓地。
	Duel.SendtoGrave(sg,REASON_EFFECT)
	-- 触发去除超量素材的单体时点。
	Duel.RaiseSingleEvent(c,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	if sg:IsExists(Card.IsType,1,nil,TYPE_MONSTER) then
		-- 中断当前效果，使之后的效果处理视为不同时处理（用于“那之后”的处理）。
		Duel.BreakEffect()
		-- ●怪兽：这张卡的攻击力上升400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(400)
		c:RegisterEffect(e1)
	end
	if sg:IsExists(Card.IsType,1,nil,TYPE_SPELL) then
		-- 中断当前效果，使之后的效果处理视为不同时处理（用于“那之后”的处理）。
		Duel.BreakEffect()
		-- 提示玩家选择要转移控制权的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 让玩家选择对方场上1只表侧表示的怪兽。
		local g=Duel.SelectMatchingCard(tp,c91135480.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 显式地在场上框选并提示所选择的怪兽。
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		-- 尝试直到结束阶段得到该怪兽的控制权，若成功则进行后续处理。
		if Duel.GetControl(tc,tp,PHASE_END,1)~=0 then
			-- 这个回合，那只怪兽不能攻击宣言
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_TRIGGER)
			tc:RegisterEffect(e2)
		end
	end
	if sg:IsExists(Card.IsType,1,nil,TYPE_TRAP) then
		-- 中断当前效果，使之后的效果处理视为不同时处理（用于“那之后”的处理）。
		Duel.BreakEffect()
		-- 提示玩家选择要无效效果的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 让玩家选择场上1只表侧表示的效果怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			-- 使该怪兽在当前连锁中已发动的效果无效化。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 选场上1只效果怪兽，那个效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
			-- 选场上1只效果怪兽，那个效果直到回合结束时无效。
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e4:SetCode(EFFECT_DISABLE_EFFECT)
			e4:SetValue(RESET_TURN_SET)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e4)
		end
	end
end
