--捕食活動
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡把1只「捕食植物」怪兽特殊召唤。那之后，从卡组把「捕食活动」以外的1张「捕食」卡加入手卡。这张卡的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
function c31643613.initial_effect(c)
	-- ①：从手卡把1只「捕食植物」怪兽特殊召唤。那之后，从卡组把「捕食活动」以外的1张「捕食」卡加入手卡。这张卡的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31643613+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c31643613.sptg)
	e1:SetOperation(c31643613.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选手卡中满足条件的「捕食植物」怪兽
function c31643613.spfilter(c,e,tp)
	return c:IsSetCard(0x10f3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数，用于筛选卡组中满足条件的「捕食」卡
function c31643613.thfilter(c)
	return c:IsSetCard(0xf3) and not c:IsCode(31643613) and c:IsAbleToHand()
end
-- 效果发动时的条件判断，检查是否满足特殊召唤和检索条件
function c31643613.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡中是否存在满足条件的「捕食植物」怪兽
		and Duel.IsExistingMatchingCard(c31643613.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 检查玩家卡组中是否存在满足条件的「捕食」卡
		and Duel.IsExistingMatchingCard(c31643613.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置效果处理时将要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行特殊召唤和检索操作
function c31643613.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的手卡「捕食植物」怪兽
	local g=Duel.SelectMatchingCard(tp,c31643613.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的怪兽特殊召唤到场上
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 中断当前效果处理，使后续效果错开时点
		Duel.BreakEffect()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的卡组「捕食」卡
		local g2=Duel.SelectMatchingCard(tp,c31643613.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g2>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g2)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- ①：从手卡把1只「捕食植物」怪兽特殊召唤。那之后，从卡组把「捕食活动」以外的1张「捕食」卡加入手卡。这张卡的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c31643613.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到全局环境，使效果生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标，禁止非融合怪兽从额外卡组特殊召唤
function c31643613.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
