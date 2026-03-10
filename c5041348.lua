--天威の龍鬼神
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把怪兽的效果发动时才能发动。那只怪兽除外。
-- ②：这张卡的攻击破坏效果怪兽送去墓地的场合发动。这张卡的攻击力上升破坏的怪兽的原本攻击力数值。这次战斗阶段中，这张卡只再1次可以向怪兽攻击。
function c5041348.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：对方把怪兽的效果发动时才能发动。那只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5041348,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,5041348)
	e1:SetCondition(c5041348.rmcon)
	e1:SetTarget(c5041348.rmtg)
	e1:SetOperation(c5041348.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击破坏效果怪兽送去墓地的场合发动。这张卡的攻击力上升破坏的怪兽的原本攻击力数值。这次战斗阶段中，这张卡只再1次可以向怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5041348,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCountLimit(1,5041349)
	e2:SetCondition(c5041348.atkcon)
	e2:SetTarget(c5041348.atktg)
	e2:SetOperation(c5041348.atkop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：不是战斗破坏状态且是对方发动怪兽效果
function c5041348.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 设置连锁处理目标为对方发动的效果怪兽，并确认其可除外
function c5041348.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return rc:IsRelateToEffect(re) and rc:IsAbleToRemove() and not rc:IsLocation(LOCATION_REMOVED) end
	-- 设置操作信息，表示将要除外目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,0,0)
end
-- 效果处理函数：将对方发动的怪兽效果从游戏中除外
function c5041348.rmop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) then
		-- 执行除外操作，将目标怪兽以正面表示形式除外
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 攻击破坏效果触发条件判断：确认是自己为攻击怪兽且被战斗破坏的怪兽为效果怪兽
function c5041348.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 返回是否满足攻击破坏效果触发条件，即为攻击怪兽、被战斗破坏且为效果怪兽
	return Duel.GetAttacker()==c and aux.bdgcon(e,tp,eg,ep,ev,re,r,rp) and bc:IsType(TYPE_EFFECT)
end
-- 设置攻击破坏效果的目标为被战斗破坏的怪兽
function c5041348.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToBattle() end
	local bc=e:GetHandler():GetBattleTarget()
	-- 设置当前处理的连锁目标为被战斗破坏的怪兽
	Duel.SetTargetCard(bc)
end
-- 攻击破坏效果处理函数：提升攻击力并获得一次额外攻击机会，同时不能直接攻击
function c5041348.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToBattle() and c:IsFaceup() then
		if tc:IsRelateToEffect(e) then
			-- 使自身攻击力增加被破坏怪兽的原本攻击力数值
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(tc:GetBaseAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
		-- 使自身在本次战斗阶段中不能进行直接攻击
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e2)
		-- 使自身在本次战斗阶段中可以再进行一次攻击
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EXTRA_ATTACK)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e3)
	end
end
