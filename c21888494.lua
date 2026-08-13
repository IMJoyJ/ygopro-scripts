--選ばれし者
-- 效果：
-- 选1张自己的手卡的怪兽卡和怪兽以外的种类2张卡。对方在这之中随机选1张，如果选中怪兽卡的场合场上特殊召唤，其他的2张卡送去墓地。选不中的话，全部送去墓地。
function c21888494.initial_effect(c)
	-- 选1张自己的手卡的怪兽卡和怪兽以外的种类2张卡。对方在这之中随机选1张，如果选中怪兽卡的场合场上特殊召唤，其他的2张卡送去墓地。选不中的话，全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c21888494.target)
	e1:SetOperation(c21888494.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，返回手牌中可被该效果特殊召唤的怪兽卡。
function c21888494.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件判定：确认满足发动所需的所有条件（有怪兽区空位、手牌有2张魔法/陷阱卡、有1张可特殊召唤的怪兽卡）。
function c21888494.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有可用的怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少2张魔法/陷阱卡（怪兽以外的种类），并排除效果持有者自身。
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND,0,2,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
		-- 检查手牌中是否存在至少1张可被该效果特殊召唤的怪兽卡。
		and Duel.IsExistingMatchingCard(c21888494.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
end
-- 效果处理时执行：选择1张怪兽卡和2张非怪兽卡，让对方从中选择1张；若选中怪兽则将其特殊召唤、其余2张送墓，若未选中怪兽则3张全部送墓。
function c21888494.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方怪兽区没有空位，则效果处理终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得手牌中所有满足特殊召唤条件的怪兽卡集合。
	local g1=Duel.GetMatchingGroup(c21888494.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 取得手牌中所有魔法/陷阱卡（怪兽以外的卡）的集合。
	local g2=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND,0,nil,TYPE_SPELL+TYPE_TRAP)
	if g1:GetCount()==0 or g2:GetCount()<2 then return end
	-- 向操作玩家显示“请选择一张怪兽卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(21888494,0))  --"请选择一张怪兽卡"
	local sg1=g1:Select(tp,1,1,nil)
	local sc=sg1:GetFirst()
	-- 向操作玩家显示“请选择怪兽卡以外的两张卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(21888494,1))  --"请选择怪兽卡以外的两张卡"
	local sg2=g2:Select(tp,2,2,nil)
	sg1:Merge(sg2)
	-- 将我方选择的3张卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,sg1)
	-- 洗切我方手牌，避免对方通过手牌位置获取额外信息。
	Duel.ShuffleHand(tp)
	local rg=sg1:Select(1-tp,1,1,nil)
	local tc=rg:GetFirst()
	if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 将选中的怪兽卡以表侧表示特殊召唤到我方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 当对方选中怪兽卡时，将剩下的两张非怪兽卡送去墓地。
		Duel.SendtoGrave(sg2,REASON_EFFECT)
	else
		-- 当对方未选中怪兽卡时，将全部三张卡送去墓地。
		Duel.SendtoGrave(sg1,REASON_EFFECT)
	end
end
