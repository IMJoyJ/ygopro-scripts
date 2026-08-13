--神竜騎士フェルグラント
-- 效果：
-- 8星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。这个回合，作为对象的怪兽效果无效，不受这张卡以外的效果影响。这个效果在对方回合也能发动。
function c1639384.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：使用2只等级8的怪兽作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。这个回合，作为对象的怪兽效果无效，不受这张卡以外的效果影响。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1639384,0))  --"效果耐性"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c1639384.cost)
	e1:SetTarget(c1639384.target)
	e1:SetOperation(c1639384.operation)
	c:RegisterEffect(e1)
end
-- 发动代价：检查能否从这张卡上取除1个超量素材，若能则取除1个超量素材作为发动代价。
function c1639384.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：选择场上表侧表示的怪兽。
function c1639384.filter(c)
	return c:IsFaceup()
end
-- 发动时的取对象处理：选定场上1只表侧表示怪兽作为效果对象；若连锁处理时对象不再合适则效果不处理。
function c1639384.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1639384.filter(chkc) end
	-- 发动合法性检查：场上是否存在至少1只表侧表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c1639384.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示选择提示消息，提示内容为“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作玩家从双方怪兽区选择1只表侧表示怪兽，并将其登记为本连锁的对象。
	Duel.SelectTarget(tp,c1639384.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：将对象怪兽的效果无效，并使其不受这张卡以外的效果影响；同时使与对象怪兽相关的连锁无效化，持续到这个回合结束。
function c1639384.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与对象怪兽相关的已发动连锁无效化（对象怪兽在连锁中发动的效果被取消），并在变里侧或回合结束时重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 作为对象的怪兽效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 作为对象的怪兽效果无效（对已发动的效果也适用，离场后仍持续到变里侧/回合结束）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 这个回合，作为对象的怪兽不受这张卡以外的效果影响。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetValue(c1639384.efilter)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 免疫判定条件：只免疫来源于这张卡以外的效果；这张卡自身的效果仍能影响对象。
function c1639384.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
