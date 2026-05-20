--ウェザー・レポート
-- 效果：
-- 反转：对方场上表侧表示存在的「光之护封剑」全部破坏。破坏成功的场合，下次的自己的战斗阶段可以进行2次。
function c72053645.initial_effect(c)
	-- 反转：对方场上表侧表示存在的「光之护封剑」全部破坏。破坏成功的场合，下次的自己的战斗阶段可以进行2次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72053645,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c72053645.target)
	e1:SetOperation(c72053645.operation)
	c:RegisterEffect(e1)
end
-- 过滤对方场上表侧表示的「光之护封剑」
function c72053645.filter(c)
	return c:IsFaceup() and c:IsCode(72302403)
end
-- 反转效果的发动准备，由于是强制发动的反转效果，直接返回true，并设置破坏的操作信息
function c72053645.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有表侧表示的「光之护封剑」
	local g=Duel.GetMatchingGroup(c72053645.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置破坏的操作信息，包含要破坏的卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 反转效果的处理，破坏对方场上表侧表示的「光之护封剑」，若破坏成功，则为自己注册一个在下次自己的战斗阶段可以进行2次战斗阶段的效果
function c72053645.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新获取对方场上表侧表示的「光之护封剑」卡片组
	local g=Duel.GetMatchingGroup(c72053645.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 破坏获取到的卡片组，并判断是否成功破坏了至少1张卡
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 下次的自己的战斗阶段可以进行2次。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_BP_TWICE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		-- 判断当前是否在自己的战斗阶段中触发了该效果
		if Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) then
			-- 将当前回合数记录在效果的Label中，用于后续判断是否是“下次”的战斗阶段
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(c72053645.bpcon)
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
		end
		-- 将允许进行2次战斗阶段的效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义效果的生效条件函数，用于确保“进行2次战斗阶段”的效果不会在发动该效果的当前回合的战斗阶段立即生效
function c72053645.bpcon(e)
	-- 判断当前回合数是否不等于记录的回合数，用于过滤掉当前回合
	return Duel.GetTurnCount()~=e:GetLabel()
end
