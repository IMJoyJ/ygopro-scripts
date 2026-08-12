--百鬼羅刹大参上
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「哥布林」怪兽加入手卡。那之后，以下效果可以适用。
-- ●场上1个超量素材取除，从手卡把1只4星以下的「哥布林」怪兽特殊召唤。
-- ②：把墓地的这张卡除外才能发动。场上1个超量素材取除。那之后，可以从自己墓地把1只「哥布林」怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果：①效果（魔法卡发动）和②效果（墓地起动效果）。
function s.initial_effect(c)
	-- ①：从卡组把1只「哥布林」怪兽加入手卡。那之后，以下效果可以适用。●场上1个超量素材取除，从手卡把1只4星以下的「哥布林」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。场上1个超量素材取除。那之后，可以从自己墓地把1只「哥布林」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"取除超量素材"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 把墓地的这张卡除外作为发动的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.dtg)
	e2:SetOperation(s.dop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组/墓地的「哥布林」怪兽。
function s.filter(c)
	return c:IsSetCard(0xac) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤条件：手卡中4星以下的「哥布林」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xac) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备：检查卡组是否存在「哥布林」怪兽，并设置检索的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1只可以加入手卡的「哥布林」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组的1张卡加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组检索「哥布林」怪兽，之后可选择取除场上1个超量素材并特殊召唤手卡中4星以下的「哥布林」怪兽。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只「哥布林」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
		-- 检查自己场上是否有空怪兽区域，且手卡中是否存在可特殊召唤的4星以下「哥布林」怪兽。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
			-- 且检查场上是否存在可以取除的超量素材。
			and Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT)
			-- 且玩家选择适用追加效果（取除超量素材并特殊召唤）。
			and Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,2)) then  --"是否取除超量素材特殊召唤？"
			-- 中断当前效果处理，使后续处理与前一处理不同时进行（用于“那之后”的时点划分）。
			Duel.BreakEffect()
			-- 取除场上1个超量素材。
			Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)
			-- 让玩家从手卡选择1只4星以下的「哥布林」怪兽。
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			-- 将选中的怪兽以表侧表示特殊召唤。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ②效果的发动准备：检查场上是否存在可以取除的超量素材。
function s.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1个可以取除的超量素材。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) end
end
-- ②效果的处理：取除场上1个超量素材，之后可选择从自己墓地把1只「哥布林」怪兽加入手卡。
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查场上是否存在可以取除的超量素材。
	if Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) then
		-- 取除场上1个超量素材。
		Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)
		-- 中断当前效果处理，使后续处理与前一处理不同时进行（用于“那之后”的时点划分）。
		Duel.BreakEffect()
		-- 检查自己墓地是否存在可以加入手卡的「哥布林」怪兽。
		if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) then
			-- 询问玩家是否选择适用追加效果（从墓地回收「哥布林」怪兽）。
			if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,3)) then  --"是否选墓地的怪兽加入手卡？"
				-- 让玩家从自己墓地选择1只「哥布林」怪兽。
				local cg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
				-- 将选中的墓地怪兽加入手卡。
				Duel.SendtoHand(cg,nil,REASON_EFFECT)
				-- 给对方玩家确认加入手卡的卡。
				Duel.ConfirmCards(1-tp,cg)
			end
		end
	end
end
