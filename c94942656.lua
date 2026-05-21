--ステルス・クラーゲン・エフィラ
-- 效果：
-- 水属性4星怪兽×2
-- ①：1回合1次，自己·对方的主要阶段才能发动。选对方场上1只水属性怪兽破坏。
-- ②：「No.」超量怪兽的效果特殊召唤的这张卡被破坏的场合才能发动。从自己墓地选最多有这张卡持有的超量素材数量的这张卡以外的「隐形水母怪」怪兽特殊召唤。并且可以再给那些特殊召唤的怪兽各从自己墓地选最多1只水属性怪兽作为那超量素材。
function c94942656.initial_effect(c)
	-- 设置超量召唤手续：水属性4星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己·对方的主要阶段才能发动。选对方场上1只水属性怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94942656,0))  --"水属性怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(c94942656.descon)
	e1:SetTarget(c94942656.destg)
	e1:SetOperation(c94942656.desop)
	c:RegisterEffect(e1)
	-- 「No.」超量怪兽的效果特殊召唤的这张卡
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c94942656.regcon)
	e2:SetOperation(c94942656.regop)
	c:RegisterEffect(e2)
	-- 被破坏的场合才能发动。从自己墓地选最多有这张卡持有的超量素材数量的这张卡以外的「隐形水母怪」怪兽特殊召唤。并且可以再给那些特殊召唤的怪兽各从自己墓地选最多1只水属性怪兽作为那超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(94942656,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c94942656.spcon)
	e3:SetTarget(c94942656.sptg)
	e3:SetOperation(c94942656.spop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：自己或对方的主要阶段。
function c94942656.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤对方场上表侧表示的水属性怪兽。
function c94942656.desfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果①的发动准备：检查是否存在可破坏的卡并设置破坏操作信息。
function c94942656.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧表示的水属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c94942656.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示的水属性怪兽。
	local g=Duel.GetMatchingGroup(c94942656.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置当前连锁的操作信息为破坏1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的处理：选择对方场上1只水属性怪兽破坏。
function c94942656.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1只表侧表示的水属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c94942656.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 为选中的怪兽显示被选为对象的动画效果。
		Duel.HintSelection(g)
		-- 因效果破坏选中的怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 检查这张卡是否是由「No.」超量怪兽的效果特殊召唤成功。
function c94942656.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x48) and re:IsActiveType(TYPE_MONSTER)
end
-- 给这张卡注册一个标记，表示其是由「No.」超量怪兽的效果特殊召唤的。
function c94942656.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(94942656,RESET_EVENT+RESET_TURN_SET+RESET_TOHAND+RESET_TODECK+RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(94942656,3))  --"「No.」超量怪兽的效果特殊召唤"
end
-- 效果②的发动条件：在怪兽区被破坏，且带有「No.」效果特召标记，且被破坏时持有超量素材。
function c94942656.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetPreviousOverlayCountOnField()
	e:SetLabel(ct)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:GetFlagEffect(94942656)>0 and ct>0
end
-- 过滤墓地中可以特殊召唤的「隐形水母怪」怪兽。
function c94942656.spfilter(c,e,tp)
	return c:IsSetCard(0x168) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查怪兽区域空位及墓地中是否存在可特召的怪兽。
function c94942656.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在除自身以外可特殊召唤的「隐形水母怪」怪兽。
		and Duel.IsExistingMatchingCard(c94942656.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 设置当前连锁的操作信息为从墓地特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 过滤墓地中可以作为超量素材的水属性卡片。
function c94942656.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanOverlay()
end
-- 效果②的处理：特殊召唤墓地的「隐形水母怪」怪兽，并可选择为其补充墓地的水属性怪兽作为超量素材。
function c94942656.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	ft=math.min(ft,e:GetLabel())
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从墓地选择最多等同于原素材数量且不超过可用格子数的「隐形水母怪」怪兽（受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c94942656.spfilter),tp,LOCATION_GRAVE,0,1,ft,e:GetHandler(),e,tp)
	-- 如果选中的怪兽数量大于0，则将它们以表侧表示特殊召唤。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取实际成功特殊召唤到怪兽区域的怪兽。
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_MZONE)
		-- 获取自己墓地中所有可作为超量素材的水属性卡片（受王家长眠之谷影响）。
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c94942656.matfilter),tp,LOCATION_GRAVE,0,nil)
		local res=false
		local tc=og:GetFirst()
		while tc do
			if sg:GetCount()==0 then return end
			-- 询问玩家是否要为该特殊召唤的怪兽重叠超量素材。
			if Duel.SelectEffectYesNo(tp,tc,aux.Stringid(94942656,2)) then  --"是否为此怪兽补充超量素材？"
				if res==false then
					res=true
					-- 中断当前效果处理，使后续的重叠素材处理与特殊召唤不视为同时进行。
					Duel.BreakEffect()
				end
				-- 提示玩家选择要作为超量素材的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
				local tg=sg:Select(tp,1,1,nil)
				-- 将选中的卡作为超量素材重叠在对应的怪兽下。
				Duel.Overlay(tc,tg)
				sg:Sub(tg)
			end
			tc=og:GetNext()
		end
	end
end
