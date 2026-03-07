--エクシーズ・フォース
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把「超量之力」以外的1张「超量」卡送去墓地。有超量怪兽在作为超量素材中的超量怪兽在场上存在的场合，也能不送去墓地加入手卡。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。场上1个超量素材取除。取除的超量素材是超量怪兽的场合，可以再把自己的墓地·除外状态的那只超量怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 注册两个效果：①效果（发动时选择送去墓地或加入手卡）和②效果（从墓地除外才能发动，取除超量素材并可能特殊召唤）
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
	-- 效果发动时，若此卡在墓地且不是在本回合送去墓地的，则该效果可以发动
	e2:SetCondition(aux.exccon)
	-- 效果发动时，需要将此卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：用于筛选卡组中非「超量之力」且为超量卡组的卡，且该卡可以送去墓地或加入手卡
function s.tgfilter(c,b)
	return not c:IsCode(id) and c:IsSetCard(0x73) and (c:IsAbleToGrave() or b and c:IsAbleToHand())
end
-- 过滤函数：用于筛选超量怪兽
function s.mfilter(c)
	return c:IsType(TYPE_XYZ)
end
-- 过滤函数：用于筛选场上正面表示的超量怪兽，且其叠放区有超量怪兽
function s.ffilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:GetOverlayGroup():IsExists(s.mfilter,1,nil)
end
-- ①效果的发动时点处理：检查场上是否存在符合条件的超量怪兽，若存在则可以发动此效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在符合条件的超量怪兽
	local b=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	-- 检查卡组中是否存在满足条件的超量卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,b) end
	-- 设置连锁操作信息：准备将1张卡从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：选择卡组中符合条件的超量卡，根据场上是否存在超量怪兽决定是送去墓地还是加入手卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在符合条件的超量怪兽
	local b=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张满足条件的超量卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,b)
	local tc=g:GetFirst()
	if tc then
		-- 若场上存在符合条件的超量怪兽且该卡可以加入手卡和送去墓地，则询问玩家是否加入手卡
		if b and tc:IsAbleToHand() and tc:IsAbleToGrave() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否加入手卡？"
			-- 将选中的卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的卡
			Duel.ConfirmCards(1-tp,tc)
		elseif b and tc:IsAbleToHand() and not tc:IsAbleToGrave() then
			-- 将选中的卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的卡
			Duel.ConfirmCards(1-tp,tc)
		elseif tc:IsAbleToGrave() then
			-- 将选中的卡送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- ②效果的发动时点处理：检查是否可以移除1个超量素材
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除1个超量素材
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) end
end
-- ②效果的处理：移除1个超量素材，若该素材为超量怪兽则可特殊召唤该怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 移除1个超量素材，若成功则继续处理
	if Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)~=0 then
		-- 获取实际被移除的超量素材
		local g=Duel.GetOperatedGroup()
		local tc=g:GetFirst()
		-- 检查是否有足够的召唤位置并满足特殊召唤条件
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsType(TYPE_XYZ) and tc:GetOwner()==tp
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
			and tc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
			and not tc:IsHasEffect(EFFECT_NECRO_VALLEY)
			-- 询问玩家是否特殊召唤该超量怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 将该超量怪兽以守备表示特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
