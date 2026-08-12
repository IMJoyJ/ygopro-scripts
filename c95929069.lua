--アイス・ハンド
-- 效果：
-- ①：这张卡被对方破坏送去墓地时，以对方场上1张魔法·陷阱卡为对象才能发动。那张对方的卡破坏。那之后，可以从卡组把1只「火焰手」特殊召唤。
function c95929069.initial_effect(c)
	-- ①：这张卡被对方破坏送去墓地时，以对方场上1张魔法·陷阱卡为对象才能发动。那张对方的卡破坏。那之后，可以从卡组把1只「火焰手」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95929069,0))  --"破坏并特殊召唤"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	-- 设置效果发动条件：这张卡在自己场上被对方破坏并送去墓地
	e1:SetCondition(aux.dogcon)
	e1:SetTarget(c95929069.target)
	e1:SetOperation(c95929069.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：魔法或陷阱卡
function c95929069.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的目标选择与处理：检查并选择对方场上1张魔法·陷阱卡作为对象，并设置破坏的操作信息
function c95929069.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c95929069.dfilter(chkc) end
	-- 检查对方场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c95929069.dfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送“选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c95929069.dfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为：破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤条件：卡名为「火焰手」（卡号68535320）且可以特殊召唤的怪兽
function c95929069.spfilter(c,e,tp)
	return c:IsCode(68535320) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：破坏作为对象的卡，之后可以从卡组特殊召唤1只「火焰手」
function c95929069.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍在该效果的影响范围内，则将其因效果破坏，并确认是否破坏成功
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 检查自己场上的怪兽区域是否有空位，若无则结束效果处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取卡组中所有符合特殊召唤条件的「火焰手」
		local g=Duel.GetMatchingGroup(c95929069.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 若卡组中存在「火焰手」，则询问玩家是否选择进行特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(95929069,1)) then  --"是否要特殊召唤"
			-- 中断当前效果处理，使后续的特殊召唤处理与破坏处理不视为同时进行
			Duel.BreakEffect()
			-- 给玩家发送“选择要特殊召唤的卡”的提示信息
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的「火焰手」以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
