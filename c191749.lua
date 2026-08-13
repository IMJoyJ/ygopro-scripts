--ヒーローフラッシュ！！
-- 效果：
-- 把自己墓地的「H-火热之心」「E-紧急呼唤」「R-正义审判」「O-超越灵魂」从游戏中除外发动。从自己卡组特殊召唤1只名字带有「元素英雄」的通常怪兽。这个回合自己场上的名字带有「元素英雄」的通常怪兽可以直接攻击对方玩家。
function c191749.initial_effect(c)
	-- 把自己墓地的「H-火热之心」「E-紧急呼唤」「R-正义审判」「O-超越灵魂」从游戏中除外发动。从自己卡组特殊召唤1只名字带有「元素英雄」的通常怪兽。这个回合自己场上的名字带有「元素英雄」的通常怪兽可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c191749.cost)
	e1:SetTarget(c191749.target)
	e1:SetOperation(c191749.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡片是否为指定的卡号，且可以作为代价从墓地除外。
function c191749.cfilter(c,code)
	return c:IsCode(code) and c:IsAbleToRemoveAsCost()
end
-- 代价检测：确认我方墓地同时存在「H-火热之心」「E-紧急呼唤」「R-正义审判」「O-超越灵魂」各至少1张，且都能作为代价除外。
function c191749.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在1张「H-火热之心」（卡号74825788）且可作为代价除外。
	if chk==0 then return Duel.IsExistingMatchingCard(c191749.cfilter,tp,LOCATION_GRAVE,0,1,nil,74825788)
		-- 检查墓地是否存在1张「E-紧急呼唤」（卡号213326）且可作为代价除外。
		and Duel.IsExistingMatchingCard(c191749.cfilter,tp,LOCATION_GRAVE,0,1,nil,213326)
		-- 检查墓地是否存在1张「R-正义审判」（卡号37318031）且可作为代价除外。
		and Duel.IsExistingMatchingCard(c191749.cfilter,tp,LOCATION_GRAVE,0,1,nil,37318031)
		-- 检查墓地是否存在1张「O-超越灵魂」（卡号63703130）且可作为代价除外。
		and Duel.IsExistingMatchingCard(c191749.cfilter,tp,LOCATION_GRAVE,0,1,nil,63703130) end
	-- 选取墓地中1张「H-火热之心」作为除外代价的对象。
	local tc1=Duel.GetFirstMatchingCard(c191749.cfilter,tp,LOCATION_GRAVE,0,nil,74825788)
	-- 选取墓地中1张「E-紧急呼唤」作为除外代价的对象。
	local tc2=Duel.GetFirstMatchingCard(c191749.cfilter,tp,LOCATION_GRAVE,0,nil,213326)
	-- 选取墓地中1张「R-正义审判」作为除外代价的对象。
	local tc3=Duel.GetFirstMatchingCard(c191749.cfilter,tp,LOCATION_GRAVE,0,nil,37318031)
	-- 选取墓地中1张「O-超越灵魂」作为除外代价的对象。
	local tc4=Duel.GetFirstMatchingCard(c191749.cfilter,tp,LOCATION_GRAVE,0,nil,63703130)
	local g=Group.FromCards(tc1,tc2,tc3,tc4)
	-- 将上述4张卡以表侧表示从墓地除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数：选择卡组中名字带有「元素英雄」的通常怪兽，且满足可被特殊召唤的条件。
function c191749.filter(c,e,tp)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标合法性检测：我方主要怪兽区有空位，且卡组中存在符合条件的「元素英雄」通常怪兽。
function c191749.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认我方主要怪兽区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组中存在至少1只满足条件的「元素英雄」通常怪兽。
		and Duel.IsExistingMatchingCard(c191749.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息为“从卡组特殊召唤1只怪兽”，供相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数：选择我方场上表侧表示的名字带有「元素英雄」的通常怪兽。
function c191749.dfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsSetCard(0x3008)
end
-- 效果处理：从卡组特殊召唤1只「元素英雄」通常怪兽，并使我方场上的「元素英雄」通常怪兽本回合获得直接攻击能力。
function c191749.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若我方主要怪兽区仍有空位，则执行特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家显示“请选择要特殊召唤的卡”的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只满足条件的「元素英雄」通常怪兽。
		local g=Duel.SelectMatchingCard(tp,c191749.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到我方场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 获取我方场上全部表侧表示的「元素英雄」通常怪兽。
	local dg=Duel.GetMatchingGroup(c191749.dfilter,tp,LOCATION_MZONE,0,nil)
	local tc=dg:GetFirst()
	while tc do
		-- 这个回合自己场上的名字带有「元素英雄」的通常怪兽可以直接攻击对方玩家。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=dg:GetNext()
	end
end
