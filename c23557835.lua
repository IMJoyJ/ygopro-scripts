--次元融合
-- 效果：
-- 支付2000基本分。双方将各自被除外的怪兽尽可能特殊召唤上场。
function c23557835.initial_effect(c)
	-- 支付2000基本分。双方将各自被除外的怪兽尽可能特殊召唤上场。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c23557835.cost)
	e1:SetTarget(c23557835.tg)
	e1:SetOperation(c23557835.op)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查以玩家tp来看的除外区是否存在满足条件的怪兽（表侧表示且可以特殊召唤）
function c23557835.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 支付2000基本分
function c23557835.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家tp是否能支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 让玩家tp支付2000基本分
	Duel.PayLPCost(tp,2000)
end
-- 设置连锁处理时的提示信息，确定要处理的卡为除外区的怪兽
function c23557835.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return
		-- 检查玩家tp的场上是否存在空位且除外区是否存在满足条件的怪兽
		(Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c23557835.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp)) or
		-- 检查玩家1-tp的场上是否存在空位且除外区是否存在满足条件的怪兽
		(Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c23557835.filter,tp,0,LOCATION_REMOVED,1,nil,e,1-tp))
	end
	-- 设置操作信息，表示本次效果将特殊召唤除外区的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,2,LOCATION_REMOVED)
end
-- 处理效果的发动，分别处理双方的特殊召唤
function c23557835.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家tp的场上可用怪兽区域数量
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft1>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft1=1 end
		-- 向玩家tp发送提示信息，提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家tp从除外区选择满足条件的怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,c23557835.filter,tp,LOCATION_REMOVED,0,ft1,ft1,nil,e,tp)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			while tc do
				-- 特殊召唤一张怪兽卡到玩家tp的场上
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				tc=g:GetNext()
			end
		end
	end
	-- 获取玩家1-tp的场上可用怪兽区域数量
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if ft2>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(1-tp,59822133) then ft2=1 end
		-- 向玩家1-tp发送提示信息，提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家1-tp从除外区选择满足条件的怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(1-tp,c23557835.filter,tp,0,LOCATION_REMOVED,ft2,ft2,nil,e,1-tp)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			while tc do
				-- 特殊召唤一张怪兽卡到玩家1-tp的场上
				Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP)
				tc=g:GetNext()
			end
		end
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
