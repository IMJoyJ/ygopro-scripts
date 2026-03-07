--極神皇トール
-- 效果：
-- 「极星兽」调整＋调整以外的怪兽2只以上
-- ①：1回合1次，自己主要阶段才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
-- ②：场上的表侧表示的这张卡被对方破坏送去墓地的回合的结束阶段，从自己墓地把1只「极星兽」调整除外才能发动。这张卡从墓地特殊召唤。
-- ③：这张卡的②的效果特殊召唤成功时才能发动。给与对方800伤害。
function c30604579.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整且满足tfilter条件，2只调整以外的怪兽
	aux.AddSynchroProcedure(c,c30604579.tfilter,aux.NonTuner(nil),2)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己主要阶段才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30604579,0))  --"怪兽效果无效化"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c30604579.distg)
	e1:SetOperation(c30604579.disop)
	c:RegisterEffect(e1)
	-- ②：场上的表侧表示的这张卡被对方破坏送去墓地的回合的结束阶段，从自己墓地把1只「极星兽」调整除外才能发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c30604579.regop)
	c:RegisterEffect(e2)
	-- ③：这张卡的②的效果特殊召唤成功时才能发动。给与对方800伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30604579,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(c30604579.spcon)
	e3:SetCost(c30604579.spcost)
	e3:SetTarget(c30604579.sptg)
	e3:SetOperation(c30604579.spop)
	c:RegisterEffect(e3)
	-- ③：这张卡的②的效果特殊召唤成功时才能发动。给与对方800伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(30604579,2))  --"给与对方800伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c30604579.damcon)
	e4:SetTarget(c30604579.damtg)
	e4:SetOperation(c30604579.damop)
	c:RegisterEffect(e4)
end
-- 过滤满足「极星兽」卡包或拥有效果61777313的怪兽
function c30604579.tfilter(c)
	return c:IsSetCard(0x6042) or c:IsHasEffect(61777313)
end
-- 检查对方场上是否存在至少1只表侧表示的怪兽
function c30604579.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 将对方场上所有表侧表示的怪兽效果无效化
function c30604579.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	while tc do
		-- 使目标怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 记录特殊召唤条件
function c30604579.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local pos=c:GetPreviousPosition()
	if c:IsReason(REASON_BATTLE) then pos=c:GetBattlePosition() end
	if rp==1-tp and c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and bit.band(pos,POS_FACEUP)~=0 then
		c:RegisterFlagEffect(30604579,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判断是否满足特殊召唤条件
function c30604579.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(30604579)~=0
end
-- 过滤满足「极星兽」调整的怪兽
function c30604579.cfilter(c)
	return c:IsSetCard(0x6042) and c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
-- 检查是否满足特殊召唤的费用条件
function c30604579.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(c30604579.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择要除外的卡
	local g=Duel.SelectMatchingCard(tp,c30604579.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检查是否满足特殊召唤条件
function c30604579.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c30604579.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将卡特殊召唤到场上
		Duel.SpecialSummon(e:GetHandler(),SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否为特殊召唤成功
function c30604579.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 设置伤害操作信息
function c30604579.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害值为800
	Duel.SetTargetParam(800)
	-- 设置伤害操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 执行伤害效果
function c30604579.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的伤害对象和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
