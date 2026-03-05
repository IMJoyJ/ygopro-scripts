--コンタクト
-- 效果：
-- 把自己场上名字带有「茧状体」的怪兽全部送去墓地，那些卡记述的1只怪兽从手卡·卡组特殊召唤。
function c16616620.initial_effect(c)
	-- 卡片效果初始化，设置为发动时点，可以自由连锁，目标函数为c16616620.target，处理函数为c16616620.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c16616620.target)
	e1:SetOperation(c16616620.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否存在表侧表示且名字带有「茧状体」的怪兽，并且该怪兽所记述的怪兽存在于手卡或卡组中
function c16616620.filter1(c,e,tp)
	-- 当前怪兽为表侧表示且名字带有「茧状体」，并且在手卡或卡组中存在其记述的怪兽
	return c:IsFaceup() and c:IsSetCard(0x1e) and Duel.IsExistingMatchingCard(c16616620.filter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,c,e,tp)
end
-- 过滤函数，用于判断手卡或卡组中是否存在名字带有「茧状体」且被当前怪兽记述的怪兽
function c16616620.filter2(c,mc,e,tp)
	-- 当前怪兽名字带有「茧状体」，并且被指定怪兽记述，且可以被特殊召唤
	return c:IsSetCard(0x1f) and aux.IsCodeListed(mc,c:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 目标函数，检查是否满足发动条件，即场上有名字带有「茧状体」的怪兽，且有满足条件的怪兽可特殊召唤
function c16616620.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查场上是否存在名字带有「茧状体」的怪兽
		and Duel.IsExistingMatchingCard(c16616620.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只怪兽，目标位置为手卡或卡组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 过滤函数，用于判断场上是否存在表侧表示且名字带有「茧状体」的怪兽
function c16616620.filter3(c)
	return c:IsFaceup() and c:IsSetCard(0x1e)
end
-- 处理函数，将场上名字带有「茧状体」的怪兽送去墓地，然后检索其记述的怪兽并特殊召唤
function c16616620.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有名字带有「茧状体」的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c16616620.filter3,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()==0 then return end
	-- 将这些怪兽送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
	local sg=Group.CreateGroup()
	local tc=g:GetFirst()
	while tc do
		-- 获取当前怪兽所记述的怪兽（存在于手卡或卡组）
		local tg=Duel.GetMatchingGroup(c16616620.filter2,tp,LOCATION_HAND+LOCATION_DECK,0,nil,tc,e,tp)
		sg:Merge(tg)
		tc=g:GetNext()
	end
	if sg:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local spg=sg:Select(tp,1,1,nil)
		-- 将选择的怪兽特殊召唤到场上
		Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
	end
end
