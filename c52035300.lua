--不死武士
-- 效果：
-- ①：这张卡只要在怪兽区域存在，不能为战士族怪兽的上级召唤以外而解放。
-- ②：自己准备阶段有这张卡在墓地存在，自己墓地没有战士族怪兽以外的怪兽存在的场合才能发动。这张卡特殊召唤。这个效果在自己场上没有怪兽存在的场合才能发动和处理。
function c52035300.initial_effect(c)
	-- 效果原文：①：这张卡只要在怪兽区域存在，不能为战士族怪兽的上级召唤以外而解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c52035300.recon)
	c:RegisterEffect(e1)
	-- 效果原文：①：这张卡只要在怪兽区域存在，不能为战士族怪兽的上级召唤以外而解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 效果原文：②：自己准备阶段有这张卡在墓地存在，自己墓地没有战士族怪兽以外的怪兽存在的场合才能发动。这张卡特殊召唤。这个效果在自己场上没有怪兽存在的场合才能发动和处理。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(52035300,0))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(c52035300.condition)
	e3:SetTarget(c52035300.target)
	e3:SetOperation(c52035300.operation)
	c:RegisterEffect(e3)
end
-- 规则层面：判断是否为战士族怪兽，若不是则不能作为上级召唤的祭品。
function c52035300.recon(e,c)
	return not c:IsRace(RACE_WARRIOR)
end
-- 规则层面：过滤出墓地中的非战士族怪兽。
function c52035300.filter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_WARRIOR)
end
-- 规则层面：判断是否为当前回合玩家、场上没有怪兽、墓地没有非战士族怪兽，满足条件时才能发动效果。
function c52035300.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断是否为当前回合玩家且场上没有怪兽。
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 规则层面：判断墓地中是否存在非战士族的怪兽。
		and not Duel.IsExistingMatchingCard(c52035300.filter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 规则层面：设置特殊召唤的处理目标和条件检查。
function c52035300.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查是否有足够的召唤位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面：设置连锁操作信息，表示将要特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面：执行特殊召唤操作，包括位置限制和召唤条件检查。
function c52035300.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断是否满足特殊召唤的条件（召唤位置和场上怪兽数量）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 then return end
	if e:GetHandler():IsRelateToEffect(e) then
		-- 规则层面：将此卡以正面表示形式特殊召唤到场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
