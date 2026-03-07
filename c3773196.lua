--異次元の偵察機
-- 效果：
-- ①：这张卡被除外的回合的结束阶段发动。除外的这张卡攻击表示特殊召唤（1回合只有1次）。
function c3773196.initial_effect(c)
	-- 效果原文内容：①：这张卡被除外的回合的结束阶段发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_REMOVE)
	e1:SetOperation(c3773196.rmop)
	c:RegisterEffect(e1)
	-- 效果原文内容：除外的这张卡攻击表示特殊召唤（1回合只有1次）。
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
-- 代码作用：当卡片被除外时，记录一个标记flag，用于后续判断是否在除外的回合结束阶段发动效果。
function c3773196.rmop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsFacedown() then return end
	e:GetHandler():RegisterFlagEffect(3773196,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 代码作用：判断是否在除外的回合结束阶段发动效果，通过检查是否有标记flag来实现。
function c3773196.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(3773196)~=0
end
-- 代码作用：设置效果的目标为自身，并注册一个flag，防止该效果在同回合重复发动。
function c3773196.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(3773197)==0 end
	-- 代码作用：设置连锁操作信息，表明该效果会将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(3773197,RESET_EVENT+0x4760000+RESET_PHASE+PHASE_END,0,1)
end
-- 代码作用：执行效果的处理逻辑，包括检查场上是否有空位，若无则送入墓地，否则特殊召唤到场上。
function c3773196.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 代码作用：检查场上是否有足够的怪兽区域，若无则将卡片送入墓地。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
			-- 代码作用：将卡片因效果原因送入墓地。
			Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
			return
		end
		-- 代码作用：以攻击表示将卡片特殊召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
