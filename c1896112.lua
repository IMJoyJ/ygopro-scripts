--次元誘爆
-- 效果：
-- 把自己场上表侧表示存在的1只融合怪兽回到融合卡组才能发动。双方选择从游戏中除外的怪兽最多2只，在各自场上特殊召唤。
function c1896112.initial_effect(c)
	-- 效果原文内容：把自己场上表侧表示存在的1只融合怪兽回到融合卡组才能发动。双方选择从游戏中除外的怪兽最多2只，在各自场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c1896112.cost)
	e1:SetTarget(c1896112.target)
	e1:SetOperation(c1896112.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查场上是否存在满足条件的融合怪兽作为发动代价
function c1896112.cfilter(c,ft)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsAbleToExtraAsCost() and (ft>0 or c:GetSequence()<5)
end
-- 发动时的处理函数，检查是否满足发动条件并选择1只融合怪兽送回卡组作为代价
function c1896112.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 判断是否满足发动条件，即场上至少有1个可用区域且存在满足条件的融合怪兽
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c1896112.cfilter,tp,LOCATION_MZONE,0,1,nil,ft) end
	-- 提示玩家选择要送回卡组的融合怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的融合怪兽作为发动代价
	local g=Duel.SelectMatchingCard(tp,c1896112.cfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 将选中的融合怪兽送回融合卡组作为发动代价
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)
end
-- 过滤函数，用于检查除外区的怪兽是否可以被特殊召唤
function c1896112.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的目标选择函数，检查双方是否可以各自选择除外区的怪兽进行特殊召唤
function c1896112.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否有可用区域
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查己方是否可以从除外区选择怪兽进行特殊召唤
		and Duel.IsExistingTarget(c1896112.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
		-- 检查对方是否可以从除外区选择怪兽进行特殊召唤
		and Duel.IsExistingTarget(c1896112.filter,1-tp,LOCATION_REMOVED,0,1,nil,e,1-tp) end
	-- 获取当前玩家场上可用的怪兽区域数量
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft1=1 end
	if ft1>2 then ft1=2 end
	-- 提示己方选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择己方要特殊召唤的怪兽
	local g1=Duel.SelectTarget(tp,c1896112.filter,tp,LOCATION_REMOVED,0,1,ft1,nil,e,tp)
	-- 获取对方玩家场上可用的怪兽区域数量
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if ft2>2 then ft2=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(1-tp,59822133) then ft2=1 end
	-- 提示对方选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方要特殊召唤的怪兽
	local g2=Duel.SelectTarget(1-tp,c1896112.filter,1-tp,LOCATION_REMOVED,0,1,ft2,nil,e,1-tp)
	g1:Merge(g2)
	-- 设置连锁操作信息，记录本次效果将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,g1:GetCount(),0,0)
end
-- 效果的处理函数，根据选择的怪兽进行特殊召唤
function c1896112.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标怪兽的集合，并筛选出与效果相关的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local g1=g:Filter(Card.IsControler,nil,tp)
	local g2=g:Filter(Card.IsControler,nil,1-tp)
	-- 获取当前玩家场上可用的怪兽区域数量
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct1=g1:GetCount()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft1>=ct1 and (ct1==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133)) then
		local tc=g1:GetFirst()
		while tc do
			-- 特殊召唤一张怪兽到己方场上
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc=g1:GetNext()
		end
	end
	-- 获取对方玩家场上可用的怪兽区域数量
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	local ct2=g2:GetCount()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft2>=ct2 and (ct2==1 or not Duel.IsPlayerAffectedByEffect(1-tp,59822133)) then
		local tc=g2:GetFirst()
		while tc do
			-- 特殊召唤一张怪兽到对方场上
			Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP)
			tc=g2:GetNext()
		end
	end
	-- 完成所有特殊召唤操作
	Duel.SpecialSummonComplete()
end
