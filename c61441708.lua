--ネフティスの鳳凰神
-- 效果：
-- ①：这张卡被效果破坏送去墓地的场合，下次的自己准备阶段发动。这张卡从墓地特殊召唤。
-- ②：这张卡的①的效果特殊召唤的场合发动。场上的魔法·陷阱卡全部破坏。
function c61441708.initial_effect(c)
	-- ①：这张卡被效果破坏送去墓地的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c61441708.spr)
	c:RegisterEffect(e1)
	-- ①：这张卡被效果破坏送去墓地的场合，下次的自己准备阶段发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61441708,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c61441708.spcon)
	e2:SetTarget(c61441708.sptg)
	e2:SetOperation(c61441708.spop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：这张卡的①的效果特殊召唤的场合发动。场上的魔法·陷阱卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61441708,1))  --"魔法·陷阱卡全部破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c61441708.descon)
	e3:SetTarget(c61441708.destg)
	e3:SetOperation(c61441708.desop)
	c:RegisterEffect(e3)
end
-- 记录这张卡被效果破坏送去墓地的状态，并根据当前是否为自己的准备阶段注册对应回合数的Flag
function c61441708.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 then return end
	-- 判断被破坏送去墓地时是否正是自己的准备阶段
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 将当前回合数记录在Label中，用于后续判断是否在同一回合
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(61441708,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(61441708,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- 特殊召唤效果的发动条件：当前是自己的准备阶段、不是被破坏的当回合，且卡片带有被效果破坏送墓的Flag
function c61441708.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前回合数不等于被破坏时的回合数，且当前是自己回合的准备阶段，且卡片存有对应的Flag
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and c:GetFlagEffect(61441708)>0
end
-- 特殊召唤效果的靶向处理：设置特殊召唤的操作信息，并重置Flag
function c61441708.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 设置特殊召唤的操作信息，表示将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(61441708)
end
-- 特殊召唤效果的实际处理：如果卡片仍在墓地，则将自身特殊召唤
function c61441708.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以自身效果特殊召唤到场上
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 破坏效果的发动条件：这张卡是通过自身效果特殊召唤成功的
function c61441708.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤场上的魔法·陷阱卡
function c61441708.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的靶向处理：获取场上所有的魔法·陷阱卡，并设置破坏的操作信息
function c61441708.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c61441708.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置破坏的操作信息，数量为获取到的魔法·陷阱卡数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的实际处理：获取场上所有的魔法·陷阱卡并全部破坏
function c61441708.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c61441708.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 因效果破坏这些卡
	Duel.Destroy(g,REASON_EFFECT)
end
