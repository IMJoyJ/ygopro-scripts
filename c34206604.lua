--魔導サイエンティスト
-- 效果：
-- 支付1000基本分，就可以从自己的融合卡组中特殊召唤1只6星以下的融合怪兽。这只融合怪兽不能对对方进行直接攻击，回合结束时回到融合卡组。
function c34206604.initial_effect(c)
	-- 支付1000基本分，就可以从自己的融合卡组中特殊召唤1只6星以下的融合怪兽。
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
-- 定义特殊召唤候选怪兽的过滤条件：必须是6星以下的融合怪兽、能被玩家tp特殊召唤，并且场上存在可供额外卡组怪兽特殊召唤的空位。
function c34206604.filter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 额外检查：从额外卡组特殊召唤该怪兽时，玩家tp场上是否有足够的可用区域（额外怪兽区/可用主怪兽区）。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 定义效果的发动代价：先检查能否支付1000基本分，能则实际支付1000基本分。
function c34206604.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段（chk==0）检查玩家tp是否能支付1000基本分；若不能则效果无法发动。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际扣除玩家tp的1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 定义效果发动条件和发动时操作信息：确认可以从额外卡组选出1只满足条件的融合怪兽，并设定本效果将进行特殊召唤。
function c34206604.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时确认玩家tp的额外卡组存在至少1只满足条件的融合怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c34206604.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息，向系统声明本效果将把1只怪兽从额外卡组特殊召唤，供后续时点与连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理时：从额外卡组选择1只符合条件的融合怪兽并特殊召唤；若成功，则给它附加不能直接攻击和回合结束回额外卡组的效果。
function c34206604.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家进行选择，显示“请选择要特殊召唤的卡”的选择框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家tp从自己的额外卡组中选择1只满足过滤条件的融合怪兽。
	local g=Duel.SelectMatchingCard(tp,c34206604.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将所选怪兽以表侧表示特殊召唤到玩家tp场上；若特殊召唤成功（返回值非0）则继续添加限制效果。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这只融合怪兽不能对对方进行直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 回合结束时回到融合卡组。
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
-- 定义回合结束阶段将效果持有者（该融合怪兽）送回持有者额外卡组的操作。
function c34206604.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将效果持有者（该融合怪兽）以效果原因送回持有者的额外卡组顶端。
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_EFFECT)
end
