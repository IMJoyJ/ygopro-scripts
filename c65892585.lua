--GP－チャリオット・キャリー号
-- 效果：
-- 3星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「黄金荣耀」魔法卡加入手卡。自己基本分比对方少的场合，可以再从卡组把1只「黄金荣耀」怪兽送去墓地。
-- ②：这张卡的①的效果发动的回合的结束阶段发动。这张卡回到额外卡组，从自己的卡组·墓地把1只「黄金荣耀-卡丽船长」特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 记录本卡效果中记载了「黄金荣耀-卡丽船长」（卡号96305350）的卡名。
	aux.AddCodeList(c,96305350)
	c:EnableReviveLimit()
	-- 添加超量召唤手续：3星怪兽×2。
	aux.AddXyzProcedure(c,nil,3,2)
	-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「黄金荣耀」魔法卡加入手卡。自己基本分比对方少的场合，可以再从卡组把1只「黄金荣耀」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果发动的回合的结束阶段发动。这张卡回到额外卡组，从自己的卡组·墓地把1只「黄金荣耀-卡丽船长」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 效果①的COST：检查并取除这张卡的1个超量素材。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①检索卡片的过滤条件：卡组中的「黄金荣耀」魔法卡。
function s.filter(c)
	return c:IsSetCard(0x192) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果①的发动准备（Target）：检查卡组是否存在可检索卡，设置操作信息，并为自身注册发动过效果的标记。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可以加入手牌的「黄金荣耀」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 效果①追加送墓怪兽的过滤条件：卡组中的「黄金荣耀」怪兽。
function s.gfilter(c)
	return c:IsSetCard(0x192) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果①的处理（Operation）：检索「黄金荣耀」魔法卡，若自己基本分比对方少，可选择再将卡组1只「黄金荣耀」怪兽送去墓地。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张满足条件的「黄金荣耀」魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的卡加入手牌，若加入手牌失败则结束效果处理。
	if Duel.SendtoHand(g,nil,REASON_EFFECT)<1 then return end
	-- 向对方玩家展示加入手牌的卡。
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手牌。
	Duel.ShuffleHand(tp)
	-- 获取卡组中所有满足送墓条件的「黄金荣耀」怪兽。
	local tg=Duel.GetMatchingGroup(s.gfilter,tp,LOCATION_DECK,0,nil)
	-- 检查自己基本分是否比对方少，且之前成功将卡加入手牌。
	if Duel.GetLP(tp)<Duel.GetLP(1-tp) and #g>0
		-- 询问玩家是否选择发动追加效果（将1只怪兽送去墓地）。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再把1只怪兽送去墓地？"
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=tg:Select(tp,1,1,nil)
		-- 中断当前效果处理，使后续的送墓处理与加入手牌不视为同时进行。
		Duel.BreakEffect()
		-- 将选择的怪兽送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡在本回合发动过效果①（检查自身是否存在对应的Flag标记）。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 效果②的发动准备（Target）：设置操作信息（自身回到额外卡组，特殊召唤怪兽）。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的操作信息：将自身（这张卡）回到卡组（额外卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 设置连锁处理的操作信息：从卡组或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②特殊召唤的过滤条件：卡名为「黄金荣耀-卡丽船长」且可以特殊召唤。
function s.sfilter(c,e,tp)
	return c:IsCode(96305350) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的处理（Operation）：将自身回到额外卡组，并从卡组或墓地特殊召唤1只「黄金荣耀-卡丽船长」。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果关联，并将其回到额外卡组。
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)>0
		-- 检查自己场上是否有可用的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从卡组或墓地（受王家长眠之谷影响）选择1张「黄金荣耀-卡丽船长」。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选择的怪兽以表侧表示特殊召唤。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
