--エクシーズ・フォース
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把「超量之力」以外的1张「超量」卡送去墓地。有超量怪兽在作为超量素材中的超量怪兽在场上存在的场合，也能不送去墓地加入手卡。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。场上1个超量素材取除。取除的超量素材是超量怪兽的场合，可以再把自己的墓地·除外状态的那只超量怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：①发动效果（卡组堆墓/检索），②墓地除外效果（取除超量素材并可特殊召唤）
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从卡组把「超量之力」以外的1张「超量」卡送去墓地。有超量怪兽在作为超量素材中的超量怪兽在场上存在的场合，也能不送去墓地加入手卡。
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
	-- 发动条件：这张卡在这个回合没有送去墓地
	e2:SetCondition(aux.exccon)
	-- 发动Cost：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 卡组检索/送去墓地的过滤条件：同名卡以外的「超量」卡且能送去墓地或加入手卡
function s.tgfilter(c,b)
	return not c:IsCode(id) and c:IsSetCard(0x73) and (c:IsAbleToGrave() or b and c:IsAbleToHand())
end
-- 超量素材过滤条件：是超量怪兽
function s.mfilter(c)
	return c:IsType(TYPE_XYZ)
end
-- 场上怪兽过滤条件：持有超量怪兽作为超量素材的表侧表示超量怪兽
function s.ffilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:GetOverlayGroup():IsExists(s.mfilter,1,nil)
end
-- 效果①的发动目标及合法性检测
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在拥有超量怪兽作为超量素材的超量怪兽
	local b=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	-- 检查卡组中是否存在满足条件的「超量」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,b) end
	-- 设置操作信息：从卡组把卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：从卡组把「超量」卡送去墓地或加入手卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 确认场上是否存在拥有超量怪兽作为素材的超量怪兽
	local b=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张「超量之力」以外的「超量」卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,b)
	local tc=g:GetFirst()
	if tc then
		-- 若满足条件且两项皆可执行，询问玩家是否加入手卡
		if b and tc:IsAbleToHand() and tc:IsAbleToGrave() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否加入手卡？"
			-- 将选取的卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方展示加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		elseif b and tc:IsAbleToHand() and not tc:IsAbleToGrave() then
			-- 将选取的卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方展示加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		elseif tc:IsAbleToGrave() then
			-- 将选取的卡送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- 效果②的发动目标与合法性检测
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可以被效果取除的超量素材
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) end
end
-- 效果②的处理：取除场上1个超量素材，是超量怪兽则可将其守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取除场上的1个超量素材
	if Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)~=0 then
		-- 获取被取除的超量素材卡片组
		local g=Duel.GetOperatedGroup()
		local tc=g:GetFirst()
		-- 检查主要怪兽区是否有空位，且取除的素材是原本属于自己的超量怪兽
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsType(TYPE_XYZ) and tc:GetOwner()==tp
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
			and tc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and tc:IsFaceupEx()
			and not tc:IsHasEffect(EFFECT_NECRO_VALLEY)
			-- 询问玩家是否将该超量怪兽特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否特殊召唤？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将该超量怪兽表侧守备表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
