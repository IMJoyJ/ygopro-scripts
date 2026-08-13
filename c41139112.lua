--サモン・ダイス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：支付1000基本分才能发动。掷1次骰子，出现的数目的效果适用。
-- ●1·2：可以把1只怪兽召唤。
-- ●3·4：可以从自己墓地选1只怪兽特殊召唤。
-- ●5·6：可以从手卡把1只5星以上的怪兽特殊召唤。
function c41139112.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：支付1000基本分才能发动。掷1次骰子，出现的数目的效果适用。●1·2：可以把1只怪兽召唤。●3·4：可以从自己墓地选1只怪兽特殊召唤。●5·6：可以从手卡把1只5星以上的怪兽特殊召唤。
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
-- 定义发动代价函数：在效果发动时检查并支付1000基本分作为代价。
function c41139112.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认玩家是否能支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分，完成代价支付。
	Duel.PayLPCost(tp,1000)
end
-- 过滤条件：筛选手牌或场上可以进行通常召唤（忽略通召次数限制）的怪兽。
function c41139112.filter1(c)
	return c:IsSummonable(true,nil)
end
-- 过滤条件：筛选墓地中满足特殊召唤条件（含召唤手续/苏生限制）的怪兽。
function c41139112.filter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤条件：筛选手牌中等级5以上且满足特殊召唤条件的怪兽。
function c41139112.filter3(c,e,tp)
	return c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- （代码中定义了但未实际调用的）发动条件判定：判断是否存在可通常召唤/墓地可特召/手牌5星以上可特召的对象。
function c41139112.filter(c,e,tp)
	-- 检查手牌或场上是否存在至少1只可进行通常召唤的怪兽。
	return Duel.IsExistingMatchingCard(c41139112.filter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		-- 检查墓地是否存在至少1只可被特殊召唤的怪兽。
		or Duel.IsExistingMatchingCard(c41139112.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查手牌是否存在至少1只5星以上可被特殊召唤的怪兽。
		or Duel.IsExistingMatchingCard(c41139112.filter3,tp,LOCATION_HAND,0,1,nil,e,tp)
end
-- 发动时的目标处理：检查阶段直接允许发动，并登记掷骰子的操作信息。
function c41139112.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果将进行掷1次骰子，供骰子相关卡片检测。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果处理：掷骰子，根据点数1/2、3/4、5/6分别执行对应的通常召唤、墓地特殊召唤、手牌特殊召唤效果。
function c41139112.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 玩家掷1次骰子，点数存入变量d。
	local d=Duel.TossDice(tp,1)
	if d==1 or d==2 then
		-- 获取手牌或场上所有满足可通常召唤条件的怪兽集合。
		local g=Duel.GetMatchingGroup(c41139112.filter1,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		-- 若存在可通常召唤的怪兽且玩家选择发动“把1只怪兽召唤”的效果，则继续处理。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(41139112,0)) then  --"是否召唤？"
			-- 给玩家显示选择召唤怪兽的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			local tc=g:Select(tp,1,1,nil):GetFirst()
			-- 将选择的怪兽进行通常召唤，并不占用本回合的通常召唤次数。
			Duel.Summon(tp,tc,true,nil)
		end
	elseif d==3 or d==4 then
		-- 获取墓地中满足可特殊召唤条件且不受王家长眠之谷影响的怪兽集合。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c41139112.filter2),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 若己方主要怪兽区有空位、墓地有可特殊召唤的怪兽且玩家确认发动，则继续处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(41139112,1)) then  --"是否从墓地特殊召唤？"
			-- 给玩家显示选择要特殊召唤的怪兽的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=g:Select(tp,1,1,nil):GetFirst()
			-- 将选择的怪兽以表侧表示特殊召唤到己方场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif d==7 then
		return
	else
		-- 获取手牌中所有5星以上且可被当前效果特殊召唤的怪兽集合。
		local g=Duel.GetMatchingGroup(c41139112.filter3,tp,LOCATION_HAND,0,nil,e,tp)
		-- 若己方主要怪兽区有空位、手牌有满足条件的怪兽且玩家确认发动，则继续处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(41139112,2)) then  --"是否从手卡特殊召唤？"
			-- 给玩家显示选择要特殊召唤的怪兽的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=g:Select(tp,1,1,nil):GetFirst()
			-- 将选择的怪兽以表侧表示特殊召唤到己方场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
