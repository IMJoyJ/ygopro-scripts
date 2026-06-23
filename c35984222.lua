--超魔神イド
-- 效果：
-- 这张卡被卡的效果破坏送去墓地的场合，下个回合的准备阶段时这张卡从墓地特殊召唤，这张卡以外的自己场上存在的怪兽全部破坏。只要这张卡在自己场上表侧表示存在，自己不能把怪兽通常召唤·反转召唤·特殊召唤。「超魔神 本我」在自己场上只能有1张表侧表示存在。
function c35984222.initial_effect(c)
	c:SetUniqueOnField(1,0,35984222)
	-- 这张卡被卡的效果破坏送去墓地的场合，下个回合的准备阶段时这张卡从墓地特殊召唤，这张卡以外的自己场上存在的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c35984222.spr)
	c:RegisterEffect(e1)
	-- 只要这张卡在自己场上表侧表示存在，自己不能把怪兽通常召唤·反转召唤·特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35984222,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c35984222.spcon)
	e2:SetTarget(c35984222.sptg)
	e2:SetOperation(c35984222.spop)
	c:RegisterEffect(e2)
	-- 「超魔神 本我」在自己场上只能有1张表侧表示存在。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e6)
end
-- 当此卡因效果破坏送入墓地时，记录标记flag，用于后续特殊召唤判定。
function c35984222.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 or c:IsPreviousLocation(LOCATION_SZONE) then return end
	c:RegisterFlagEffect(35984222,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
-- 判断是否为下个回合的准备阶段且已记录标记flag，决定是否发动特殊召唤。
function c35984222.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否为下个回合且已记录标记flag，决定是否发动特殊召唤。
	return c:GetTurnID()~=Duel.GetTurnCount() and c:GetFlagEffect(35984222)>0
end
-- 设置特殊召唤及破坏效果的目标与数量信息。
function c35984222.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取己方场上所有怪兽作为破坏目标。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,e:GetHandler())
	-- 设置将要破坏的怪兽数量信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置将要特殊召唤的卡信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤并随后破坏己方场上所有怪兽。
function c35984222.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否仍存在于场上且成功特殊召唤，若成功则继续执行破坏效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取己方场上所有怪兽作为破坏目标。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,c)
		-- 将己方场上所有怪兽以效果原因破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
