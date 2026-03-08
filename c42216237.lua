--ゼラの天使
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 「杰拉的天使」的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升除外的对方的卡数量×100。
-- ②：这张卡被除外的场合，下个回合的准备阶段发动。除外的这张卡特殊召唤。
function c42216237.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升除外的对方的卡数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c42216237.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，下个回合的准备阶段发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_REMOVE)
	e2:SetOperation(c42216237.spreg)
	c:RegisterEffect(e2)
	-- 除外的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42216237,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1,42216237)
	e3:SetCondition(c42216237.spcon)
	e3:SetTarget(c42216237.sptg)
	e3:SetOperation(c42216237.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 计算除外的对方卡的数量并乘以100作为攻击力加成
function c42216237.atkval(e,c)
	-- 获取除外的对方卡的数量并乘以100
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_REMOVED)*100
end
-- 记录除外时的回合数并设置标记
function c42216237.spreg(e,tp,eg,ep,ev,re,r,rp)
	-- 记录当前回合数用于后续判断
	e:SetLabel(Duel.GetTurnCount())
	e:GetHandler():RegisterFlagEffect(42216237,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
-- 判断是否为下个回合的准备阶段且满足特殊召唤条件
function c42216237.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断除外时的回合数不等于当前回合数且持有标记
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and c:GetFlagEffect(42216237)>0
end
-- 设置特殊召唤的效果处理信息
function c42216237.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 设置将自身特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(42216237)
end
-- 执行特殊召唤操作
function c42216237.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以正面表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
