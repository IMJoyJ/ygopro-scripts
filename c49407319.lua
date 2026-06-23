--スター・マイン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 自己对「速射连发烟花」1回合只能有1次特殊召唤。
-- ①：这张卡被对方怪兽的攻击或者对方的效果破坏的场合发动。自己受到2000伤害。那之后，给与对方2000伤害。
-- ②：这张卡的相邻的怪兽区域存在的怪兽被对方怪兽的攻击或者对方的效果破坏的场合发动。这张卡破坏，自己受到2000伤害。那之后，给与对方2000伤害。
function c49407319.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(49407319)
	-- ①：这张卡被对方怪兽的攻击或者对方的效果破坏的场合发动。自己受到2000伤害。那之后，给与对方2000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49407319,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c49407319.damcon)
	e1:SetTarget(c49407319.damtg)
	e1:SetOperation(c49407319.damop)
	c:RegisterEffect(e1)
	-- ②：这张卡的相邻的怪兽区域存在的怪兽被对方怪兽的攻击或者对方的效果破坏的场合发动。这张卡破坏，自己受到2000伤害。那之后，给与对方2000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49407319,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c49407319.descon)
	e2:SetTarget(c49407319.destg)
	e2:SetOperation(c49407319.desop)
	c:RegisterEffect(e2)
end
-- 判断该卡是否因对方效果或战斗破坏而被破坏且破坏时控制权属于对方
function c49407319.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp)
		-- 判断该卡是否因对方效果或战斗破坏而被破坏且破坏时控制权属于对方
		and (c:IsReason(REASON_EFFECT) and rp==1-tp or c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp))
end
-- 设置连锁处理信息，确定将对所有玩家造成2000伤害
function c49407319.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息，确定将对所有玩家造成2000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,2000)
end
-- 当该卡因对方效果或战斗破坏时触发，先对自己造成2000伤害再对对方造成2000伤害
function c49407319.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功对自己造成2000伤害
	if Duel.Damage(tp,2000,REASON_EFFECT)>0 then
		-- 中断当前效果处理，使后续效果视为错时点处理
		Duel.BreakEffect()
		-- 对对方造成2000伤害
		Duel.Damage(1-tp,2000,REASON_EFFECT)
	end
end
-- 过滤满足条件的被破坏怪兽，包括其控制权、位置、破坏原因及相邻区域判断
function c49407319.filter(c,tp,rp,seq)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		-- 判断该卡是否因对方效果或战斗破坏而被破坏且破坏时控制权属于对方
		and ((c:IsReason(REASON_EFFECT) and rp==1-tp) or (c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp)))
		and c:GetPreviousSequence()<5 and math.abs(seq-c:GetPreviousSequence())==1
end
-- 判断是否有相邻区域被破坏的怪兽满足条件
function c49407319.descon(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetHandler():GetSequence()
	if seq>=5 then return false end
	return eg:IsExists(c49407319.filter,1,nil,tp,rp,seq)
end
-- 设置连锁处理信息，确定将破坏自身并造成2000伤害
function c49407319.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息，确定将破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置连锁处理信息，确定将对所有玩家造成2000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,2000)
end
-- 当相邻区域怪兽被对方效果或战斗破坏时触发，先破坏自身再对自己造成2000伤害再对对方造成2000伤害
function c49407319.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自身是否仍在场上且成功破坏自身并对自己造成2000伤害
	if e:GetHandler():IsRelateToEffect(e) and Duel.Destroy(e:GetHandler(),REASON_EFFECT)>0 and Duel.Damage(tp,2000,REASON_EFFECT)>0 then
		-- 中断当前效果处理，使后续效果视为错时点处理
		Duel.BreakEffect()
		-- 对对方造成2000伤害
		Duel.Damage(1-tp,2000,REASON_EFFECT)
	end
end
