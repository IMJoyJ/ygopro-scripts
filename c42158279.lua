--ドラグマトゥルギー
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己场上的「教导」怪兽或者仪式·融合·同调怪兽解放，从手卡·卡组把1只「教导」仪式怪兽仪式召唤。
-- ②：把墓地的这张卡除外，以等级不同的自己墓地2只「教导」怪兽为对象才能发动。那2只之内的1只加入手卡，另1只回到卡组最下面。
function c42158279.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己场上的「教导」怪兽或者仪式·融合·同调怪兽解放，从手卡·卡组把1只「教导」仪式怪兽仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,42158279)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c42158279.target)
	e1:SetOperation(c42158279.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：把墓地的这张卡除外，以等级不同的自己墓地2只「教导」怪兽为对象才能发动。那2只之内的1只加入手卡，另1只回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,42158279)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	-- 设置②效果的发动代价：把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c42158279.thtg)
	e2:SetOperation(c42158279.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡片是否为「教导」系列（0x145），用于筛选可仪式召唤的「教导」怪兽。
function c42158279.filter(c,e,tp)
	return c:IsSetCard(0x145)
end
-- 过滤函数：判断卡片是否可作为仪式解放素材——位于我方怪兽区，且为「教导」怪兽或仪式·融合·同调怪兽。
function c42158279.matfilter(c)
	return c:IsLocation(LOCATION_MZONE) and (c:IsSetCard(0x145) or c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO))
end
-- ①效果的发动条件判断与操作信息登记：检查是否存在可用素材在手卡·卡组仪式召唤「教导」仪式怪兽，并登记特殊召唤信息。
function c42158279.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家可用的仪式素材组，并筛选出自己场上满足条件的「教导」怪兽或仪式·融合·同调怪兽作为候选素材。
		local mg=Duel.GetRitualMaterial(tp):Filter(c42158279.matfilter,nil)
		-- 检查在手卡·卡组中是否存在1只「教导」仪式怪兽，能够用上述候选素材通过等级合计恰好相等的仪式召唤。
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,c42158279.filter,e,tp,mg,nil,Card.GetLevel,"Equal")
	end
	-- 登记本次连锁处理将进行1只怪兽的特殊召唤（从手卡·卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①效果的实际处理：选择要仪式召唤的「教导」仪式怪兽，从候选素材中选择等级合计相等的解放素材，解放并仪式召唤。
function c42158279.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 效果处理时重新获取并筛选可用仪式素材（自己的「教导」怪兽或仪式·融合·同调怪兽）。
	local mg=Duel.GetRitualMaterial(tp):Filter(c42158279.matfilter,nil)
	-- 提示玩家选择要仪式召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组选择1只满足条件的「教导」仪式怪兽作为仪式召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,c42158279.filter,e,tp,mg,nil,Card.GetLevel,"Equal")
	local tc=g:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的素材。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 为素材选择设置额外检查：保证所选素材的等级合计必须恰好等于仪式召唤怪兽的等级。
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		-- 从候选素材中选出等级合计等于仪式怪兽等级的1组解放素材（执行仪式合法性检查）。
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
		-- 清除之前设置的额外检查。
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 解放选定的仪式素材（墓地中的仪式魔人等卡除外）。
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果处理，使接下来的仪式召唤作为独立处理，避免时点错过。
		Duel.BreakEffect()
		-- 将选择的「教导」仪式怪兽以仪式召唤方式特殊召唤到场上。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 过滤函数：判断墓地中的怪兽是否为「教导」怪兽且当前能成为效果对象，用于②效果取对象。
function c42158279.thfilter(c,e)
	return c:IsSetCard(0x145) and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e)
end
-- 选择子组判定：检查所选2只「教导」怪兽等级互不相同，且存在能够分别回手牌和回卡组的组合。
function c42158279.fselect(g)
	-- 返回是否满足：2只怪兽等级不同，且其中至少1只可加入手卡、另1只可回到卡组。
	return aux.dlvcheck(g) and g:IsExists(c42158279.fcheck,1,nil,g)
end
-- 判断怪兽c能否加入手卡，并且剩余1只怪兽能够回到卡组。
function c42158279.fcheck(c,g)
	return c:IsAbleToHand() and g:IsExists(c42158279.fcheck2,1,c)
end
-- 判断怪兽能否回到卡组。
function c42158279.fcheck2(c)
	return c:IsAbleToDeck()
end
-- ②效果的target函数：从自己墓地选择2只等级不同的「教导」怪兽作为对象，并登记回手牌/回卡组的处理信息。
function c42158279.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地中所有可作为②效果对象的「教导」怪兽。
	local g=Duel.GetMatchingGroup(c42158279.thfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return g:CheckSubGroup(c42158279.fselect,2,2) end
	-- 提示玩家选择②效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,c42158279.fselect,false,2,2)
	-- 将选择的2只怪兽设定为效果对象。
	Duel.SetTargetCard(sg)
	-- 登记操作信息：选择的2只中有1只将被送回手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,tp,LOCATION_GRAVE)
	-- 登记操作信息：选择的2只中有1只将被送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：从对象中选择1只加入手卡，另1只回到卡组最下面；若对象不合法则效果不处理。
function c42158279.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中②效果选择的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g:FilterCount(Card.IsRelateToEffect,nil,e)<2 or not g:IsExists(c42158279.fcheck,1,nil,g) then return end
	-- 提示玩家选择要加入手卡的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local sg=g:FilterSelect(tp,c42158279.fcheck,1,1,nil,g)
	-- 如果加入手卡成功且该卡确实在手卡时，将另一只对象怪兽送回卡组最下面。
	if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 and sg:GetFirst():IsLocation(LOCATION_HAND) then
		-- 将剩余的对象怪兽以效果送回持有者卡组最下面。
		Duel.SendtoDeck(g-sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
