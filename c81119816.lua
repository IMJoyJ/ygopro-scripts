--プランキッズ・パルス
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡作为「调皮宝贝」怪兽的所用融合素材或者所用连接素材送去墓地的场合才能发动。从卡组把「调皮宝贝·脉冲娃」以外的1张「调皮宝贝」卡送去墓地。那之后，可以从手卡·卡组把「调皮宝贝·脉冲娃」以外的1只「调皮宝贝」怪兽守备表示特殊召唤。
function c81119816.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡作为「调皮宝贝」怪兽的所用融合素材或者所用连接素材送去墓地的场合才能发动。从卡组把「调皮宝贝·脉冲娃」以外的1张「调皮宝贝」卡送去墓地。那之后，可以从手卡·卡组把「调皮宝贝·脉冲娃」以外的1只「调皮宝贝」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,81119816)
	e1:SetCondition(c81119816.tgcon)
	e1:SetTarget(c81119816.tgtg)
	e1:SetOperation(c81119816.tgop)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否作为「调皮宝贝」怪兽的融合或连接素材送去墓地
function c81119816.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and rc:IsSetCard(0x120) and r&(REASON_FUSION+REASON_LINK)~=0 and not c:IsReason(REASON_RETURN)
end
-- 效果发动的目标检查与操作信息设置
function c81119816.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「调皮宝贝·脉冲娃」以外的「调皮宝贝」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c81119816.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果包含将卡组的卡送去墓地的处理
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤卡组中「调皮宝贝·脉冲娃」以外的「调皮宝贝」卡
function c81119816.tgfilter(c)
	return c:IsSetCard(0x120) and c:IsAbleToGrave() and not c:IsCode(81119816)
end
-- 过滤手卡或卡组中可以守备表示特殊召唤的「调皮宝贝·脉冲娃」以外的「调皮宝贝」怪兽
function c81119816.spfilter(c,e,tp)
	return c:IsSetCard(0x120) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and not c:IsCode(81119816)
end
-- 效果处理，将卡组的1张「调皮宝贝」卡送去墓地，之后可以从手卡或卡组守备表示特殊召唤1只「调皮宝贝」怪兽
function c81119816.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张「调皮宝贝·脉冲娃」以外的「调皮宝贝」卡
	local g=Duel.SelectMatchingCard(tp,c81119816.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 获取手卡和卡组中除刚才选择送去墓地的卡以外、满足特殊召唤条件的「调皮宝贝·脉冲娃」以外的「调皮宝贝」怪兽
	local g2=Duel.GetMatchingGroup(c81119816.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,g:GetFirst(),e,tp)
	-- 将选择的卡送去墓地，并确认其成功送去墓地
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		-- 检查手卡或卡组中是否存在可特殊召唤的怪兽，且己方场上有空余的怪兽区域
		and #g2>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否选择进行特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(81119816,0)) then  --"是否特殊召唤？"
		-- 中断当前效果处理，使后续的特殊召唤处理与送去墓地处理不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g2:Select(tp,1,1,nil)
		-- 将选择的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
