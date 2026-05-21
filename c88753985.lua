--きつね火
-- 效果：
-- 场上表侧表示存在的这张卡被战斗破坏送去墓地的回合的结束阶段时，这张卡从墓地特殊召唤。这张卡只要在场上表侧表示存在，不能为上级召唤而解放。
function c88753985.initial_effect(c)
	-- 场上表侧表示存在的这张卡被战斗破坏送去墓地的回合的结束阶段时，这张卡从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetOperation(c88753985.regop)
	c:RegisterEffect(e1)
	-- 这张卡只要在场上表侧表示存在，不能为上级召唤而解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 在自身被战斗破坏送去墓地时，注册一个在回合结束阶段发动的特殊召唤效果
function c88753985.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousPosition(POS_FACEUP) then
		-- 场上表侧表示存在的这张卡被战斗破坏送去墓地的回合的结束阶段时，这张卡从墓地特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(88753985,0))  --"特殊召唤"
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c88753985.sptg)
		e1:SetOperation(c88753985.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 特殊召唤效果的发动准备，设置特殊召唤的操作信息
function c88753985.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果的处理为特殊召唤1张自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的实际处理，若满足条件则将自身特殊召唤
function c88753985.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则无法特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
