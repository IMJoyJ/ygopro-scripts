--融合徴兵
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把额外卡组1只融合怪兽给对方观看，从自己的卡组·墓地选那只怪兽有卡名记述的1只融合素材怪兽加入手卡。这张卡的发动后，直到回合结束时自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤，那些怪兽效果不能发动。
function c17194258.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把额外卡组1只融合怪兽给对方观看，那只怪兽有卡名记述的1只融合素材怪兽从自己的卡组·墓地加入手卡。这张卡的发动后，直到回合结束时自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤，不能把那些怪兽效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,17194258+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c17194258.target)
	e1:SetOperation(c17194258.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选额外卡组融合怪兽的过滤函数：该怪兽必须是融合怪兽，并且自己的卡组·墓地中存在一只它记述了卡名的融合素材怪兽可以加入手卡。
function c17194258.filter1(c,tp)
	-- 返回条件：c是融合怪兽，且卡组·墓地存在满足filter2（能作为c的素材且可加入手卡）的卡。
	return c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(c17194258.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c)
end
-- 定义筛选融合素材的过滤函数：c必须是fc的融合素材（fc的卡名记述了c的卡名），并且c可以被加入手卡。
function c17194258.filter2(c,fc)
	-- 返回条件：c的卡名被fc的素材卡名列表包含，且c能加入手卡。
	return aux.IsMaterialListCode(fc,c:GetCode()) and c:IsAbleToHand()
end
-- 效果发动时的目标处理函数：确认发动条件成立，并设置“从卡组·墓地检索加入手卡”的操作信息。
function c17194258.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查是否存在符合条件的额外卡组融合怪兽以及对应的素材，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c17194258.filter1,tp,LOCATION_EXTRA,0,1,nil,tp) end
	-- 设置操作信息：这次效果处理涉及将卡组·墓地的1张卡加入手卡，用于后续连锁检测和效果判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理函数：从额外卡组选择并展示融合怪兽，从卡组·墓地选择对应素材加入手卡，若成功则给加入的卡设置本回合的召唤·特殊召唤·覆盖·效果发动限制。
function c17194258.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示当前玩家选择一张要展示给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从额外卡组选择1只符合条件的融合怪兽（filter1）。
	local cg=Duel.SelectMatchingCard(tp,c17194258.filter1,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	if cg:GetCount()==0 then return end
	-- 将选择的融合怪兽展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,cg)
	-- 提示当前玩家选择一张要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组·墓地选择1只符合条件的融合素材，并应用王家长眠之谷的过滤（不受其影响的卡才能选择）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c17194258.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,cg:GetFirst())
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选择的素材以效果原因送去持有者的手卡；若确实送入了手卡且卡在手牌区域，则继续执行后续的自肃效果设置。
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 将加入手卡的怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
		if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
		-- 这张卡的发动后，直到回合结束时自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤，不能把那些怪兽效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c17194258.sumlimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册对己方生效的“不能通常召唤该卡名怪兽”的永续效果，持续到回合结束。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		-- 注册对己方生效的“不能特殊召唤该卡名怪兽”的永续效果，持续到回合结束。
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_MSET)
		-- 注册对己方生效的“不能覆盖该卡名怪兽”的永续效果，持续到回合结束。
		Duel.RegisterEffect(e3,tp)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_ACTIVATE)
		e4:SetValue(c17194258.aclimit)
		-- 注册对己方生效的“不能发动该卡名怪兽的效果”的永续效果，持续到回合结束。
		Duel.RegisterEffect(e4,tp)
	end
end
-- 限制函数：判断对象怪兽是否为本次效果加入手卡的那只怪兽（通过记录的卡号判断），用于限制通常召唤·特殊召唤·覆盖。
function c17194258.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end
-- 限制函数：判断发动效果的卡是否为本次加入手卡的那只怪兽（通过记录的卡号判断），并且是怪兽卡的效果发动，用于限制效果发动。
function c17194258.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel()) and re:IsActiveType(TYPE_MONSTER)
end
