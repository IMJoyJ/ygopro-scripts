--異次元の偵察機
-- 效果：
-- ①：这张卡被除外的回合的结束阶段发动。除外的这张卡攻击表示特殊召唤（1回合只有1次）。
function c3773196.initial_effect(c)
	-- ①：这张卡被除外的回合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_REMOVE)
	e1:SetOperation(c3773196.rmop)
	c:RegisterEffect(e1)
	-- 的结束阶段发动。除外的这张卡攻击表示特殊召唤（1回合只有1次）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3773196,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCondition(c3773196.condition)
	e2:SetTarget(c3773196.target)
	e2:SetOperation(c3773196.operation)
	c:RegisterEffect(e2)
end
-- 该效果为不入连锁的诱发效果：当这张卡被除外时，若其为表侧表示，则给自身注册一个标志（3773196），用于记录“这张卡被除外的回合”，该标志会在离场/返回手牌/卡组/墓地等重置或结束阶段时重置。
function c3773196.rmop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsFacedown() then return end
	e:GetHandler():RegisterFlagEffect(3773196,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 结束阶段发动条件：检查这张卡是否带有3773196标志，即本回合是否曾因除外而离开过场上。
function c3773196.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(3773196)~=0
end
-- 发动时的追加条件与处理：若这张卡已带有3773197标志（本回合已发动过此效果）则不能发动；通过后设置操作信息，并注册3773197标志，实现“1回合只有1次”的限制。
function c3773196.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(3773197)==0 end
	-- 向系统声明本次效果处理包含特殊召唤操作，处理时将对这张卡进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(3773197,RESET_EVENT+0x4760000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤的实际处理：若这张卡仍与当前效果相关联，则优先将其特殊召唤；若主要怪兽区无空位，则改为送去墓地。
function c3773196.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 检查我方主要怪兽区可用区域数量是否小于等于0（即没有可用的怪兽区域）。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
			-- 因为没有可用怪兽区域，将这张卡从除外区以效果原因送去墓地。
			Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
			return
		end
		-- 成功时，将这张卡以表侧攻击表示特殊召唤到我的主要怪兽区（由于是效果特殊召唤，召唤条件与苏生限制均不检查）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
