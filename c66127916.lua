--融合準備
-- 效果：
-- ①：把额外卡组1只融合怪兽给对方观看，那只怪兽有卡名记述的1只融合素材怪兽从卡组加入手卡。那之后，可以从自己墓地选1张「融合」加入手卡。
function c66127916.initial_effect(c)
	-- ①：把额外卡组1只融合怪兽给对方观看，那只怪兽有卡名记述的1只融合素材怪兽从卡组加入手卡。那之后，可以从自己墓地选1张「融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c66127916.target)
	e1:SetOperation(c66127916.activate)
	c:RegisterEffect(e1)
end
-- 过滤额外卡组中满足条件的融合怪兽：该怪兽有卡名记述的融合素材怪兽存在于卡组中且能加入手卡
function c66127916.filter1(c,tp)
	-- 检查卡片是否为融合怪兽，且卡组中存在至少1张该融合怪兽记述的、可加入手卡的融合素材怪兽
	return c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(c66127916.filter2,tp,LOCATION_DECK,0,1,nil,c)
end
-- 过滤卡组中满足条件的融合素材怪兽：该怪兽是被指定的融合怪兽所记述的素材，且能加入手卡
function c66127916.filter2(c,fc)
	-- 检查卡片是否为融合怪兽fc上记述了卡名的素材，且该卡片可以加入手卡
	return aux.IsMaterialListCode(fc,c:GetCode()) and c:IsAbleToHand()
end
-- 效果发动的目标过滤与操作信息设置
function c66127916.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以给对方观看的融合怪兽（即该融合怪兽有卡名记述的素材存在于卡组中）
	if chk==0 then return Duel.IsExistingMatchingCard(c66127916.filter1,tp,LOCATION_EXTRA,0,1,nil,tp) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤墓地中名为「融合」且能加入手卡的卡片
function c66127916.filter3(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果处理的执行函数
function c66127916.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从额外卡组选择1只满足条件的融合怪兽
	local cg=Duel.SelectMatchingCard(tp,c66127916.filter1,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	if cg:GetCount()==0 then return end
	-- 将选中的融合怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,cg)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张被确认的融合怪兽所记述的融合素材怪兽
	local g=Duel.SelectMatchingCard(tp,c66127916.filter2,tp,LOCATION_DECK,0,1,1,nil,cg:GetFirst())
	if g:GetCount()>0 then
		-- 将选中的融合素材怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的融合素材怪兽给对方确认
		Duel.ConfirmCards(1-tp,g)
		-- 获取自己墓地中不受「王家长眠之谷」影响的「融合」卡片
		local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c66127916.filter3),tp,LOCATION_GRAVE,0,nil)
		-- 如果墓地存在「融合」且玩家选择将其加入手卡
		if tg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(66127916,0)) then  --"是否把自己墓地1张「融合」加入手卡？"
			-- 中断当前效果，使后续的回收「融合」处理与前面的检索素材处理不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 将选中的「融合」加入手卡
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 将从墓地加入手卡的「融合」给对方确认
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
