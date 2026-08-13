--不死武士
-- 效果：
-- ①：这张卡只要在怪兽区域存在，不能为战士族怪兽的上级召唤以外而解放。
-- ②：自己准备阶段有这张卡在墓地存在，自己墓地没有战士族怪兽以外的怪兽存在的场合才能发动。这张卡特殊召唤。这个效果在自己场上没有怪兽存在的场合才能发动和处理。
function c52035300.initial_effect(c)
	-- ①：这张卡只要在怪兽区域存在，不能为战士族怪兽的上级召唤以外而解放。（本行实现“不能作为非战士族怪兽的上级召唤祭品”的部分）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c52035300.recon)
	c:RegisterEffect(e1)
	-- ①：这张卡只要在怪兽区域存在，不能为战士族怪兽的上级召唤以外而解放。（本行实现“不能作为上级召唤以外的解放”的部分）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段有这张卡在墓地存在，自己墓地没有战士族怪兽以外的怪兽存在的场合才能发动。这张卡特殊召唤。这个效果在自己场上没有怪兽存在的场合才能发动和处理。
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
-- 判定祭品怪兽是否不是战士族；若返回 true，则该怪兽不能作为这张卡的上级召唤祭品，从而保证只能为战士族怪兽的上级召唤而解放。
function c52035300.recon(e,c)
	return not c:IsRace(RACE_WARRIOR)
end
-- 过滤墓地中“是怪兽且不是战士族”的卡，用于检查墓地是否存在战士族以外的怪兽。
function c52035300.filter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_WARRIOR)
end
-- 发动条件：自己的准备阶段、自己场上没有怪兽、且墓地没有战士族以外的怪兽时，此效果才能发动。
function c52035300.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 必须是自己回合的准备阶段，且自己场上没有怪兽。
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 自己墓地不存在战士族以外的怪兽（即墓地里的怪兽均为战士族）。
		and not Duel.IsExistingMatchingCard(c52035300.filter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 目标处理：效果发动前的合法性检查，确认可以特殊召唤这张卡（自己场上有空位且这张卡满足特殊召唤条件）。
function c52035300.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己主要怪兽区域存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的特殊召唤操作信息：将这张卡视为特殊召唤对象，数量为1，供连锁响应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若自己场上没有怪兽且仍有可用的主要怪兽区域，且这张卡仍与效果关联，则将其特殊召唤。
function c52035300.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己场上已有怪兽或主要怪兽区域没有空位，则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 then return end
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡从墓地以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
