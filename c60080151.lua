--好敵手の記憶
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。自己受到攻击怪兽的攻击力数值的伤害，那只怪兽从游戏中除外。下次的对方回合的结束阶段时，这个效果除外的怪兽在自己场上特殊召唤。
function c60080151.initial_effect(c)
	-- 对方怪兽的攻击宣言时才能发动。自己受到攻击怪兽的攻击力数值的伤害，那只怪兽从游戏中除外。下次的对方回合的结束阶段时，这个效果除外的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c60080151.condition)
	e1:SetTarget(c60080151.target)
	e1:SetOperation(c60080151.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，用于判断是否满足发动时点
function c60080151.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是自己（即对方回合的攻击宣言）
	return tp~=Duel.GetTurnPlayer()
end
-- 定义效果的目标处理函数，检查攻击怪兽是否可除外并设置伤害与除外的操作信息
function c60080151.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前进行攻击宣言的怪兽
	local tc=Duel.GetAttacker()
	if chk==0 then return tc:IsOnField() and tc:IsAbleToRemove() end
	-- 设置操作信息：给与自己相当于该怪兽攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,tc:GetAttack())
	-- 设置操作信息：将该攻击怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
end
-- 定义效果的处理函数，执行伤害、除外以及注册后续特殊召唤效果的操作
function c60080151.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local tc=Duel.GetAttacker()
	if tc and tc:IsAttackable() and tc:IsRelateToBattle() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
		local dam=tc:GetAttack()
		-- 如果成功给与自己伤害且成功将该怪兽表侧表示除外，且该怪兽确实已移动到除外区
		if Duel.Damage(tp,dam,REASON_EFFECT)>0 and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED) then
			-- 下次的对方回合的结束阶段时，这个效果除外的怪兽在自己场上特殊召唤。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCountLimit(1)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCondition(c60080151.spcon)
			e1:SetOperation(c60080151.spop)
			e1:SetLabelObject(tc)
			-- 将当前的回合数保存到效果的Label中，以便后续判断是否为“下次的”回合
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
			-- 将该延迟触发的效果注册给玩家
			Duel.RegisterEffect(e1,tp)
			tc:RegisterFlagEffect(60080151,RESET_EVENT+RESETS_STANDARD,0,0)
		end
	end
end
-- 定义特殊召唤效果的触发条件函数，判断是否为下次的对方回合结束阶段且怪兽状态未改变
function c60080151.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 判断当前回合数是否不等于发动时的回合数（即至少到了下一回合），且当前是对方的回合
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetTurnPlayer()~=tp
		and tc:GetFlagEffect(60080151)~=0 and tc:GetReasonEffect():GetHandler()==e:GetHandler()
end
-- 定义特殊召唤效果的处理函数
function c60080151.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示，显示本卡（好对手的记忆）的卡片发动效果动画
	Duel.Hint(HINT_CARD,0,60080151)
	-- 将被除外的怪兽在自己场上表侧表示特殊召唤
	Duel.SpecialSummon(e:GetLabelObject(),0,tp,tp,false,false,POS_FACEUP)
end
