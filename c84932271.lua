--ワーム・ジェートリクプス
-- 效果：
-- 反转：这个回合这张卡被破坏送去墓地时，这张卡在自己场上守备表示特殊召唤。
function c84932271.initial_effect(c)
	-- 反转：
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetOperation(c84932271.flipop)
	c:RegisterEffect(e1)
	-- 这个回合这张卡被破坏送去墓地时，这张卡在自己场上守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84932271,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c84932271.spcon)
	e2:SetTarget(c84932271.sptg)
	e2:SetOperation(c84932271.spop)
	c:RegisterEffect(e2)
end
-- 在怪兽翻转时，为自身注册一个在回合结束前有效的标识，用于记录该卡在本回合内曾翻转过
function c84932271.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) then
		c:RegisterFlagEffect(84932271,RESET_EVENT+0x17a0000+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 检查怪兽送去墓地的原因是否为被破坏
function c84932271.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 检查怪兽是否在本回合内翻转过（是否存在对应的标识效果），并设置特殊召唤的操作信息
function c84932271.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(84932271)~=0 end
	-- 设置特殊召唤的操作信息，将自身作为特殊召唤的对象，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时，若此卡仍存在于墓地，则将其在自己场上表侧守备表示特殊召唤
function c84932271.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡在自己场上表侧守备表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
