--ライトロード・アーチャー フェリス
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
-- ①：这张卡被怪兽的效果从卡组送去墓地的场合发动。这张卡特殊召唤。
-- ②：把这张卡解放，以对方场上1只怪兽为对象才能发动。那只对方怪兽破坏。那之后，从自己卡组上面把3张卡送去墓地。
function c73176465.initial_effect(c)
	-- ①：这张卡被怪兽的效果从卡组送去墓地的场合发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73176465,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c73176465.condtion)
	e1:SetTarget(c73176465.target)
	e1:SetOperation(c73176465.operation)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放，以对方场上1只怪兽为对象才能发动。那只对方怪兽破坏。那之后，从自己卡组上面把3张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73176465,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c73176465.descost)
	e2:SetTarget(c73176465.destg)
	e2:SetOperation(c73176465.desop)
	c:RegisterEffect(e2)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(c73176465.splimit)
	c:RegisterEffect(e3)
end
-- 特殊召唤限制条件：只能通过卡的效果进行特殊召唤
function c73176465.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 效果1的发动条件：此卡因怪兽效果从卡组送去墓地
function c73176465.condtion(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and re:IsActiveType(TYPE_MONSTER)
		and e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 效果1的发动准备：此效果为必发效果，直接返回true并设置特殊召唤的操作信息
function c73176465.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的操作信息，将自身作为特殊召唤的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果1的效果处理：若此卡仍存在于墓地，则将其特殊召唤
function c73176465.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果2的Cost：检查并解放自身
function c73176465.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的Cost
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果2的对象选择与发动条件检查：确认自己能将卡组上方3张卡送去墓地，且对方场上存在可作为对象的怪兽
function c73176465.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 检查自己是否能将卡组最上方的3张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3)
		-- 检查对方场上是否存在可以作为效果对象的怪兽
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 在界面上提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置破坏的操作信息，包含选择的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置从卡组送去墓地的操作信息，数量为3张
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,tp,3)
end
-- 效果2的效果处理：破坏对象怪兽，之后将卡组上方3张卡送去墓地
function c73176465.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用此效果，则将其破坏，并确认是否破坏成功
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 中断当前效果处理，使后续的送去墓地处理与破坏不视为同时进行
		Duel.BreakEffect()
		-- 将自己卡组最上方的3张卡送去墓地
		Duel.DiscardDeck(tp,3,REASON_EFFECT)
	end
end
