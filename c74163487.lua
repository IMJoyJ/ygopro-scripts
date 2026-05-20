--レストレーション・ポイントガード
-- 效果：
-- 电子界族怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，这张卡以外的连接怪兽连接召唤成功的场合发动。这个回合，这张卡不会被战斗·效果破坏。
-- ②：这张卡在墓地存在，这张卡为素材作连接召唤的连接怪兽被对方的效果破坏的场合才能发动。这张卡特殊召唤。
function c74163487.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤的手续，需要2只电子界族怪兽作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	-- ①：1回合1次，这张卡以外的连接怪兽连接召唤成功的场合发动。这个回合，这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c74163487.incon)
	e1:SetOperation(c74163487.inop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，这张卡为素材作连接召唤的连接怪兽被对方的效果破坏的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c74163487.regcon)
	e2:SetOperation(c74163487.regop)
	c:RegisterEffect(e2)
end
-- 检查是否有这张卡以外的连接怪兽连接召唤成功
function c74163487.incon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_LINK) and not eg:IsContains(e:GetHandler())
end
-- 效果①的操作处理：使这张卡在回合结束前不会被战斗和效果破坏
function c74163487.inop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 这个回合，这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
end
-- 检查是否是作为连接召唤的素材
function c74163487.regcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
-- 在这张卡作为连接召唤素材时，在墓地注册一个在素材怪兽被破坏时可以发动的诱发效果
function c74163487.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ②：这张卡在墓地存在，这张卡为素材作连接召唤的连接怪兽被对方的效果破坏的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,74163487)
	e1:SetLabelObject(rc)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c74163487.spcon)
	e1:SetTarget(c74163487.sptg)
	e1:SetOperation(c74163487.spop)
	c:RegisterEffect(e1)
end
-- 检查作为素材的连接怪兽是否被对方的效果破坏
function c74163487.spcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetLabelObject()
	return eg:IsContains(rc) and bit.band(r,REASON_EFFECT)~=0 and rp==1-tp
end
-- 检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c74163487.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，将自身作为特殊召唤的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的操作处理：将墓地的这张卡特殊召唤
function c74163487.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自身场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
