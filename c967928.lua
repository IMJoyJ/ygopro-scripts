--罰ゲーム！
-- 效果：
-- 对方的手卡4张的时候，选择下面1个效果发动。
-- ●对方下个抽卡阶段不能抽卡。
-- ●这个回合对方不能发动魔法·陷阱卡。
function c967928.initial_effect(c)
	-- 对方的手卡4张的时候，选择下面1个效果发动。●对方下个抽卡阶段不能抽卡。●这个回合对方不能发动魔法·陷阱卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMING_TOHAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c967928.condition)
	e1:SetTarget(c967928.target)
	e1:SetOperation(c967928.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数
function c967928.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方手卡数量是否等于4张
	return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)==4
end
-- 定义效果发动时的目标选择与处理准备函数
function c967928.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 让玩家选择其中一个效果发动
	local op=Duel.SelectOption(tp,aux.Stringid(967928,0),aux.Stringid(967928,1))  --"对方下个抽卡阶段不能抽卡/这个回合对方不能发动魔法·陷阱卡"
	e:SetLabel(op)
	-- 设置效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
end
-- 定义效果处理函数
function c967928.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家（即对方）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if e:GetLabel()==0 then
		-- ●对方下个抽卡阶段不能抽卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetCode(EFFECT_CANNOT_DRAW)
		-- 判断当前是否已经是对方回合的抽卡阶段（用于处理“下个抽卡阶段”的边界情况）
		if Duel.GetTurnPlayer()==p and Duel.GetCurrentPhase()==PHASE_DRAW then
			e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,2)
			-- 将当前回合数记录在效果的Label中，以便在条件函数中避开当前回合
			e1:SetLabel(Duel.GetTurnCount())
		else
			e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN)
			e1:SetLabel(0)
		end
		e1:SetCondition(c967928.skipcon)
		-- 给目标玩家注册无法抽卡的效果
		Duel.RegisterEffect(e1,p)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DRAW_COUNT)
		e2:SetValue(0)
		-- 给目标玩家注册抽卡阶段抽卡数变为0的效果
		Duel.RegisterEffect(e2,p)
	else
		-- ●这个回合对方不能发动魔法·陷阱卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(c967928.aclimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 给目标玩家注册无法发动魔法·陷阱卡的效果
		Duel.RegisterEffect(e1,p)
	end
end
-- 定义跳过抽卡阶段的条件函数
function c967928.skipcon(e)
	-- 判断当前回合不等于记录的回合（即避开当前回合），且当前处于抽卡阶段
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetCurrentPhase()==PHASE_DRAW
end
-- 定义限制发动的卡片类型判定函数（限制魔法·陷阱卡的发动）
function c967928.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
