--コクーン・パーティ
-- 效果：
-- 自己墓地存在的名字带有「新空间侠」的怪兽每有1种类，把1只名字带有「茧状体」的怪兽从自己卡组特殊召唤。
function c80368942.initial_effect(c)
	-- 自己墓地存在的名字带有「新空间侠」的怪兽每有1种类，把1只名字带有「茧状体」的怪兽从自己卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c80368942.target)
	e1:SetOperation(c80368942.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中名字带有「新空间侠」的怪兽卡
function c80368942.gfilter(c)
	return c:IsSetCard(0x1f) and c:IsType(TYPE_MONSTER)
end
-- 过滤卡组中名字带有「茧状体」且可以特殊召唤的怪兽卡
function c80368942.spfilter(c,e,tp)
	return c:IsSetCard(0x1e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性检测与操作信息设置（检查墓地「新空间侠」种类数、怪兽区域空位数、卡组中「茧状体」怪兽数量，并设置特殊召唤的操作信息）
function c80368942.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己墓地中所有名字带有「新空间侠」的怪兽
		local g=Duel.GetMatchingGroup(c80368942.gfilter,tp,LOCATION_GRAVE,0,nil)
		local ct=c80368942.count_unique_code(g)
		e:SetLabel(ct)
		-- 检查墓地「新空间侠」的种类数是否大于0，且自己场上的怪兽区域空位数是否足够容纳对应数量的怪兽
		return ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
			-- 检查卡组中是否存在至少对应数量（种类数）的、可以特殊召唤的名字带有「茧状体」的怪兽
			and Duel.IsExistingMatchingCard(c80368942.spfilter,tp,LOCATION_DECK,0,ct,nil,e,tp)
	end
	-- 设置特殊召唤的操作信息，指定从卡组特殊召唤对应数量的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,e:GetLabel(),tp,LOCATION_DECK)
end
-- 效果处理的执行函数（计算墓地「新空间侠」种类数，从卡组选择并特殊召唤对应数量的名字带有「茧状体」的怪兽）
function c80368942.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，重新获取自己墓地中所有名字带有「新空间侠」的怪兽
	local g=Duel.GetMatchingGroup(c80368942.gfilter,tp,LOCATION_GRAVE,0,nil)
	local ct=c80368942.count_unique_code(g)
	-- 如果种类数为0，或者怪兽区域空位数不足，则不进行处理
	if ct==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<ct then return end
	-- 获取卡组中所有可以特殊召唤的名字带有「茧状体」的怪兽
	local sg=Duel.GetMatchingGroup(c80368942.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if sg:GetCount()<ct then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local spg=sg:Select(tp,ct,ct,nil)
	-- 将选中的「茧状体」怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
end
-- 辅助函数：计算传入的卡片组中不同卡名（卡片密码）的种类数量
function c80368942.count_unique_code(g)
	local check={}
	local count=0
	local tc=g:GetFirst()
	while tc do
		for i,code in ipairs({tc:GetCode()}) do
			if not check[code] then
				check[code]=true
				count=count+1
			end
		end
		tc=g:GetNext()
	end
	return count
end
