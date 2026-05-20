--融合派兵
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ①：把额外卡组1只融合怪兽给对方观看，那只怪兽有卡名记述的1只融合素材怪兽从手卡·卡组特殊召唤。
function c6498706.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。①：把额外卡组1只融合怪兽给对方观看，那只怪兽有卡名记述的1只融合素材怪兽从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,6498706+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c6498706.cost)
	e1:SetTarget(c6498706.target)
	e1:SetOperation(c6498706.activate)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于检测玩家在当前回合是否进行过不符合条件的特殊召唤（即从额外卡组特殊召唤了融合怪兽以外的怪兽）。
	Duel.AddCustomActivityCounter(6498706,ACTIVITY_SPSUMMON,c6498706.counterfilter)
end
-- 计数器过滤函数：如果特殊召唤的怪兽不是来自额外卡组，或者是额外卡组的融合怪兽，则不计入限制（返回true表示允许，不增加计数器）。
function c6498706.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end
-- 效果发动的Cost：检查本回合是否未从额外卡组特殊召唤过融合怪兽以外的怪兽，并注册本回合不能从额外卡组特殊召唤融合怪兽以外怪兽的限制。
function c6498706.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检查：本回合玩家是否没有进行过不符合条件的特殊召唤（即计数器为0）。
	if chk==0 then return Duel.GetCustomActivityCount(6498706,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。①：把额外卡组1只融合怪兽给对方观看，那只怪兽有卡名记述的1只融合素材怪兽从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c6498706.splimit)
	-- 将不能从额外卡组特殊召唤融合怪兽以外怪兽的限制效果注册给发动玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制的过滤函数：限制从额外卡组特殊召唤非融合怪兽。
function c6498706.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end
-- 额外卡组融合怪兽的过滤条件：必须是融合怪兽，且其卡名记述的融合素材怪兽中，存在至少1只可以从手卡或卡组特殊召唤的怪兽。
function c6498706.ffilter(c,e,tp)
	-- 检查该卡是否为融合怪兽，且手卡或卡组中是否存在满足特殊召唤条件的该卡记述的素材怪兽。
	return c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(c6498706.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,c,e,tp)
end
-- 融合素材怪兽的过滤条件：该怪兽的卡名必须被融合怪兽fc记述，且该怪兽可以被特殊召唤。
function c6498706.spfilter(c,fc,e,tp)
	-- 检查怪兽卡名是否在融合怪兽的素材列表中，并确认其是否可以被特殊召唤。
	return aux.IsMaterialListCode(fc,c:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的Target：检查怪兽区域是否有空位，以及额外卡组是否存在满足条件的融合怪兽，并设置特殊召唤的操作信息。
function c6498706.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检查：玩家场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查额外卡组中是否存在至少1只满足条件的融合怪兽。
		and Duel.IsExistingMatchingCard(c6498706.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：让玩家从额外卡组选择1只融合怪兽给对方观看，然后从手卡或卡组将1只该融合怪兽记述的素材怪兽特殊召唤。
function c6498706.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时检查：如果此时玩家场上没有可用的怪兽区域空格，则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要给对方确认的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家从额外卡组选择1只满足条件的融合怪兽。
	local tc=Duel.SelectMatchingCard(tp,c6498706.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选中的融合怪兽给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从手卡或卡组选择1只被确认的融合怪兽记述的素材怪兽。
		local g=Duel.SelectMatchingCard(tp,c6498706.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tc,e,tp)
		if g:GetCount()>0 then
			-- 将选中的素材怪兽以表侧表示特殊召唤到玩家场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
