--融合徴兵
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把额外卡组1只融合怪兽给对方观看，从自己的卡组·墓地选那只怪兽有卡名记述的1只融合素材怪兽加入手卡。这张卡的发动后，直到回合结束时自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤，那些怪兽效果不能发动。
function c17194258.initial_effect(c)
	-- ①：把额外卡组1只融合怪兽给对方观看，从自己的卡组·墓地选那只怪兽有卡名记述的1只融合素材怪兽加入手卡。这张卡的发动后，直到回合结束时自己不能把这个效果加入手卡的怪兽以及那些同名怪兽通常召唤·特殊召唤，那些怪兽效果不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,17194258+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c17194258.target)
	e1:SetOperation(c17194258.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查以玩家来看的额外卡组是否存在至少1只融合怪兽，并且该怪兽在自己的卡组或墓地存在其融合素材怪兽。
function c17194258.filter1(c,tp)
	-- 检查以玩家来看的额外卡组是否存在至少1只融合怪兽，并且该怪兽在自己的卡组或墓地存在其融合素材怪兽。
	return c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(c17194258.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c)
end
-- 过滤函数，检查以玩家来看的卡组或墓地是否存在至少1张满足条件的卡，该卡是给定融合怪兽的融合素材，并且可以送去手牌。
function c17194258.filter2(c,fc)
	-- 检查以玩家来看的卡组或墓地是否存在至少1张满足条件的卡，该卡是给定融合怪兽的融合素材，并且可以送去手牌。
	return aux.IsMaterialListCode(fc,c:GetCode()) and c:IsAbleToHand()
end
-- 效果处理时的判断条件，检查以玩家来看的额外卡组是否存在至少1只融合怪兽。
function c17194258.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家来看的额外卡组是否存在至少1只融合怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c17194258.filter1,tp,LOCATION_EXTRA,0,1,nil,tp) end
	-- 设置连锁处理信息，表示效果处理时将从玩家的卡组或墓地选择1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理函数，选择并确认额外卡组的融合怪兽，然后从卡组或墓地选择其融合素材怪兽加入手牌，并设置后续限制效果。
function c17194258.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择一张额外卡组的融合怪兽给对方确认。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从玩家的额外卡组中选择1只融合怪兽。
	local cg=Duel.SelectMatchingCard(tp,c17194258.filter1,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	if cg:GetCount()==0 then return end
	-- 向对方确认所选的融合怪兽。
	Duel.ConfirmCards(1-tp,cg)
	-- 提示玩家选择一张要加入手牌的融合素材怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从玩家的卡组或墓地中选择1张满足条件的融合素材怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c17194258.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,cg:GetFirst())
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的融合素材怪兽送去手牌，并判断是否成功加入手牌。
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 向对方确认所选的融合素材怪兽。
		Duel.ConfirmCards(1-tp,tc)
		if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
		-- 创建并注册一系列限制效果，禁止玩家在本回合召唤、特殊召唤、覆盖放置以及发动与该融合素材怪兽同名的怪兽效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c17194258.sumlimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册禁止玩家通常召唤的限制效果。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		-- 注册禁止玩家特殊召唤的限制效果。
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_MSET)
		-- 注册禁止玩家覆盖放置的限制效果。
		Duel.RegisterEffect(e3,tp)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_ACTIVATE)
		e4:SetValue(c17194258.aclimit)
		-- 注册禁止玩家发动效果的限制效果。
		Duel.RegisterEffect(e4,tp)
	end
end
-- 限制效果的目标函数，判断目标怪兽是否与指定卡号相同。
function c17194258.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end
-- 限制效果的发动限制函数，判断是否为与指定卡号相同的怪兽效果发动。
function c17194258.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel()) and re:IsActiveType(TYPE_MONSTER)
end
