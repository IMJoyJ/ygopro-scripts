--ホップ・イヤー飛行隊
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，对方主要阶段，以自己场上1只表侧表示怪兽为对象才能发动。这张卡特殊召唤。那之后，只用这张卡和作为对象的怪兽为素材进行同调召唤。
function c1980574.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡存在的场合，对方主要阶段，以自己场上1只表侧表示怪兽为对象才能发动。这张卡特殊召唤。那之后，只用这张卡和作为对象的怪兽为素材进行同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1980574,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,1980574)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(c1980574.syncon)
	e1:SetTarget(c1980574.syntg)
	e1:SetOperation(c1980574.synop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：仅在对方回合的主要阶段（主要阶段1或主要阶段2）才能发动。
function c1980574.syncon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判定当前是否为对方回合的主要阶段，满足则发动。
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 定义对象选择过滤条件：作为对象的怪兽须表侧表示，且额外卡组存在能用该对象与本卡为素材进行同调召唤的怪兽。
function c1980574.synfilter(c,tp,mc)
	local mg=Group.FromCards(c,mc)
	-- 判定对象怪兽是否表侧表示，以及额外卡组是否能用该对象与本卡作为素材进行同调召唤。
	return c:IsFaceup() and Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,mg)
end
-- 效果发动时的目标处理：检查能否特殊召唤本卡并选择对象怪兽。
function c1980574.syntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c1980574.synfilter(chkc,tp,c) end
	-- 检查玩家是否可以再进行2次特殊召唤（一次特殊召唤本卡，一次同调召唤）。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查我方的主要怪兽区域是否有空位，用于特殊召唤本卡。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查场上是否存在满足条件的表侧表示怪兽可以作为对象。
		and Duel.IsExistingTarget(c1980574.synfilter,tp,LOCATION_MZONE,0,1,nil,tp,c) end
	-- 给玩家显示“请选择表侧表示的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只表侧表示怪兽作为效果对象（并设定为连锁对象）。
	Duel.SelectTarget(tp,c1980574.synfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,c)
	-- 设置操作信息：声明本效果将进行特殊召唤（本卡及后续同调怪兽），其中本卡作为确定要特殊召唤的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,LOCATION_EXTRA)
end
-- 效果处理：特殊召唤本卡，然后以本卡和对象怪兽为素材进行同调召唤。
function c1980574.synop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果本卡已不与该效果关联，或本卡特殊召唤失败，则结束处理。
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 取得效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() or not tc:IsControler(tp) then return end
	-- 刷新游戏状态，确保同调召唤条件判定基于最新场地信息。
	Duel.AdjustAll()
	local mg=Group.FromCards(c,tc)
	if mg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 检索额外卡组中所有能用本卡与对象怪兽作为素材进行同调召唤的同调怪兽。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil,mg)
	if g:GetCount()>0 then
		-- 给玩家显示“请选择要特殊召唤的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以本卡和对象怪兽为素材，对选择的同调怪兽进行同调召唤。
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
