--闇よりの恐怖
-- 效果：
-- 当这张卡被对方的效果从手卡或卡组送去墓地时，这张卡特殊召唤上场。
function c34193084.initial_effect(c)
	-- 当这张卡被对方的效果从手卡或卡组送去墓地时，这张卡特殊召唤上场。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34193084,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c34193084.spcon)
	e1:SetTarget(c34193084.sptg)
	e1:SetOperation(c34193084.spop)
	c:RegisterEffect(e1)
end
-- 诱发条件判断：这张卡之前位于手卡或卡组，且是因效果（非战斗）被送去墓地，且该效果的控制者为对方玩家。
function c34193084.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK) and bit.band(r,REASON_EFFECT)~=0 and rp==1-tp
end
-- 发动前目标处理：在合法性检查阶段（chk==0）直接判定可以发动；在确定发动时登记特殊召唤这张卡的操作信息。
function c34193084.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次连锁的特殊召唤操作信息：将这张卡作为预定特殊召唤的确定对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时的实际执行：若这张卡仍与当前效果保持关联（未被无效或离场导致联系重置），则将其特殊召唤。
function c34193084.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到玩家tp的场上（此调用不忽略召唤条件与苏生限制）。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
