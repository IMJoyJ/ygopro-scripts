--CX 風紀大宮司サイモン
-- 效果：
-- 7星怪兽×3
-- 这张卡不受这张卡以外的怪兽的效果影响。此外，这张卡有「风纪宫司 祝词」在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡1个超量素材取除，选择对方场上1只怪兽才能发动。选择的怪兽的表示形式变更，那只怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
function c41147577.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为7的怪兽3只进行叠放
	aux.AddXyzProcedure(c,nil,7,3)
	c:EnableReviveLimit()
	-- 这张卡不受这张卡以外的怪兽的效果影响
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c41147577.efilter)
	c:RegisterEffect(e1)
	-- 1回合1次，把这张卡1个超量素材取除，选择对方场上1只怪兽才能发动。选择的怪兽的表示形式变更，那只怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
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
-- 效果过滤函数，用于判断是否免疫某个效果，当效果拥有者不是自己时生效
function c41147577.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end
-- 效果发动条件，判断是否有「风纪宫司 祝词」作为超量素材
function c41147577.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,14152862)
end
-- 效果发动费用，消耗1个超量素材
function c41147577.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 选择效果对象，选择对方场上可以变更表示形式的怪兽
function c41147577.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanChangePosition() end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上可以变更表示形式的怪兽
	Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数，变更目标怪兽表示形式并使其效果无效
function c41147577.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果在回合结束时无效
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
