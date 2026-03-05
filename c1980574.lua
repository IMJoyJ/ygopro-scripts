--ホップ・イヤー飛行隊
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，对方主要阶段，以自己场上1只表侧表示怪兽为对象才能发动。这张卡特殊召唤。那之后，只用这张卡和作为对象的怪兽为素材进行同调召唤。
function c1980574.initial_effect(c)
	-- 效果原文内容：这个卡名的效果1回合只能使用1次。
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
-- 效果作用：判断是否为对方主要阶段
function c1980574.syncon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 效果作用：判断是否为对方主要阶段
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 效果原文内容：①：这张卡在手卡存在的场合，对方主要阶段，以自己场上1只表侧表示怪兽为对象才能发动。这张卡特殊召唤。那之后，只用这张卡和作为对象的怪兽为素材进行同调召唤。
function c1980574.synfilter(c,tp,mc)
	local mg=Group.FromCards(c,mc)
	-- 效果作用：判断目标怪兽是否为表侧表示且能进行同调召唤
	return c:IsFaceup() and Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,mg)
end
-- 效果作用：设置效果的发动条件和目标选择
function c1980574.syntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c1980574.synfilter(chkc,tp,c) end
	-- 效果作用：检查玩家是否能特殊召唤2次
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 效果作用：检查玩家场上是否有足够的召唤区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 效果作用：检查是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(c1980574.synfilter,tp,LOCATION_MZONE,0,1,nil,tp,c) end
	-- 效果作用：提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 效果作用：选择满足条件的目标怪兽
	Duel.SelectTarget(tp,c1980574.synfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,c)
	-- 效果作用：设置效果处理时的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,LOCATION_EXTRA)
end
-- 效果作用：处理效果的发动和后续操作
function c1980574.synop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：将此卡特殊召唤到场上
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 效果作用：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() or not tc:IsControler(tp) then return end
	-- 效果作用：刷新场上信息
	Duel.AdjustAll()
	local mg=Group.FromCards(c,tc)
	if mg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 效果作用：获取满足同调召唤条件的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil,mg)
	if g:GetCount()>0 then
		-- 效果作用：提示玩家选择要同调召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 效果作用：进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
