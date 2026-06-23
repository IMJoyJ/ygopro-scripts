--シャトルロイド
-- 效果：
-- 这张卡被选择作为攻击对象时，可以把这张卡从游戏中除外。这个效果从游戏中除外的场合，这张卡在下次的自己的准备阶段时特殊召唤。那个时候，给与对方基本分1000分伤害。
function c10449150.initial_effect(c)
	-- 这张卡被选择作为攻击对象时，可以把这张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10449150,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetTarget(c10449150.rmtg)
	e1:SetOperation(c10449150.rmop)
	c:RegisterEffect(e1)
	-- 这个效果从游戏中除外的场合，这张卡在下次的自己的准备阶段时特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10449150,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCondition(c10449150.spcon)
	e2:SetTarget(c10449150.sptg)
	e2:SetOperation(c10449150.spop)
	c:RegisterEffect(e2)
	-- 那个时候，给与对方基本分1000分伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10449150,2))  --"LP伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c10449150.damcon)
	e3:SetTarget(c10449150.damtg)
	e3:SetOperation(c10449150.damop)
	c:RegisterEffect(e3)
end
-- 设置除外效果的处理目标
function c10449150.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	-- 设置除外效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 处理除外效果
function c10449150.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将卡片从游戏中除外并注册flag
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then
		c:RegisterFlagEffect(10449150,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- 判断是否为自己的准备阶段
function c10449150.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的准备阶段
	return Duel.GetTurnPlayer()==tp
end
-- 设置特殊召唤效果的处理目标
function c10449150.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(10449150)~=0 end
	e:GetHandler():ResetFlagEffect(10449150)
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置伤害效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 处理特殊召唤效果
function c10449150.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡片特殊召唤到场上
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- 判断是否为特殊召唤成功
function c10449150.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 设置伤害效果的处理目标
function c10449150.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的目标玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的目标参数
	Duel.SetTargetParam(1000)
	-- 设置伤害效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 处理伤害效果
function c10449150.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
