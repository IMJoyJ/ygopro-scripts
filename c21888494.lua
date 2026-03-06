--選ばれし者
-- 效果：
-- 选1张自己的手卡的怪兽卡和怪兽以外的种类2张卡。对方在这之中随机选1张，如果选中怪兽卡的场合场上特殊召唤，其他的2张卡送去墓地。选不中的话，全部送去墓地。
function c21888494.initial_effect(c)
	-- 效果原文内容：选1张自己的手卡的怪兽卡和怪兽以外的种类2张卡。对方在这之中随机选1张，如果选中怪兽卡的场合场上特殊召唤，其他的2张卡送去墓地。选不中的话，全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c21888494.target)
	e1:SetOperation(c21888494.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的怪兽卡，用于特殊召唤
function c21888494.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：判断是否满足发动条件
function c21888494.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断玩家手牌中是否存在至少2张魔法或陷阱卡
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND,0,2,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
		-- 效果作用：判断玩家手牌中是否存在至少1张可以特殊召唤的怪兽卡
		and Duel.IsExistingMatchingCard(c21888494.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
end
-- 效果作用：执行卡片效果的主要处理流程
function c21888494.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：检索玩家手牌中所有可以特殊召唤的怪兽卡
	local g1=Duel.GetMatchingGroup(c21888494.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 效果作用：检索玩家手牌中所有魔法或陷阱卡
	local g2=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND,0,nil,TYPE_SPELL+TYPE_TRAP)
	if g1:GetCount()==0 or g2:GetCount()<2 then return end
	-- 效果作用：提示玩家选择一张怪兽卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(21888494,0))  --"请选择一张怪兽卡"
	local sg1=g1:Select(tp,1,1,nil)
	local sc=sg1:GetFirst()
	-- 效果作用：提示玩家选择两张怪兽卡以外的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(21888494,1))  --"请选择怪兽卡以外的两张卡"
	local sg2=g2:Select(tp,2,2,nil)
	sg1:Merge(sg2)
	-- 效果作用：向对方玩家确认所选的卡
	Duel.ConfirmCards(1-tp,sg1)
	-- 效果作用：洗切玩家手牌
	Duel.ShuffleHand(tp)
	local rg=sg1:Select(1-tp,1,1,nil)
	local tc=rg:GetFirst()
	if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 效果作用：将选中的怪兽卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 效果作用：将选中的两张非怪兽卡送去墓地
		Duel.SendtoGrave(sg2,REASON_EFFECT)
	else
		-- 效果作用：将所有选中的卡送去墓地
		Duel.SendtoGrave(sg1,REASON_EFFECT)
	end
end
