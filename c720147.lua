--王の憤激
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上的「王战」怪兽任意数量解放，以自己场上1只超量怪兽为对象才能发动。从自己的手卡·场上·墓地选解放数量的解放的怪兽以外的「王战」怪兽在作为对象的怪兽下面重叠作为超量素材。
function c720147.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上的「王战」怪兽任意数量解放，以自己场上1只超量怪兽为对象才能发动。从自己的手卡·场上·墓地选解放数量的解放的怪兽以外的「王战」怪兽在作为对象的怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,720147+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c720147.cost)
	e1:SetTarget(c720147.target)
	e1:SetOperation(c720147.activate)
	c:RegisterEffect(e1)
end
-- 效果发动代价（Cost）处理函数，将Label设为1以标记该效果在发动时需要支付代价（解放怪兽）。
function c720147.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤可作为解放代价的「王战」怪兽，且该怪兽被解放后，场上仍存在可作为效果对象的超量怪兽。
function c720147.costfilter(c,tp)
	-- 检查卡片是否为「王战」卡，且在排除该卡后，场上是否存在至少1只满足超量素材重叠条件的超量怪兽。
	return c:IsSetCard(0x134) and Duel.IsExistingTarget(c720147.matfilter1,tp,LOCATION_MZONE,0,1,c,tp,Group.FromCards(c))
end
-- 过滤作为效果对象的超量怪兽，要求其为表侧表示，且手卡/场上/墓地存在足够数量的、不包含已被解放怪兽的「王战」怪兽作为超量素材。
function c720147.matfilter1(c,tp,g)
	local sg=g:Clone()
	sg:AddCard(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查手卡、场上、墓地是否存在至少与解放数量相同的、不包含在排除组中的、可作为超量素材的「王战」怪兽。
		and Duel.IsExistingMatchingCard(c720147.matfilter2,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,g:GetCount(),sg)
end
-- 过滤可作为超量素材的「王战」怪兽，要求其为「王战」怪兽卡且可以被重叠为超量素材。
function c720147.matfilter2(c)
	return c:IsSetCard(0x134) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 检查玩家选择的解放怪兽组是否合法：排除该组后场上仍有合法的超量怪兽作为对象，且该组中的卡全部可以被解放。
function c720147.fselect(g,tp)
	-- 检查在排除已选择的解放怪兽组后，场上是否存在至少1只合法的超量怪兽作为效果对象。
	return Duel.IsExistingTarget(c720147.matfilter1,tp,LOCATION_MZONE,0,1,g,tp,g)
		-- 检查选择的卡片组是否全部属于可解放的卡片。
		and Duel.CheckReleaseGroup(tp,aux.IsInGroup,#g,nil,g)
end
-- 效果发动时的目标选择与代价支付处理函数。
function c720147.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetLabelObject()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c720147.matfilter1(chkc,tp,g) end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		-- 检查玩家场上是否存在至少1只满足解放条件的「王战」怪兽。
		return Duel.CheckReleaseGroup(tp,c720147.costfilter,1,nil,tp)
	end
	-- 获取玩家场上所有满足解放条件的「王战」怪兽卡组。
	local rg=Duel.GetReleaseGroup(tp):Filter(c720147.costfilter,nil,tp)
	-- 提示玩家选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,c720147.fselect,false,1,rg:GetCount(),tp)
	sg:KeepAlive()
	e:SetLabelObject(sg)
	-- 强制应用类似「暗影敌托邦」等代替解放的效果次数限制。
	aux.UseExtraReleaseCount(sg,tp)
	-- 将选中的怪兽作为发动代价解放。
	Duel.Release(sg,REASON_COST)
	-- 遍历所有被解放的怪兽。
	for rc in aux.Next(sg) do
		rc:CreateEffectRelation(e)
	end
	-- 提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只自己场上的表侧表示超量怪兽作为效果对象，并排除已被解放的怪兽。
	Duel.SelectTarget(tp,c720147.matfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp,sg)
end
-- 效果生效时的处理（Operation）函数。
function c720147.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为效果对象的超量怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local rg=e:GetLabelObject()
		local exg=rg:Filter(Card.IsRelateToEffect,nil,e)
		exg:AddCard(tc)
		-- 提示玩家选择要作为超量素材的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从手卡、场上、墓地选择与解放数量相同的、不受「王家之谷」影响的「王战」怪兽，排除已被解放的怪兽和作为对象的超量怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c720147.matfilter2),tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,rg:GetCount(),rg:GetCount(),exg)
		if g:GetCount()>0 then
			-- 遍历选中的将要作为超量素材的卡片。
			for oc in aux.Next(g) do
				local og=oc:GetOverlayGroup()
				if og:GetCount()>0 then
					-- 将这些卡片原本拥有的超量素材因规则送去墓地。
					Duel.SendtoGrave(og,REASON_RULE)
				end
			end
			-- 将选中的「王战」怪兽重叠在作为对象的超量怪兽下面作为超量素材。
			Duel.Overlay(tc,g)
		end
	end
end
