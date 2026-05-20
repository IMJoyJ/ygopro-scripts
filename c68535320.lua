--ファイヤー・ハンド
-- 效果：
-- ①：这张卡被对方破坏送去墓地时，以对方场上1只怪兽为对象才能发动。那只对方怪兽破坏。那之后，可以从卡组把1只「寒冰手」特殊召唤。
function c68535320.initial_effect(c)
	-- ①：这张卡被对方破坏送去墓地时，以对方场上1只怪兽为对象才能发动。那只对方怪兽破坏。那之后，可以从卡组把1只「寒冰手」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68535320,0))  --"破坏并特殊召唤"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	-- 设置效果发动条件：这张卡在自己场上被对方破坏并送去墓地
	e1:SetCondition(aux.dogcon)
	e1:SetTarget(c68535320.target)
	e1:SetOperation(c68535320.operation)
	c:RegisterEffect(e1)
end
-- 效果①的发动准备（检查是否满足发动条件、选择对象并设置操作信息）
function c68535320.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象且能被破坏的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤卡组中卡名为「寒冰手」且可以特殊召唤的怪兽
function c68535320.spfilter(c,e,tp)
	return c:IsCode(95929069) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的处理（破坏对象怪兽，并可以从卡组特殊召唤「寒冰手」）
function c68535320.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果相关联，则将其用效果破坏，并判断是否破坏成功
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 检查自己场上是否有空余的怪兽区域，若无则结束效果处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取卡组中所有符合特殊召唤条件的「寒冰手」
		local g=Duel.GetMatchingGroup(c68535320.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 若卡组中存在「寒冰手」，则询问玩家是否选择进行特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(68535320,1)) then  --"是否要特殊召唤"
			-- 中断当前效果处理，使后续的特殊召唤处理与破坏处理不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的「寒冰手」以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
