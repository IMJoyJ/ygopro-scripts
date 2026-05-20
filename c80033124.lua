--サイバーダーク・インパクト！
-- 效果：
-- ①：从自己的手卡·场上·墓地让「电子暗黑魔角」「电子暗黑刃翼」「电子暗黑龙骨」各1张回到持有者卡组，把1只「铠黑龙-电子暗黑龙」从额外卡组融合召唤。
function c80033124.initial_effect(c)
	-- 注册卡片效果中记载了「电子暗黑魔角」、「电子暗黑刃翼」、「电子暗黑龙骨」的卡片密码
	aux.AddCodeList(c,41230939,77625948,3019642)
	-- ①：从自己的手卡·场上·墓地让「电子暗黑魔角」「电子暗黑刃翼」「电子暗黑龙骨」各1张回到持有者卡组，把1只「铠黑龙-电子暗黑龙」从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c80033124.target)
	e1:SetOperation(c80033124.activate)
	c:RegisterEffect(e1)
end
-- 创建用于检查融合素材是否包含「电子暗黑魔角」、「电子暗黑刃翼」、「电子暗黑龙骨」各1张的条件检查函数数组
c80033124.fchecks=aux.CreateChecks(Card.IsFusionCode,{41230939,77625948,3019642})
-- 过滤函数：判断卡片是否为「电子暗黑魔角」、「电子暗黑刃翼」或「电子暗黑龙骨」之一，且可以作为融合素材并能回到卡组
function c80033124.ffilter0(c)
	return c:IsFusionCode(41230939,77625948,3019642) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
-- 过滤函数：在ffilter0的基础上，增加不受当前效果影响的免疫检测（用于效果处理时过滤）
function c80033124.ffilter(c,e)
	return c:IsFusionCode(41230939,77625948,3019642) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
		and not c:IsImmuneToEffect(e)
end
-- 过滤函数：判断卡片是否为「铠黑龙-电子暗黑龙」，且能以融合召唤的方式特殊召唤，并检查额外卡组特殊召唤的区域空格
function c80033124.spfilter(c,e,tp,sg)
	return c:IsCode(40418351) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		-- 检查在将选定的融合素材送回卡组后，是否仍有足够的额外卡组怪兽出场区域
		and (not sg or Duel.GetLocationCountFromEx(tp,tp,sg,c)>0)
end
-- 目标达成条件函数：判断是否存在可以从额外卡组融合召唤的「铠黑龙-电子暗黑龙」
function c80033124.fgoal(g,e,tp)
	-- 检查额外卡组是否存在至少1只满足特殊召唤条件的「铠黑龙-电子暗黑龙」（传入已选素材组进行区域检查）
	return Duel.IsExistingMatchingCard(c80033124.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
end
-- 效果发动时的合法性检测与目标确认（Target）
function c80033124.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查是否存在必须作为融合素材的卡片限制
		if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return false end
		-- 检查额外卡组是否存在可以特殊召唤的「铠黑龙-电子暗黑龙」
		if not Duel.IsExistingMatchingCard(c80033124.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil) then return false end
		-- 获取自己手卡、场上、墓地中所有可作为素材且能回到卡组的「电子暗黑魔角」、「电子暗黑刃翼」、「电子暗黑龙骨」
		local mg=Duel.GetMatchingGroup(c80033124.ffilter0,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
		return mg:CheckSubGroupEach(c80033124.fchecks,c80033124.fgoal,e,tp)
	end
	-- 设置当前连锁的操作信息为：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤函数：判断卡片是否在手卡，或者在场上且为里侧表示（用于后续向对方确认卡片）
function c80033124.cfilter(c)
	return c:IsLocation(LOCATION_HAND) or (c:IsOnField() and c:IsFacedown())
end
-- 过滤函数：判断卡片是否在墓地，或者在场上且为表侧表示（用于后续在场上展示选择动画）
function c80033124.cfilter2(c)
	return c:IsLocation(LOCATION_GRAVE) or (c:IsOnField() and c:IsFaceup())
end
-- 效果处理（Activate）的核心逻辑
function c80033124.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次检查是否存在必须作为融合素材的卡片限制
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 获取自己手卡、场上、墓地中满足素材条件且不受「王家之谷」影响的卡片组
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c80033124.ffilter),tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,e)
	-- 给玩家发送提示信息：“请选择要返回卡组的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=mg:SelectSubGroupEach(tp,c80033124.fchecks,false,c80033124.fgoal,e,tp)
	if not sg then return end
	local cg=sg:Filter(c80033124.cfilter,nil)
	if cg:GetCount()>0 then
		-- 给对方玩家确认选定的手卡或场上里侧表示的素材卡片
		Duel.ConfirmCards(1-tp,cg)
		-- 洗切自己手卡（重置手卡洗牌检测状态）
		Duel.ShuffleHand(tp)
	end
	local cg2=sg:Filter(c80033124.cfilter2,nil)
	if cg2:GetCount()>0 then
		-- 选中并闪烁显示场上表侧表示或墓地中的素材卡片
		Duel.HintSelection(cg2)
	end
	-- 将选定的素材卡片送回持有者卡组并洗牌
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 给玩家发送提示信息：“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足特殊召唤条件的「铠黑龙-电子暗黑龙」
	local g=Duel.SelectMatchingCard(tp,c80033124.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	-- 将选定的怪兽以融合召唤的方式表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(g,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	g:GetFirst():CompleteProcedure()
end
