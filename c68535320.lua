--ファイヤー・ハンド
-- 效果：
-- ①：这张卡被对方破坏送去墓地时，以对方场上1只怪兽为对象才能发动。那只对方怪兽破坏。那之后，可以从卡组把1只「寒冰手」特殊召唤。
function c68535320.initial_effect(c)
	-- ①：这张卡被对方破坏送去墓地时，以对方场上1只怪兽为对象才能发动。那只对方怪兽破坏。那之后，可以从卡组把1只「寒冰手」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68535320,0))  --"破坏并特殊召唤"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	-- 设置发动条件为通用函数aux.dogcon：确认这张卡是从己方场上被对方破坏并送去墓地
	e1:SetCondition(aux.dogcon)
	e1:SetTarget(c68535320.target)
	e1:SetOperation(c68535320.operation)
	c:RegisterEffect(e1)
end
-- 发动检测、取对象及连锁信息设置：确认对方怪兽区存在怪兽，选择1只作为对象并登记破坏操作信息
function c68535320.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 发动条件检查：确认对方怪兽区存在至少1只可成为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向己方提示选择要破坏的对方怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让己方从对方怪兽区选择1只怪兽作为连锁对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记连锁的破坏操作信息，预计破坏所选对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 筛选条件：检查卡片是否为可特殊召唤的「寒冰手」
function c68535320.spfilter(c,e,tp)
	return c:IsCode(95929069) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理流程：破坏作为对象的对方怪兽；若破坏成功且己方怪兽区有空位，则可选从卡组把1只「寒冰手」特殊召唤
function c68535320.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁所指定的对方怪兽对象
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍在连锁中并以效果将其破坏，判断是否破坏成功
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 检查己方主要怪兽区是否有空位，若无空位则结束处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取己方卡组中全部可特殊召唤的「寒冰手」卡片组
		local g=Duel.GetMatchingGroup(c68535320.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 若卡组存在可特召的「寒冰手」，询问己方是否要特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(68535320,1)) then  --"是否要特殊召唤"
			-- 中断效果处理，使后续的特殊召唤与前面的破坏视为不同时处理
			Duel.BreakEffect()
			-- 向己方提示选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将所选「寒冰手」以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
