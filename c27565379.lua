--B・F－霊弓のアズサ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡以外的「蜂军」怪兽的效果让对方受到伤害时才能发动（伤害步骤也能发动）。给与对方那只怪兽的原本攻击力数值的伤害。
-- ②：这张卡在墓地存在的状态，自己的「蜂军」怪兽的战斗让怪兽被破坏时才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c27565379.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡以外的「蜂军」怪兽的效果让对方受到伤害时才能发动（伤害步骤也能发动）。给与对方那只怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27565379,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,27565379)
	e1:SetCondition(c27565379.damcon)
	e1:SetTarget(c27565379.damtg)
	e1:SetOperation(c27565379.damop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己的「蜂军」怪兽的战斗让怪兽被破坏时才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27565379,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c27565379.spcon)
	e2:SetTarget(c27565379.sptg)
	e2:SetOperation(c27565379.spop)
	c:RegisterEffect(e2)
end
-- 判断是否为对方造成的伤害且不是战斗伤害，且效果来源不是此卡，且效果来源为怪兽卡且为蜂军卡组
function c27565379.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and bit.band(r,REASON_BATTLE)==0 and re and re:GetHandler()~=e:GetHandler() and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x12f)
end
-- 设置伤害目标为对方玩家，设置伤害值为效果来源怪兽的原本攻击力
function c27565379.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=re:GetHandler()
	local atk=tc:GetBaseAttack()
	-- 设置连锁处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息为对对方造成指定数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 执行伤害效果，对指定玩家造成指定数值的伤害
function c27565379.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local tc=re:GetHandler()
	local atk=tc:GetBaseAttack()
	-- 对指定玩家造成指定数值的伤害
	Duel.Damage(p,atk,REASON_EFFECT)
end
-- 判断被战斗破坏的怪兽是否为蜂军卡组且满足特殊召唤条件
function c27565379.cfilter(c,tp)
	if c:IsSetCard(0x12f) and c:IsPreviousControler(tp) then return true end
	local rc=c:GetBattleTarget()
	return rc:IsSetCard(0x12f)
		and (not rc:IsLocation(LOCATION_MZONE) and rc:IsPreviousControler(tp)
			or rc:IsLocation(LOCATION_MZONE) and rc:IsControler(tp))
end
-- 判断被战斗破坏的怪兽中是否存在满足条件的蜂军怪兽且此卡不在破坏列表中
function c27565379.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c27565379.cfilter,1,nil,tp)
end
-- 判断是否满足特殊召唤条件，包括场上是否有空位和此卡是否可以特殊召唤
function c27565379.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁操作信息为特殊召唤此卡到对方场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将此卡特殊召唤到对方场上并设置其离场时的处理
function c27565379.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否可以参与特殊召唤且特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 设置此卡离场时被移除（不进入墓地）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
