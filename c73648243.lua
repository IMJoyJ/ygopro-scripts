--サンドモス
-- 效果：
-- 里侧守备表示的这张卡被战斗以外的方式破坏送去墓地时，原本的攻击力·守备力交换并在自己场上特殊召唤。
function c73648243.initial_effect(c)
	-- 里侧守备表示的这张卡被战斗以外的方式破坏送去墓地时，原本的攻击力·守备力交换并在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73648243,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c73648243.spcon)
	e1:SetTarget(c73648243.sptg)
	e1:SetOperation(c73648243.spop)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否在怪兽区域以里侧守备表示被战斗以外的方式（效果破坏）送去墓地
function c73648243.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(c:GetReason(),0x41)==0x41 and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEDOWN_DEFENSE)
end
-- 特殊召唤效果的发动准备，设置特殊召唤的操作信息
function c73648243.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的操作信息，将自身特殊召唤1只
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：获取原本攻击力与守备力，将自身特殊召唤并交换原本攻击力与守备力
function c73648243.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local batk=c:GetBaseAttack()
	local bdef=c:GetBaseDefense()
	-- 若卡片仍与效果关联，则尝试将自身以表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 原本的攻击力·守备力交换
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(bdef)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(batk)
		c:RegisterEffect(e2)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
