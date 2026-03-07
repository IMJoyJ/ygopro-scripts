--魔導サイエンティスト
-- 效果：
-- 支付1000基本分，就可以从自己的融合卡组中特殊召唤1只6星以下的融合怪兽。这只融合怪兽不能对对方进行直接攻击，回合结束时回到融合卡组。
function c34206604.initial_effect(c)
	-- 效果原文：支付1000基本分，就可以从自己的融合卡组中特殊召唤1只6星以下的融合怪兽。这只融合怪兽不能对对方进行直接攻击，回合结束时回到融合卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(34206604,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c34206604.cost)
	e1:SetTarget(c34206604.target)
	e1:SetOperation(c34206604.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的融合怪兽：等级不超过6星且可以特殊召唤的怪兽
function c34206604.filter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查场上是否有足够的位置来特殊召唤该怪兽
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 支付1000基本分的费用
function c34206604.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 设置特殊召唤的连锁操作信息
function c34206604.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在满足条件的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c34206604.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行特殊召唤操作
function c34206604.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c34206604.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽特殊召唤到场上
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 效果原文：这只融合怪兽不能对对方进行直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 效果原文：回合结束时回到融合卡组。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetOperation(c34206604.retop)
		tc:RegisterEffect(e2)
	end
end
-- 将怪兽送回卡组顶端
function c34206604.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将怪兽送回卡组顶端
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_EFFECT)
end
