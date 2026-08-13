--CX 風紀大宮司サイモン
-- 效果：
-- 7星怪兽×3
-- 这张卡不受这张卡以外的怪兽的效果影响。此外，这张卡有「风纪宫司 祝词」在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡1个超量素材取除，选择对方场上1只怪兽才能发动。选择的怪兽的表示形式变更，那只怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
function c41147577.initial_effect(c)
	-- 添加XYZ召唤手续：这张卡以3只7星怪兽为素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,7,3)
	c:EnableReviveLimit()
	-- 这张卡不受这张卡以外的怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c41147577.efilter)
	c:RegisterEffect(e1)
	-- ●1回合1次，把这张卡1个超量素材取除，选择对方场上1只怪兽才能发动。选择的怪兽的表示形式变更，那只怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41147577,0))  --"效果无效"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1)
	e2:SetCondition(c41147577.poscon)
	e2:SetCost(c41147577.poscost)
	e2:SetTarget(c41147577.postg)
	e2:SetOperation(c41147577.posop)
	c:RegisterEffect(e2)
end
-- 免疫效果的过滤函数：当效果来源是怪兽效果且发动者不是这张卡自身时，返回true，使这张卡不受该效果影响。
function c41147577.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end
-- 效果发动条件：此卡的超量素材中存在「风纪宫司 祝词」（卡号14152862）时，该效果才能发动。
function c41147577.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,14152862)
end
-- 效果发动代价：从这张卡上取除1个超量素材作为COST。
function c41147577.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动时的对象选择流程：选择对方场上1只可以变更表示形式的怪兽作为效果对象。
function c41147577.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanChangePosition() end
	-- 检查对方场上是否存在至少1只满足'可以变更表示形式'条件的怪兽，以此判断效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil) end
	-- 发动时提示玩家选择效果对象，显示'请选择效果的对象'的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从对方场上选择1只可以变更表示形式的怪兽，并将其登记为这次效果的对象。
	Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：取对象怪兽，若该怪兽仍与效果关联，则变更其表示形式，并将其效果直到回合结束时无效。
function c41147577.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时确定的第1个对象怪兽（即发动时选择的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 变更对象怪兽的表示形式：表侧攻击表示变为表侧守备表示，表侧守备表示变为表侧攻击表示，里侧表示变为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		-- 使与对象怪兽相关的连锁处理无效化，并在该怪兽变为里侧表示时重置此无效状态。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
