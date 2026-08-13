--天威の龍鬼神
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把怪兽的效果发动时才能发动。那只怪兽除外。
-- ②：这张卡的攻击破坏效果怪兽送去墓地的场合发动。这张卡的攻击力上升破坏的怪兽的原本攻击力数值。这次战斗阶段中，这张卡只再1次可以向怪兽攻击。
function c5041348.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要调整1只 + 调整以外的怪兽1只以上作为素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方把怪兽的效果发动时才能发动。那只怪兽除外。
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
-- ①效果的发动条件：本卡不处于战斗破坏确定状态，且对方玩家发动了怪兽效果（rp==1-tp且re为怪兽效果）。
function c5041348.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- ①效果的目标处理：将发动效果的对方怪兽作为对象，检查其仍与效果关联、能够被除外且不在除外区；chk==0时返回是否可发动，之后将该怪兽登记为除外对象。
function c5041348.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return rc:IsRelateToEffect(re) and rc:IsAbleToRemove() and not rc:IsLocation(LOCATION_REMOVED) end
	-- 设置操作信息：将对方发动的怪兽（rc）登记为除外对象，数量为1，用于其他效果（如星尘龙等）的联动判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,0,0)
end
-- ①效果处理：若那只怪兽仍与发动的效果关联，则将其除外。
function c5041348.rmop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) then
		-- 将对象怪兽以表侧表示除外，除外原因为效果。
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的发动条件：本卡是攻击怪兽，战斗破坏效果怪兽并将其送去墓地，且本卡与该战斗仍相关。
function c5041348.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判断攻击者为本卡、满足战斗破坏怪兽送去墓地的通用条件、且被破坏怪兽为效果怪兽，三者同时满足才能发动。
	return Duel.GetAttacker()==c and aux.bdgcon(e,tp,eg,ep,ev,re,r,rp) and bc:IsType(TYPE_EFFECT)
end
-- ②效果的目标处理：发动时无需选择对象，仅确认本卡仍在战斗相关状态；效果处理时将被战斗破坏的效果怪兽设为对象。
function c5041348.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToBattle() end
	local bc=e:GetHandler():GetBattleTarget()
	-- 将被战斗破坏的怪兽设为当前连锁的对象，使后续可通过Duel.GetFirstTarget()获取该怪兽。
	Duel.SetTargetCard(bc)
end
-- ②效果处理：若本卡仍在战斗相关状态且表侧表示，则若被破坏怪兽仍与效果关联，将本卡攻击力上升该怪兽原本攻击力；并在本次战斗阶段内使本卡不能直接攻击，同时追加1次对怪兽的攻击次数。
function c5041348.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取之前记录的被战斗破坏的怪兽，作为攻击力提升的数值依据。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToBattle() and c:IsFaceup() then
		if tc:IsRelateToEffect(e) then
			-- 这张卡的攻击力上升破坏的怪兽的原本攻击力数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(tc:GetBaseAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
		-- 这次战斗阶段中，这张卡只再1次可以向怪兽攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e2)
		-- 这次战斗阶段中，这张卡只再1次可以向怪兽攻击。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EXTRA_ATTACK)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e3)
	end
end
