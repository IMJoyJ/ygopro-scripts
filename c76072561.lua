--閃刀姫＝ゼロ
-- 效果：
-- 「闪刀姬」怪兽2只
-- 自己对「闪刀姬=零露」1回合只能有1次特殊召唤，这张卡不能作为连接素材。这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡特殊召唤的场合才能发动。从自己的卡组·墓地把1张「闪刀」魔法卡加入手卡。
-- ②：自己·对方回合，把这张卡解放才能发动。「闪刀姬-零衣」「闪刀姬-露世」各1只从自己的卡组·墓地特殊召唤。那之后，可以把场上1张卡破坏。
local s,id,o=GetID()
-- 注册卡片初始效果，包括记载卡名、特殊召唤限制、连接召唤手续、不能作为连接素材、特殊召唤成功时检索「闪刀」魔法卡，以及解放自身特殊召唤「闪刀姬-零衣」和「闪刀姬-露世」并破坏场上卡片的效果。
function s.initial_effect(c)
	-- 记录该卡效果中记载了「闪刀姬-零衣」与「闪刀姬-露世」的卡名。
	aux.AddCodeList(c,26077387,37351133)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：需要2只「闪刀姬」怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x1115),2,2)
	-- 这张卡不能作为连接素材。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- ①：这张卡特殊召唤的场合才能发动。从自己的卡组·墓地把1张「闪刀」魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索魔法卡"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，把这张卡解放才能发动。「闪刀姬-零衣」「闪刀姬-露世」各1只从自己的卡组·墓地特殊召唤。那之后，可以把场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检索卡组或墓地中属于「闪刀」系列且是魔法卡、能加入手牌的卡。
function s.filter(c)
	return c:IsSetCard(0x115) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果①（检索「闪刀」魔法卡）的发动准备与合法性检测函数。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地中是否存在至少1张满足条件的「闪刀」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息：从卡组或墓地将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①（检索「闪刀」魔法卡）的效果处理函数。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地（受王家长眠之谷影响）选择1张满足条件的「闪刀」魔法卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡因效果加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②（特殊召唤「零衣」和「露世」）的发动代价（Cost）函数。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查此卡是否可以解放，且解放此卡后自己场上是否有2个以上的空怪兽区域。
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c,tp)>1 end
	-- 解放此卡作为发动的代价。
	Duel.Release(c,REASON_COST)
end
-- 过滤函数：检查卡片是否为「闪刀姬-零衣」且可以被特殊召唤。
function s.spfilter1(c,e,tp)
	return c:IsCode(26077387) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数：检查卡片是否为「闪刀姬-露世」且可以被特殊召唤。
function s.spfilter2(c,e,tp)
	return c:IsCode(37351133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数：确保选择的卡片组中包含2种不同卡名的卡（即「零衣」和「露世」各1只）。
function s.fselect(g)
	return g:GetClassCount(Card.GetCode)==2
end
-- 效果②（特殊召唤「零衣」和「露世」）的发动准备与合法性检测函数。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查卡组或墓地中是否存在至少1只可以特殊召唤的「闪刀姬-零衣」。
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查卡组或墓地中是否存在至少1只可以特殊召唤的「闪刀姬-露世」。
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组或墓地特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②（特殊召唤「零衣」和「露世」并可选破坏场上卡片）的效果处理函数。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取卡组或墓地中所有满足条件的「闪刀姬-零衣」（受王家长眠之谷影响）。
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	-- 获取卡组或墓地中所有满足条件的「闪刀姬-露世」（受王家长眠之谷影响）。
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if #g1>=1 and #g2>=1 then
		g1:Merge(g2)
		local sg=g1:SelectSubGroup(tp,s.fselect,false,2,2)
		-- 将选中的「闪刀姬-零衣」和「闪刀姬-露世」以表侧表示特殊召唤，并判断是否特殊召唤成功。
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0
			-- 检查场上是否存在至少1张卡（用于后续的破坏效果）。
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			-- 询问玩家是否选择发动后续的破坏效果。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否选卡破坏？"
			-- 提示玩家选择要破坏的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 让玩家选择场上的1张卡。
			local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if #dg>0 then
				-- 中断当前效果处理，使后续的破坏处理与特殊召唤不视为同时进行（造成错时点）。
				Duel.BreakEffect()
				-- 闪烁显示被选为破坏对象的卡片。
				Duel.HintSelection(dg)
				-- 将选中的卡因效果破坏。
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
end
