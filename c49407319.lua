--スター・マイン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 自己对「速射连发烟花」1回合只能有1次特殊召唤。
-- ①：这张卡被对方怪兽的攻击或者对方的效果破坏的场合发动。自己受到2000伤害。那之后，给与对方2000伤害。
-- ②：这张卡的相邻的怪兽区域存在的怪兽被对方怪兽的攻击或者对方的效果破坏的场合发动。这张卡破坏，自己受到2000伤害。那之后，给与对方2000伤害。
function c49407319.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整＋1只以上调整以外的怪兽作为素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(49407319)
	-- 对应①效果的注册：这张卡被对方怪兽的攻击或对方的效果破坏的场合发动，自己受到2000伤害，那之后给与对方2000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49407319,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c49407319.damcon)
	e1:SetTarget(c49407319.damtg)
	e1:SetOperation(c49407319.damop)
	c:RegisterEffect(e1)
	-- 对应②效果的注册：这张卡的相邻怪兽区域的怪兽被对方怪兽的攻击或对方的效果破坏的场合发动，这张卡破坏，自己受到2000伤害，那之后给与对方2000伤害。
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
-- ①效果的发动条件判定：确认被破坏的这张卡此前控制者是自己，且破坏原因是对方的效果（rp为对方）或对方怪兽的战斗破坏。
function c49407319.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp)
		-- 具体判定破坏原因：若是效果破坏则要求该效果的发动者是对方；若是战斗破坏则要求攻击怪兽的控制者为对方。
		and (c:IsReason(REASON_EFFECT) and rp==1-tp or c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp))
end
-- ①效果的发动时点处理：直接允许发动，并将伤害效果的操作信息登记为对双方玩家各造成2000伤害。
function c49407319.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记伤害操作信息：该效果会对双方玩家造成伤害，伤害数值为2000。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,2000)
end
-- ①效果的处理：先对自己造成2000伤害，若成功造成伤害则中断效果处理，再对对方造成2000伤害。
function c49407319.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 对自己造成2000伤害，并判断是否实际造成了伤害（防止因回复/伤害替代等效果导致未造成伤害）。
	if Duel.Damage(tp,2000,REASON_EFFECT)>0 then
		-- 中断当前效果处理链，使后续给与对方伤害的步骤不被视为同时处理，从而避免错过时点。
		Duel.BreakEffect()
		-- 在对自己造成伤害成功后，再对对方造成2000伤害。
		Duel.Damage(1-tp,2000,REASON_EFFECT)
	end
end
-- ②效果的过滤函数：筛选出被破坏的、之前在我方主要怪兽区的、且位于这张卡的相邻怪兽区域的怪兽，同时要求破坏原因是对方的效果或对方怪兽的战斗破坏。
function c49407319.filter(c,tp,rp,seq)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		-- 与damcon相同的破坏原因判定：效果破坏时要求rp为对方，战斗破坏时要求攻击怪兽控制者为对方。
		and ((c:IsReason(REASON_EFFECT) and rp==1-tp) or (c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp)))
		and c:GetPreviousSequence()<5 and math.abs(seq-c:GetPreviousSequence())==1
end
-- ②效果的发动条件：这张卡必须在主要怪兽区，且本次被破坏的怪兽组中存在满足相邻条件及破坏条件怪兽。
function c49407319.descon(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetHandler():GetSequence()
	if seq>=5 then return false end
	return eg:IsExists(c49407319.filter,1,nil,tp,rp,seq)
end
-- ②效果发动时点处理：允许发动，并登记破坏这张卡以及伤害双方各2000的操作信息。
function c49407319.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记破坏操作信息：效果对象为这张卡自身，数量1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 登记伤害操作信息：该效果会对双方玩家各造成2000伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,2000)
end
-- ②效果的处理：先确认这张卡仍与效果关联，然后破坏这张卡；若破坏成功且自己受到2000伤害，则中断效果处理，再对对方造成2000伤害。
function c49407319.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行连锁判定：这张卡仍在场上且与效果关联、破坏这张卡成功、以及对自己造成2000伤害成功，三者同时满足时继续处理。
	if e:GetHandler():IsRelateToEffect(e) and Duel.Destroy(e:GetHandler(),REASON_EFFECT)>0 and Duel.Damage(tp,2000,REASON_EFFECT)>0 then
		-- 中断当前效果处理链，使后续给与对方伤害的步骤不被视为同时处理，从而避免错过时点。
		Duel.BreakEffect()
		-- 在满足条件后，再对对方造成2000伤害。
		Duel.Damage(1-tp,2000,REASON_EFFECT)
	end
end
