--ジェネレーション・チェンジ
-- 效果：
-- 选择自己场上表侧表示存在的1只怪兽破坏。那之后，从卡组把1张和破坏的卡同名的卡加入手卡。
function c34460239.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只怪兽破坏。那之后，从卡组把1张和破坏的卡同名的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c34460239.target)
	e1:SetOperation(c34460239.activate)
	c:RegisterEffect(e1)
end
-- 检查目标怪兽是否表侧表示且卡组存在与该怪兽同名的可加入手卡的卡。
function c34460239.filter(c,tp)
	return c:IsFaceup()
		-- 检查卡组中是否存在与目标怪兽同名且可加入手卡的卡。
		and Duel.IsExistingMatchingCard(c34460239.nfilter1,tp,LOCATION_DECK,0,1,nil,c)
end
-- 检查卡是否与目标怪兽同名且可加入手卡。
function c34460239.nfilter1(c,tc)
	return c:IsCode(tc:GetCode()) and c:IsAbleToHand()
end
-- 检查卡是否与目标怪兽破坏前的卡名相同且可加入手卡。
function c34460239.nfilter2(c,tc)
	return c:IsCode(tc:GetPreviousCodeOnField()) and c:IsAbleToHand()
end
-- 设置效果目标为己方场上表侧表示的怪兽，且该怪兽满足破坏条件。
function c34460239.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c34460239.filter(chkc,tp) end
	-- 检查己方场上是否存在满足条件的怪兽作为目标。
	if chk==0 then return Duel.IsExistingTarget(c34460239.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向玩家提示选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的1只己方场上表侧表示的怪兽作为目标。
	local g=Duel.SelectTarget(tp,c34460239.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置效果操作信息为破坏目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果操作信息为从卡组检索1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果的发动，破坏目标怪兽并检索同名卡加入手卡。
function c34460239.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否表侧表示、是否与效果相关联且成功破坏。
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 中断当前效果处理，使后续处理视为错时点。
		Duel.BreakEffect()
		-- 从卡组选择与目标怪兽同名的1张卡。
		local g=Duel.SelectMatchingCard(tp,c34460239.nfilter2,tp,LOCATION_DECK,0,1,1,nil,tc)
		local hc=g:GetFirst()
		if hc then
			-- 将选中的卡加入手卡。
			Duel.SendtoHand(hc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的卡。
			Duel.ConfirmCards(1-tp,hc)
		end
	end
end
