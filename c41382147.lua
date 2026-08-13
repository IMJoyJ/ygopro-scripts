--星見鳥ラリス
-- 效果：
-- 这张卡的攻击力在伤害步骤时上升战斗的对方怪兽等级×200的数值。这张卡攻击的场合伤害步骤结束时从游戏中除外，下次自己回合的战斗阶段开始时表侧攻击表示回到自己场上。
function c41382147.initial_effect(c)
	-- 这张卡的攻击力在伤害步骤时上升战斗的对方怪兽等级×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c41382147.atkcon)
	e1:SetValue(c41382147.atkval)
	c:RegisterEffect(e1)
	-- 这张卡攻击的场合伤害步骤结束时从游戏中除外，下次自己回合的战斗阶段开始时表侧攻击表示回到自己场上。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41382147,0))  --"除外"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(c41382147.rmcon)
	e2:SetTarget(c41382147.rmtg)
	e2:SetOperation(c41382147.rmop)
	c:RegisterEffect(e2)
end
-- 攻击力上升效果的适用条件：当前阶段为伤害步骤或伤害计算时，且此卡正在进行战斗（作为攻击方或攻击对象），且战斗对象存在。
function c41382147.atkcon(e)
	-- 获取当前游戏阶段，用于判断是否处于伤害步骤或伤害计算时。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		-- 判断此卡是否参与战斗：此卡是攻击者或攻击对象，并且攻击对象不为空，确保效果只在本卡进行战斗时适用。
		and (Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()) and Duel.GetAttackTarget()~=nil
end
-- 计算攻击力上升数值：以与此卡战斗的对方怪兽的当前等级乘以200作为上升值。
function c41382147.atkval(e,c)
	return e:GetHandler():GetBattleTarget():GetLevel()*200
end
-- 除外效果的触发条件：此卡仍与本次战斗相关、是攻击怪兽且处于表侧表示。
function c41382147.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 返回条件判断：此卡与战斗关联、作为攻击怪兽存在且表侧表示，满足时才触发除外。
	return c:IsRelateToBattle() and c==Duel.GetAttacker() and c:IsFaceup()
end
-- 除外效果的发动处理：chk==0时直接允许发动（无需额外条件），同时登记除外操作信息。
function c41382147.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次效果将除外自身1张卡的操作信息，用于让其他卡能正确连锁或响应。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 除外效果的处理：若此卡仍与效果相关且表侧表示，则将其以效果原因暂时除外，并注册一个在下次自己回合战斗阶段开始时返回场上的效果。
function c41382147.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡没有因连锁等原因离场过、仍表侧表示，然后以效果原因暂时除外；只有除外成功才继续注册返回效果。
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)==1 then
		-- 下次自己回合的战斗阶段开始时表侧攻击表示回到自己场上。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(c41382147.retop)
		-- 将返回效果注册为场地持续效果，使其在关联领域内持续监测战斗阶段开始。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 返回效果的处理函数：在满足条件时，将之前暂时除外的这张卡返回场上，实现表侧攻击表示归来。
function c41382147.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为控制者（登记返回效果的玩家），确保只在“下次自己回合”的战斗阶段开始时归还。
	if Duel.GetTurnPlayer()==tp then
		-- 将暂时除外的这张卡返回场上（未指定表示形式时按离场前表侧攻击表示恢复）。
		Duel.ReturnToField(e:GetLabelObject())
	end
end
