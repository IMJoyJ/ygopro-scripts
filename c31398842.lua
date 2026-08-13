--エクシーズ・フォース
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把「超量之力」以外的1张「超量」卡送去墓地。有超量怪兽在作为超量素材中的超量怪兽在场上存在的场合，也能不送去墓地加入手卡。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。场上1个超量素材取除。取除的超量素材是超量怪兽的场合，可以再把自己的墓地·除外状态的那只超量怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 注册两个效果：①的魔法卡发动效果，从卡组将「超量之力」以外的「超量」卡送墓或在有素材条件下加入手卡；②的墓地起动效果，除外自身取除场上1个超量素材，并可将取除的超量怪兽守备表示特殊召唤。
function s.initial_effect(c)
	-- ①：从卡组把「超量之力」以外的1张「超量」卡送去墓地。有超量怪兽在作为超量素材中的超量怪兽在场上存在的场合，也能不送去墓地加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。场上1个超量素材取除。取除的超量素材是超量怪兽的场合，可以再把自己的墓地·除外状态的那只超量怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"取除超量素材"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动条件：该卡送去墓地的回合不能发动，必须满足aux.exccon（即非当回合送去墓地或符合例外情况）才能从墓地发动。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：从墓地除外这张卡自身作为发动COST。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 筛选卡组中符合条件的「超量」卡：卡名不为「超量之力」，属于「超量」系列，并且能被送去墓地；若场上有带超量素材的超量怪兽（b为真），也允许选择能加入手卡的卡。
function s.tgfilter(c,b)
	return not c:IsCode(id) and c:IsSetCard(0x73) and (c:IsAbleToGrave() or b and c:IsAbleToHand())
end
-- 判断一张卡是否为超量怪兽，用于检查超量素材中是否存在超量怪兽。
function s.mfilter(c)
	return c:IsType(TYPE_XYZ)
end
-- 判断场上是否存在表侧表示的超量怪兽，且其下方叠放有超量怪兽作为超量素材（即“有超量怪兽在作为超量素材中的超量怪兽在场上存在”）。
function s.ffilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:GetOverlayGroup():IsExists(s.mfilter,1,nil)
end
-- ①效果发动前的合法性检测与操作信息设置：检查是否存在满足条件的场上超量怪兽和卡组内的「超量」卡，并设置此效果可能涉及从卡组将卡送去墓地，供连锁判断使用。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前场上是否存在满足s.ffilter（表侧超量怪兽且其素材中有超量怪兽）的怪兽，结果存入b，用于决定能否选择加入手卡的分支。
	local b=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	-- 在效果发动合法性检查（chk==0）时，确认卡组中是否存在满足s.tgfilter的「超量」卡（且根据b判断是否允许加入手卡），若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,b) end
	-- 设置操作信息：本效果可能将卡组中的1张卡送去墓地（CATEGORY_TOGRAVE），使其他卡能够根据该信息进行连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1张符合条件的「超量」卡；若满足手牌替代条件且玩家选择加入手卡，则加入手卡并给对方确认，否则将其送去墓地。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新确认场上是否存在满足条件的超量素材怪兽，因为场上状态可能已发生变化，以此决定是否可以使用加入手卡的分支。
	local b=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	-- 显示选择提示，告知玩家要选择一张送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足s.tgfilter的「超量」卡，b作为额外参数传入，允许选择可加入手卡的卡。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,b)
	local tc=g:GetFirst()
	if tc then
		-- 如果场上有带超量素材的超量怪兽，且选中的卡既能送墓也能加入手卡，则询问玩家是否不送去墓地而加入手卡；选择否则继续送去墓地。
		if b and tc:IsAbleToHand() and tc:IsAbleToGrave() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否加入手卡？"
			-- 将选中的卡加入其持有者的手卡（不送去墓地）。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示这张加入手卡的卡，确认检索内容。
			Duel.ConfirmCards(1-tp,tc)
		elseif b and tc:IsAbleToHand() and not tc:IsAbleToGrave() then
			-- 在满足素材条件且该卡不能送去墓地但可以加入手卡的情况下，不送去墓地直接加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示这张加入手卡的卡，确认检索内容。
			Duel.ConfirmCards(1-tp,tc)
		elseif tc:IsAbleToGrave() then
			-- 将选中的卡送去墓地（通常是因为玩家没有选择加入手卡，或该卡只能送去墓地）。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- ②效果发动前的目标检测：判断我方能否以效果方式取除场上至少1个超量素材，用于决定是否满足发动条件。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查（chk==0）时，确认场上有可被取除的超量素材，只有存在时才允许发动②效果。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) end
end
-- ②效果处理：取除场上1个超量素材；若被取除的素材是超量怪兽且满足条件，则可以选择将其从自己的墓地或除外区守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行取除：由我方以效果原因取除场上1个超量素材，成功取除后继续处理。
	if Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)~=0 then
		-- 获取本次效果操作中实际被取除的卡片组，即被取除的那个超量素材。
		local g=Duel.GetOperatedGroup()
		local tc=g:GetFirst()
		-- 判断特殊召唤的基本条件：我方主要怪兽区有空位、被取除的素材是超量怪兽且其持有者是我方。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsType(TYPE_XYZ) and tc:GetOwner()==tp
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
			and tc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
			and not tc:IsHasEffect(EFFECT_NECRO_VALLEY)
			-- 询问玩家是否要将这只取除的超量怪兽特殊召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤作为独立事件处理，避免时点被合并，便于特殊召唤成功时正确触发时点。
			Duel.BreakEffect()
			-- 将选择的超量怪兽以表侧守备表示特殊召唤到我方场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
