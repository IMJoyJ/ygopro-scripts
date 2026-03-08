--ドラグマトゥルギー
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己场上的「教导」怪兽或者仪式·融合·同调怪兽解放，从手卡·卡组把1只「教导」仪式怪兽仪式召唤。
-- ②：把墓地的这张卡除外，以等级不同的自己墓地2只「教导」怪兽为对象才能发动。那2只之内的1只加入手卡，另1只回到卡组最下面。
function c42158279.initial_effect(c)
	-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己场上的「教导」怪兽或者仪式·融合·同调怪兽解放，从手卡·卡组把1只「教导」仪式怪兽仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,42158279)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c42158279.target)
	e1:SetOperation(c42158279.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以等级不同的自己墓地2只「教导」怪兽为对象才能发动。那2只之内的1只加入手卡，另1只回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,42158279)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c42158279.thtg)
	e2:SetOperation(c42158279.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选「教导」卡
function c42158279.filter(c,e,tp)
	return c:IsSetCard(0x145)
end
-- 过滤函数，用于筛选可用于仪式召唤的素材
function c42158279.matfilter(c)
	return c:IsLocation(LOCATION_MZONE) and (c:IsSetCard(0x145) or c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO))
end
-- 检查是否满足仪式召唤条件
function c42158279.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取可用于仪式召唤的素材组
		local mg=Duel.GetRitualMaterial(tp):Filter(c42158279.matfilter,nil)
		-- 检查是否存在满足条件的仪式怪兽
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,c42158279.filter,e,tp,mg,nil,Card.GetLevel,"Equal")
	end
	-- 设置效果处理信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 处理仪式召唤效果
function c42158279.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取可用于仪式召唤的素材组
	local mg=Duel.GetRitualMaterial(tp):Filter(c42158279.matfilter,nil)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,c42158279.filter,e,tp,mg,nil,Card.GetLevel,"Equal")
	local tc=g:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置额外的仪式召唤检查条件
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		-- 选择满足条件的仪式召唤素材组
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
		-- 清除额外的仪式召唤检查条件
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 解放仪式召唤素材
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 将仪式怪兽特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 过滤函数，用于筛选墓地中的「教导」怪兽
function c42158279.thfilter(c,e)
	return c:IsSetCard(0x145) and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e)
end
-- 筛选函数，用于检查是否满足效果条件
function c42158279.fselect(g)
	-- 检查是否满足效果条件
	return aux.dlvcheck(g) and g:IsExists(c42158279.fcheck,1,nil,g)
end
-- 检查单张卡是否可以加入手牌
function c42158279.fcheck(c,g)
	return c:IsAbleToHand() and g:IsExists(c42158279.fcheck2,1,c)
end
-- 检查单张卡是否可以回到卡组
function c42158279.fcheck2(c)
	return c:IsAbleToDeck()
end
-- 设置效果处理信息，表示将处理2只怪兽
function c42158279.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取墓地中的「教导」怪兽组
	local g=Duel.GetMatchingGroup(c42158279.thfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return g:CheckSubGroup(c42158279.fselect,2,2) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,c42158279.fselect,false,2,2)
	-- 设置效果处理对象
	Duel.SetTargetCard(sg)
	-- 设置效果处理信息，表示将加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,tp,LOCATION_GRAVE)
	-- 设置效果处理信息，表示将回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,1,tp,LOCATION_GRAVE)
end
-- 处理墓地效果
function c42158279.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果处理对象
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g:FilterCount(Card.IsRelateToEffect,nil,e)<2 or not g:IsExists(c42158279.fcheck,1,nil,g) then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local sg=g:FilterSelect(tp,c42158279.fcheck,1,1,nil,g)
	-- 将选中的卡加入手牌
	if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 and sg:GetFirst():IsLocation(LOCATION_HAND) then
		-- 将剩余的卡回到卡组底部
		Duel.SendtoDeck(g-sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
