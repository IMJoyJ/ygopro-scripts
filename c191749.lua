--ヒーローフラッシュ！！
-- 效果：
-- 把自己墓地的「H-火热之心」「E-紧急呼唤」「R-正义审判」「O-超越灵魂」从游戏中除外发动。从自己卡组特殊召唤1只名字带有「元素英雄」的通常怪兽。这个回合自己场上的名字带有「元素英雄」的通常怪兽可以直接攻击对方玩家。
function c191749.initial_effect(c)
	-- 效果：把自己墓地的「H-火热之心」「E-紧急呼唤」「R-正义审判」「O-超越灵魂」从游戏中除外发动。从自己卡组特殊召唤1只名字带有「元素英雄」的通常怪兽。这个回合自己场上的名字带有「元素英雄」的通常怪兽可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c191749.cost)
	e1:SetTarget(c191749.target)
	e1:SetOperation(c191749.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查卡是否为指定code且可作为费用除外
function c191749.cfilter(c,code)
	return c:IsCode(code) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时的费用处理，检查是否满足除外四张指定卡片的条件
function c191749.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在「H-火热之心」且可作为费用除外
	if chk==0 then return Duel.IsExistingMatchingCard(c191749.cfilter,tp,LOCATION_GRAVE,0,1,nil,74825788)
		-- 检查自己墓地是否存在「E-紧急呼唤」且可作为费用除外
		and Duel.IsExistingMatchingCard(c191749.cfilter,tp,LOCATION_GRAVE,0,1,nil,213326)
		-- 检查自己墓地是否存在「R-正义审判」且可作为费用除外
		and Duel.IsExistingMatchingCard(c191749.cfilter,tp,LOCATION_GRAVE,0,1,nil,37318031)
		-- 检查自己墓地是否存在「O-超越灵魂」且可作为费用除外
		and Duel.IsExistingMatchingCard(c191749.cfilter,tp,LOCATION_GRAVE,0,1,nil,63703130) end
	-- 获取自己墓地第一张「H-火热之心」
	local tc1=Duel.GetFirstMatchingCard(c191749.cfilter,tp,LOCATION_GRAVE,0,nil,74825788)
	-- 获取自己墓地第一张「E-紧急呼唤」
	local tc2=Duel.GetFirstMatchingCard(c191749.cfilter,tp,LOCATION_GRAVE,0,nil,213326)
	-- 获取自己墓地第一张「R-正义审判」
	local tc3=Duel.GetFirstMatchingCard(c191749.cfilter,tp,LOCATION_GRAVE,0,nil,37318031)
	-- 获取自己墓地第一张「O-超越灵魂」
	local tc4=Duel.GetFirstMatchingCard(c191749.cfilter,tp,LOCATION_GRAVE,0,nil,63703130)
	local g=Group.FromCards(tc1,tc2,tc3,tc4)
	-- 将上述四张卡从游戏中除外作为发动费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，检查卡是否为「元素英雄」通常怪兽且可特殊召唤
function c191749.filter(c,e,tp)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理目标，检查自己卡组是否存在满足条件的怪兽
function c191749.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c191749.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理信息，表示将特殊召唤1只名字带有「元素英雄」的通常怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，检查场上正面表示的「元素英雄」通常怪兽
function c191749.dfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsSetCard(0x3008)
end
-- 效果发动时的处理流程，特殊召唤卡组中的怪兽并赋予其直接攻击效果
function c191749.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己卡组选择1只满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c191749.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 获取自己场上所有正面表示的「元素英雄」通常怪兽
	local dg=Duel.GetMatchingGroup(c191749.dfilter,tp,LOCATION_MZONE,0,nil)
	local tc=dg:GetFirst()
	while tc do
		-- 为场上符合条件的怪兽设置直接攻击效果，该效果在结束阶段重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=dg:GetNext()
	end
end
