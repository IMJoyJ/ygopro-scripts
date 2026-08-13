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
-- 筛选可以作为对象的自己场上表侧表示怪兽：必须是表侧表示，且自己卡组中存在与它当前卡号相同的卡并能加入手卡。
function c34460239.filter(c,tp)
	return c:IsFaceup()
		-- 检查卡组中是否存在1张与目标怪兽当前卡号相同且能够加入手卡的卡。
		and Duel.IsExistingMatchingCard(c34460239.nfilter1,tp,LOCATION_DECK,0,1,nil,c)
end
-- 定义卡组检索的匹配条件：卡组中的卡与目标怪兽当前卡号一致，且能够加入手卡。
function c34460239.nfilter1(c,tc)
	return c:IsCode(tc:GetCode()) and c:IsAbleToHand()
end
-- 定义破坏后检索的匹配条件：卡组中的卡与目标怪兽在场上时的原卡号一致，且能够加入手卡。
function c34460239.nfilter2(c,tc)
	return c:IsCode(tc:GetPreviousCodeOnField()) and c:IsAbleToHand()
end
-- 发动时的目标选择阶段：选择自己场上表侧表示的1只怪兽（需满足条件），并设置破坏与检索的操作信息。
function c34460239.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c34460239.filter(chkc,tp) end
	-- 发动合法性判定：确认自己场上是否存在满足条件的表侧表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c34460239.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 显示选择提示，要求玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己场上的表侧表示怪兽中选择1只作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c34460239.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息：将选择的对象怪兽作为破坏效果的处理对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：效果处理时将从卡组把1张卡加入手卡，检索区域为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：取得对象；若对象仍表侧且与效果关联，则将其破坏；破坏成功后，从卡组选择1张与破坏的卡同名的卡加入手卡，并向对方确认。
function c34460239.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍表侧表示且与效果关联，并尝试以效果将其破坏；若破坏成功则继续后续处理。
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 中断当前效果时点，使破坏处理和检索加入手卡处理分开，避免时点被占用。
		Duel.BreakEffect()
		-- 从卡组中选择1张与已破坏怪兽在场上时的原卡号相同且能加入手卡的卡。
		local g=Duel.SelectMatchingCard(tp,c34460239.nfilter2,tp,LOCATION_DECK,0,1,1,nil,tc)
		local hc=g:GetFirst()
		if hc then
			-- 将选择的那张卡以效果原因加入其持有者的手卡。
			Duel.SendtoHand(hc,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的那张卡。
			Duel.ConfirmCards(1-tp,hc)
		end
	end
end
