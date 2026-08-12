--タリホー！スプリガンズ！
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。这张卡也能把自己场上最多3个超量素材取除来发动。
-- ①：从卡组把1只「护宝炮妖」怪兽加入手卡。把超量素材取除来把这张卡发动的场合，可以再从自己的手卡·墓地把那个数量的「护宝炮妖」怪兽特殊召唤。
-- ②：自己主要阶段有这张卡在墓地存在的场合，以场上1只超量怪兽为对象才能发动。那只怪兽1个超量素材取除，这张卡加入手卡。
function c9175957.initial_effect(c)
	-- 这张卡也能把自己场上最多3个超量素材取除来发动。①：从卡组把1只「护宝炮妖」怪兽加入手卡。把超量素材取除来把这张卡发动的场合，可以再从自己的手卡·墓地把那个数量的「护宝炮妖」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9175957,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,9175957)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c9175957.cost)
	e1:SetTarget(c9175957.target)
	e1:SetOperation(c9175957.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段有这张卡在墓地存在的场合，以场上1只超量怪兽为对象才能发动。那只怪兽1个超量素材取除，这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9175957,3))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,9175957)
	e2:SetTarget(c9175957.mattg)
	e2:SetOperation(c9175957.matop)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价处理：检查并让玩家选择是否取除自己场上的超量素材发动，并记录取除的数量
function c9175957.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local spct=0
	-- 检查自己场上是否存在可以作为代价取除的超量素材
	if Duel.CheckRemoveOverlayCard(tp,LOCATION_MZONE,0,1,REASON_COST)
		-- 询问玩家是否要取除超量素材来发动这张卡
		and Duel.SelectYesNo(tp,aux.Stringid(9175957,1)) then  --"是否取除超量素材发动？"
		-- 让玩家选择并取除1到3个超量素材，并记录实际取除的数量
		spct=Duel.RemoveOverlayCard(tp,LOCATION_MZONE,0,1,3,REASON_COST)
	end
	e:SetLabel(spct)
end
-- 过滤条件：卡组中的「护宝炮妖」怪兽且能加入手卡
function c9175957.thfilter(c)
	return c:IsSetCard(0x155) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备：检查卡组中是否存在可检索的怪兽，设置操作信息，并根据是否取除了素材动态调整效果分类
function c9175957.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只「护宝炮妖」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c9175957.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	local spct=e:GetLabel()
	if spct>0 then
		e:SetCategory(e:GetCategory()|CATEGORY_GRAVE_SPSUMMON|CATEGORY_SPECIAL_SUMMON)
	else
		e:SetCategory(e:GetCategory()&~(CATEGORY_GRAVE_SPSUMMON|CATEGORY_SPECIAL_SUMMON))
	end
end
-- 过滤条件：「护宝炮妖」怪兽且能被特殊召唤
function c9175957.spfilter(c,e,tp)
	return c:IsSetCard(0x155) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的效果处理：从卡组检索1只「护宝炮妖」怪兽，若发动时取除了超量素材，则可以再从手卡·墓地特殊召唤对应数量的「护宝炮妖」怪兽
function c9175957.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的「护宝炮妖」怪兽
	local g=Duel.SelectMatchingCard(tp,c9175957.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 获取自己场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 计算手卡和墓地中满足特殊召唤条件的「护宝炮妖」怪兽数量（受王家长眠之谷影响）
		local ct=Duel.GetMatchingGroupCount(aux.NecroValleyFilter(c9175957.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
		local spct=e:GetLabel()
		if spct>0 and ct>=spct and ft>=spct
			-- 询问玩家是否要特殊召唤「护宝炮妖」怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(9175957,2)) then  --"是否特殊召唤「护宝炮妖」怪兽？"
			-- 中断当前效果处理，使后续的特殊召唤处理与检索处理不视为同时进行
			Duel.BreakEffect()
			-- 让玩家从手卡·墓地选择与取除素材数量相同的「护宝炮妖」怪兽（受王家长眠之谷影响）
			local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c9175957.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,spct,spct,nil,e,tp)
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤条件：场上表侧表示的超量怪兽，且拥有可以被效果取除的超量素材
function c9175957.matfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
end
-- 效果②的发动准备：检查自身是否能加入手卡，并选择场上1只表侧表示的超量怪兽作为对象，设置操作信息
function c9175957.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c9175957.matfilter(chkc,tp) end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 检查场上是否存在可以作为效果对象的超量怪兽
		and Duel.IsExistingTarget(c9175957.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择场上1只满足条件的超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c9175957.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息：将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果②的效果处理：取除目标怪兽的1个超量素材，若成功则将墓地的这张卡加入手卡
function c9175957.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT)>0
		and c:IsRelateToEffect(e) then
		-- 将墓地的这张卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
