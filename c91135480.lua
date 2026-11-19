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
	-- 为这张卡设置超量召唤手续：需要2只4星怪兽作为超量素材。
	aux.AddXyzProcedure(c,nil,4,2)
	-- 这个卡名的效果1回合只能使用1次。①：对方把效果发动时才能发动。这张卡的超量素材最多3种类（怪兽·魔法·陷阱）取除。那之后，以下适用。●怪兽：这张卡的攻击力上升400。●魔法：选对方场上1只表侧表示怪兽直到结束阶段得到控制权。这个回合，那只怪兽不能攻击宣言，不能把效果发动。●陷阱：选场上1只效果怪兽，那个效果直到回合结束时无效。
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
-- 发动条件检查函数：确认发动时触发连锁的效果是由对方玩家发动的。
function c91135480.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 发动检查函数：确认这张卡可以以效果取除至少1个超量素材，且所持有的怪兽·魔法·陷阱素材中至少有一种满足对应的后续适用条件。
function c91135480.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		if not c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) then return false end
		local g=c:GetOverlayGroup()
		if g:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
			then return true end
		if g:IsExists(Card.IsType,1,nil,TYPE_SPELL)
			-- 检查这张卡是否拥有魔法卡素材且对方场上存在至少1只可改变控制权的表侧表示怪兽。
			and Duel.IsExistingMatchingCard(c91135480.ctfilter,tp,0,LOCATION_MZONE,1,nil) then return true end
		if g:IsExists(Card.IsType,1,nil,TYPE_TRAP)
			-- 检查这张卡是否拥有陷阱卡素材且双方场上存在至少1只可被无效的表侧表示效果怪兽。
			and Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then return true end
		return false
	end
end
-- 定义超量素材组合检查函数：限制选中的超量素材中怪兽、魔法、陷阱卡每种最多只能包含1张。
function c91135480.check(g)
	return g:FilterCount(Card.IsType,nil,TYPE_MONSTER)<=1
		and g:FilterCount(Card.IsType,nil,TYPE_SPELL)<=1
		and g:FilterCount(Card.IsType,nil,TYPE_TRAP)<=1
end
-- 定义抢夺控制权过滤函数：检查对方怪兽是否为表侧表示且可以改变控制权。
function c91135480.ctfilter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 效果处理函数：按各分支当前是否可适用筛选可选素材，取除最多各1张（怪兽·魔法·陷阱）素材后，依取除的种类依次适用加攻、夺取控制权并封锁攻击与效果、无效场上效果怪兽效果的处理。
function c91135480.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) then return end
	local g=c:GetOverlayGroup()
	local tg=Group.CreateGroup()
	if c:IsFaceup() then
		tg:Merge(g:Filter(Card.IsType,nil,TYPE_MONSTER))
	end
	-- 检查对方怪兽区是否存在可夺取控制权的表侧表示怪兽，若存在则将魔法卡超量素材纳入可选范围。
	if Duel.IsExistingMatchingCard(c91135480.ctfilter,tp,0,LOCATION_MZONE,1,nil) then
		tg:Merge(g:Filter(Card.IsType,nil,TYPE_SPELL))
	end
	-- 检查双方怪兽区是否存在可被无效的表侧表示效果怪兽，若存在则将陷阱卡超量素材纳入可选范围。
	if Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
		tg:Merge(g:Filter(Card.IsType,nil,TYPE_TRAP))
	end
	-- 向玩家发送选择要取除的超量素材的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
	local sg=tg:SelectSubGroup(tp,c91135480.check,false,1,3)
	if not sg then return end
	-- 将选中的超量素材以效果原因送去墓地（完成取除操作）。
	Duel.SendtoGrave(sg,REASON_EFFECT)
	-- 为这张卡触发超量素材被取除的单体事件通知。
	Duel.RaiseSingleEvent(c,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	if sg:IsExists(Card.IsType,1,nil,TYPE_MONSTER) then
		-- 插入效果中断，使取除素材与后续怪兽分支效果视为不同时处理。
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
		-- 插入效果中断，使后续魔法分支的夺取控制权处理与其他分支视为不同时处理。
		Duel.BreakEffect()
		-- 向玩家发送选择要改变控制权的对方怪兽的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 让玩家从对方怪兽区选择1只满足条件的表侧表示怪兽。
		local g=Duel.SelectMatchingCard(tp,c91135480.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 为选中的对方怪兽显示被选择提示动画。
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		-- 让发动玩家直到这个回合结束阶段为止得到所选怪兽的控制权，并判断是否成功转移控制权。
		if Duel.GetControl(tc,tp,PHASE_END,1)~=0 then
			-- 这个回合，那只怪兽不能攻击宣言，不能把效果发动。
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
		-- 插入效果中断，使后续陷阱分支的无效怪兽效果处理与其他分支视为不同时处理。
		Duel.BreakEffect()
		-- 向玩家发送选择要无效效果的怪兽提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 让玩家从双方怪兽区选择1只表侧表示且效果未被无效的效果怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			-- 使当前连锁中与被选怪兽相关的效果在状态重置前无效化。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- ●陷阱：选场上1只效果怪兽，那个效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
			-- ●陷阱：选场上1只效果怪兽，那个效果直到回合结束时无效。
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
