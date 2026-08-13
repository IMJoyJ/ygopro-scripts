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
-- 筛选满足条件的除外区表侧怪兽：该卡必须表侧表示，并且能够被对应玩家通过此效果特殊召唤（遵守召唤条件和苏生限制）。
function c23557835.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动代价处理：效果发动需要支付2000基本分，此函数负责在发动时检查代价并在确认后支付。
function c23557835.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）判断当前玩家是否能够支付2000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 实际扣除当前玩家2000基本分，完成代价支付。
	Duel.PayLPCost(tp,2000)
end
-- 效果发动条件的判定：只有自己或对方场上存在可用怪兽区空位，且对应玩家的除外区存在可被该玩家特殊召唤的表侧怪兽时，效果才能发动。
function c23557835.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return
		-- 检查自己的怪兽区是否有空位，且自己的除外区存在能被自己特殊召唤的表侧怪兽。
		(Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c23557835.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp)) or
		-- 检查对方的怪兽区是否有空位，且对方的除外区存在能被对方特殊召唤的表侧怪兽。
		(Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c23557835.filter,tp,0,LOCATION_REMOVED,1,nil,e,1-tp))
	end
	-- 将本次连锁标记为包含特殊召唤效果，操作目标预计为双方除外区的怪兽，用于让相关卡（如星尘龙等）正确响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,2,LOCATION_REMOVED)
end
-- 效果处理时：分别计算双方可用怪兽区空位；若有空位，则让对应玩家从自己的除外区选择满足条件的表侧怪兽，并通过特殊召唤步骤尽可能多地特殊召唤到各自场上；若青眼精灵龙的效果适用中，则每方最多特殊召唤1只；最后统一完成特殊召唤。
function c23557835.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区空格数，决定自己最多能特殊召唤的数量。
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft1>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft1=1 end
		-- 向自己玩家显示选择要特殊召唤的卡片的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的除外区选择满足条件的表侧怪兽，选择数量上限为自己可用怪兽区空格数。
		local g=Duel.SelectMatchingCard(tp,c23557835.filter,tp,LOCATION_REMOVED,0,ft1,ft1,nil,e,tp)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			while tc do
				-- 将当前选中的怪兽以表侧表示加入特殊召唤步骤，特召到自己场上。
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				tc=g:GetNext()
			end
		end
	end
	-- 获取对方场上可用的怪兽区空格数，决定对方最多能特殊召唤的数量。
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if ft2>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(1-tp,59822133) then ft2=1 end
		-- 向对方玩家显示选择要特殊召唤的卡片的提示信息。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让对方玩家从自己的除外区选择满足条件的表侧怪兽，选择数量上限为对方可用怪兽区空格数。
		local g=Duel.SelectMatchingCard(1-tp,c23557835.filter,tp,0,LOCATION_REMOVED,ft2,ft2,nil,e,1-tp)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			while tc do
				-- 将当前选中的怪兽以表侧表示加入特殊召唤步骤，特召到对方场上。
				Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP)
				tc=g:GetNext()
			end
		end
	end
	-- 完成特殊召唤处理，将累积的特殊召唤步骤统一处理为特殊召唤成功。
	Duel.SpecialSummonComplete()
end
