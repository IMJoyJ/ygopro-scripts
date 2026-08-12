--No.25 重装光学撮影機フォーカス・フォース
-- 效果：
-- 6星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只5星以上的效果怪兽为对象才能发动。那只对方怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
function c64554883.initial_effect(c)
	-- 添加超量召唤手续：6星怪兽×2
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只5星以上的效果怪兽为对象才能发动。那只对方怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64554883,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c64554883.cost)
	e1:SetTarget(c64554883.target)
	e1:SetOperation(c64554883.operation)
	c:RegisterEffect(e1)
end
-- 设置该卡片的“No.”数值为25
aux.xyz_number[64554883]=25
-- 效果发动的代价：取除这张卡1个超量素材
function c64554883.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选对方场上等级5以上且未被无效的效果怪兽
function c64554883.filter(c)
	-- 判定卡片是否为等级5以上且可以被无效的效果怪兽
	return c:IsLevelAbove(5) and aux.NegateEffectMonsterFilter(c)
end
-- 效果发动的目标选择与确认
function c64554883.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c64554883.filter(chkc) end
	-- 在发动阶段，检查对方场上是否存在至少1只满足条件的5星以上效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c64554883.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c64554883.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：操作分类为无效效果，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理：使作为对象的怪兽效果直到回合结束时无效
function c64554883.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动阶段选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsCanBeDisabledByEffect(e) then
		-- 那只对方怪兽的效果直到回合结束时无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只对方怪兽的效果直到回合结束时无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
