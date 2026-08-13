--ゼラの天使
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 「杰拉的天使」的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升除外的对方的卡数量×100。
-- ②：这张卡被除外的场合，下个回合的准备阶段发动。除外的这张卡特殊召唤。
function c42216237.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整怪兽和1只以上调整以外的怪兽。
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
	-- 「杰拉的天使」的②的效果1回合只能使用1次。②：这张卡被除外的场合，下个回合的准备阶段发动。除外的这张卡特殊召唤。
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
-- 计算这张卡攻击力上升的数值：对方除外区的卡数量×100。
function c42216237.atkval(e,c)
	-- 返回对方除外区卡的数量乘以100，作为攻击力上升值。
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_REMOVED)*100
end
-- 这张卡被除外时，记录当前回合数并给自己注册一个标志，用于后续判定是否为“下个回合的准备阶段”。
function c42216237.spreg(e,tp,eg,ep,ev,re,r,rp)
	-- 将当前回合数保存到效果的Label中，供之后比较回合是否已经经过。
	e:SetLabel(Duel.GetTurnCount())
	e:GetHandler():RegisterFlagEffect(42216237,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
-- 准备阶段发动条件：确认除外发生时的回合数不是当前回合数（即已经过了至少一个回合），且自身带有除外时注册的标志。
function c42216237.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定为“下个回合”且标志存在时才满足发动条件。
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and c:GetFlagEffect(42216237)>0
end
-- 特殊召唤效果发动时的目标处理：效果必定发动，设置特殊召唤的操作信息，并清除除外时注册的标志，防止重复发动。
function c42216237.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 设置本次连锁的操作信息：效果涉及特殊召唤，对象为此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(42216237)
end
-- 效果处理时，若此卡仍在除外区且与效果关联，则将其特殊召唤。
function c42216237.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到其持有者的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
