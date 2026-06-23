--サモン・ダイス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：支付1000基本分才能发动。掷1次骰子，出现的数目的效果适用。
-- ●1·2：可以把1只怪兽召唤。
-- ●3·4：可以从自己墓地选1只怪兽特殊召唤。
-- ●5·6：可以从手卡把1只5星以上的怪兽特殊召唤。
function c41139112.initial_effect(c)
	-- ①：支付1000基本分才能发动。掷1次骰子，出现的数目的效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,41139112+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c41139112.cost)
	e1:SetTarget(c41139112.target)
	e1:SetOperation(c41139112.activate)
	c:RegisterEffect(e1)
end
-- 支付1000基本分
function c41139112.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数，检查玩家手卡或场上是否有可通常召唤的怪兽
function c41139112.filter1(c)
	return c:IsSummonable(true,nil)
end
-- 过滤函数，检查玩家墓地是否有可特殊召唤的怪兽
function c41139112.filter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数，检查玩家手卡是否有5星以上的可特殊召唤的怪兽
function c41139112.filter3(c,e,tp)
	return c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 综合过滤函数，检查玩家是否满足任意一种骰子效果的发动条件
function c41139112.filter(c,e,tp)
	-- 检查玩家手卡或场上是否有可通常召唤的怪兽
	return Duel.IsExistingMatchingCard(c41139112.filter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		-- 检查玩家墓地是否有可特殊召唤的怪兽
		or Duel.IsExistingMatchingCard(c41139112.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查玩家手卡是否有5星以上的可特殊召唤的怪兽
		or Duel.IsExistingMatchingCard(c41139112.filter3,tp,LOCATION_HAND,0,1,nil,e,tp)
end
-- 设置效果发动时的连锁操作信息，包括骰子效果
function c41139112.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息为投掷骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果发动时的处理函数，根据骰子结果执行对应效果
function c41139112.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家投掷1次骰子
	local d=Duel.TossDice(tp,1)
	if d==1 or d==2 then
		-- 获取玩家手卡或场上的可通常召唤怪兽组
		local g=Duel.GetMatchingGroup(c41139112.filter1,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		-- 判断是否有可通常召唤的怪兽并询问玩家是否发动
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(41139112,0)) then  --"是否召唤？"
			-- 提示玩家选择要通常召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			local tc=g:Select(tp,1,1,nil):GetFirst()
			-- 执行通常召唤操作
			Duel.Summon(tp,tc,true,nil)
		end
	elseif d==3 or d==4 then
		-- 获取玩家墓地的可特殊召唤怪兽组（受王家长眠之谷影响）
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c41139112.filter2),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 判断是否有可从墓地特殊召唤的怪兽并询问玩家是否发动
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(41139112,1)) then  --"是否从墓地特殊召唤？"
			-- 提示玩家选择要从墓地特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=g:Select(tp,1,1,nil):GetFirst()
			-- 执行从墓地特殊召唤操作
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif d==7 then
		return
	else
		-- 获取玩家手卡中5星以上的可特殊召唤怪兽组
		local g=Duel.GetMatchingGroup(c41139112.filter3,tp,LOCATION_HAND,0,nil,e,tp)
		-- 判断是否有可从手卡特殊召唤的怪兽并询问玩家是否发动
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(41139112,2)) then  --"是否从手卡特殊召唤？"
			-- 提示玩家选择要从手卡特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=g:Select(tp,1,1,nil):GetFirst()
			-- 执行从手卡特殊召唤操作
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
