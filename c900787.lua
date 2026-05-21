--ドラグニティナイト－ゲイボルグ
-- 效果：
-- 龙族调整＋调整以外的鸟兽族怪兽1只以上
-- ①：这张卡进行战斗的从伤害步骤开始时到伤害计算前1次，从自己墓地把1只鸟兽族怪兽除外才能发动。这张卡的攻击力直到回合结束时上升除外的那只怪兽的原本攻击力数值。
function c900787.initial_effect(c)
	-- 添加同调召唤手续：龙族调整＋调整以外的鸟兽族怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),aux.NonTuner(Card.IsRace,RACE_WINDBEAST),1)
	c:EnableReviveLimit()
	-- ①：这张卡进行战斗的从伤害步骤开始时到伤害计算前1次，从自己墓地把1只鸟兽族怪兽除外才能发动。这张卡的攻击力直到回合结束时上升除外的那只怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(900787,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c900787.condition)
	e1:SetCost(c900787.cost)
	e1:SetOperation(c900787.operation)
	c:RegisterEffect(e1)
end
-- 判断发动条件：当前处于伤害步骤，且这张卡进行战斗，且在伤害计算前
function c900787.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断当前是否为伤害步骤，且这张卡是攻击怪兽或被攻击怪兽（即进行战斗）
	return ph==PHASE_DAMAGE and (c==Duel.GetAttacker() or c==Duel.GetAttackTarget())
		-- 判断是否尚未进行伤害计算
		and not Duel.IsDamageCalculated()
end
-- 过滤条件：墓地的鸟兽族怪兽且可以作为代价除外
function c900787.cfilter(c)
	return c:IsRace(RACE_WINDBEAST) and c:IsAbleToRemoveAsCost()
end
-- 判断发动代价：检查此卡在此次战斗中是否未发动过该效果，以及自己墓地是否存在可除外的鸟兽族怪兽
function c900787.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(900787)==0
		-- 检查自己墓地是否存在至少1只满足过滤条件的卡
		and Duel.IsExistingMatchingCard(c900787.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c900787.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetAttack())
	-- 将选中的卡表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:GetHandler():RegisterFlagEffect(900787,RESET_PHASE+PHASE_DAMAGE,0,1)
end
-- 效果处理：若此卡在场上表侧表示，则使其攻击力上升除外怪兽的原本攻击力数值，直到回合结束
function c900787.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升除外的那只怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
