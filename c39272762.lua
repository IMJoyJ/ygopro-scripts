--超銀河眼の光子龍
-- 效果：
-- 8星怪兽×3
-- 「银河眼光子龙」作为素材让这张卡超量召唤成功时，这张卡以外的场上表侧表示存在的卡的效果无效。1回合1次，把这张卡1个超量素材取除才能发动。对方场上的超量素材全部取除，这个回合这张卡的攻击力上升取除数量×500的数值。并且，这个回合这张卡在同1次的战斗阶段中可以作出最多有取除数量的攻击。
function c39272762.initial_effect(c)
	-- 为这张卡设定超量召唤手续：以任意3只8星怪兽作为超量素材进行超量召唤（不限制素材种族/属性）。
	aux.AddXyzProcedure(c,nil,8,3)
	c:EnableReviveLimit()
	-- 「银河眼光子龙」作为素材让这张卡超量召唤成功时，这张卡以外的场上表侧表示存在的卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39272762,0))  --"效果无效"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c39272762.negcon)
	e1:SetOperation(c39272762.negop)
	c:RegisterEffect(e1)
	-- 「银河眼光子龙」作为素材让这张卡超量召唤成功时
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c39272762.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 1回合1次，把这张卡1个超量素材取除才能发动。对方场上的超量素材全部取除，这个回合这张卡的攻击力上升取除数量×500的数值。并且，这个回合这张卡在同1次的战斗阶段中可以作出最多有取除数量的攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetDescription(aux.Stringid(39272762,1))  --"取除素材"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c39272762.atcost)
	e3:SetTarget(c39272762.attg)
	e3:SetOperation(c39272762.atop)
	c:RegisterEffect(e3)
end
-- 检查超量召唤的素材中是否存在「银河眼光子龙」（卡号93717133），若存在则将该效果的标记label设为1，否则设为0，用于判定是否满足“用「银河眼光子龙」作为素材超量召唤成功”的条件。
function c39272762.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsCode,1,nil,93717133) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判定该效果能否发动：必须满足这张卡以超量召唤方式特殊召唤成功，且素材检查标记label为1（即使用了「银河眼光子龙」作为素材），两者同时成立时才触发。
function c39272762.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
-- 效果处理：获取场上除这张卡以外的所有表侧表示卡，对其中每张卡依次赋予“效果无效化”和“效果的效果无效化”；若为陷阱怪兽，再追加赋予“陷阱怪兽效果无效化”，这些无效效果会在该卡离场等标准时机重置。
function c39272762.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上除这张卡以外的所有表侧表示卡（包括双方怪兽区域和魔法陷阱区域的表侧卡）。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	local tc=g:GetFirst()
	while tc do
		-- 效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 效果无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
end
-- 效果发动的代价条件与处理：在发动时判定这张卡是否有1个超量素材可以作为代价（cost）；发动时实际取除这张卡的1个超量素材作为代价。
function c39272762.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动的其他条件判定：检查对方场上是否存在超量素材（数量不为0），满足时该效果才能发动。
function c39272762.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动的判定阶段（chk==0）检查对方场上的全部超量素材数量是否为0；如果不为0则允许发动（返回true），否则禁止发动。
	if chk==0 then return Duel.GetOverlayCount(tp,0,1)~=0 end
end
-- 效果处理：将对方场上的所有超量素材全部取除并送去墓地；若这张卡仍表侧存在于场上且与效果关联，则赋予这张卡攻击力上升（取除数量×500）的效果，并赋予额外攻击次数（取除数量-1次）的效果，持续到回合结束。
function c39272762.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方场上的全部超量素材，作为后续处理的卡片集合g。
	local g=Duel.GetOverlayGroup(tp,0,1)
	if g:GetCount()==0 then return end
	-- 将对方场上取除的全部超量素材以效果原因送去墓地，即执行“对方场上的超量素材全部取除”的处理。
	Duel.SendtoGrave(g,REASON_EFFECT)
	-- 中断当前效果处理流程，使后续的攻击力上升和追加攻击次数等效果处理另起一个时点，避免与前面的取除素材处理被同时处理，造成时点错误。
	Duel.BreakEffect()
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这个回合这张卡的攻击力上升取除数量×500的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(g:GetCount()*500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	-- 并且，这个回合这张卡在同1次的战斗阶段中可以作出最多有取除数量的攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(g:GetCount()-1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
end
