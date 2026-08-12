--絶望神アンチホープ
-- 效果：
-- 这张卡不能通常召唤。把自己场上4只表侧表示的1星怪兽送去墓地的场合才能从手卡·墓地特殊召唤。
-- ①：只要这张卡在怪兽区域存在，其他的自己怪兽不能攻击。
-- ②：这张卡进行战斗的战斗步骤中1次，把自己墓地1只1星怪兽除外才能发动。这张卡直到那次伤害步骤结束时不受其他卡的效果影响，不会被战斗破坏。
function c52085072.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上4只表侧表示的1星怪兽送去墓地的场合才能从手卡·墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCondition(c52085072.spcon)
	e2:SetTarget(c52085072.sptg)
	e2:SetOperation(c52085072.spop)
	c:RegisterEffect(e2)
	-- 只要这张卡在怪兽区域存在，其他的自己怪兽不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c52085072.antarget)
	c:RegisterEffect(e3)
	-- 这张卡进行战斗的战斗步骤中1次，把自己墓地1只1星怪兽除外才能发动。这张卡直到那次伤害步骤结束时不受其他卡的效果影响，不会被战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(52085072,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(TIMING_BATTLE_PHASE)
	e4:SetCondition(c52085072.btcon)
	e4:SetCost(c52085072.btcost)
	e4:SetOperation(c52085072.btop)
	c:RegisterEffect(e4)
end
-- 检索满足条件的场上表侧表示1星怪兽（可送去墓地作为特殊召唤的代价）
function c52085072.spcfilter(c)
	return c:IsFaceup() and c:IsLevel(1) and c:IsAbleToGraveAsCost()
end
-- 检查玩家场上是否有4只满足条件的怪兽以供特殊召唤
function c52085072.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家场上所有满足条件的怪兽组
	local sg=Duel.GetMatchingGroup(c52085072.spcfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查该组中是否存在恰好4只且能放入怪兽区的组合
	return sg:CheckSubGroup(aux.mzctcheck,4,4,tp)
end
-- 选择并标记要送去墓地的4只怪兽
function c52085072.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上所有满足条件的怪兽组
	local sg=Duel.GetMatchingGroup(c52085072.spcfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从满足条件的怪兽中选择恰好4只并检查是否能放入怪兽区
	local g=sg:SelectSubGroup(tp,aux.mzctcheck,true,4,4,tp)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else return false end
end
-- 将标记的怪兽组送去墓地作为特殊召唤的代价
function c52085072.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的怪兽送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断目标怪兽是否不是该卡本身
function c52085072.antarget(e,c)
	return c~=e:GetHandler()
end
-- 判断当前阶段是否为战斗阶段且该卡正在参与攻击或被攻击
function c52085072.btcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为战斗阶段开始到战斗结束之间
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 判断该卡是否为攻击怪兽或被攻击怪兽
		and (Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler())
end
-- 检索满足条件的墓地1星怪兽（可除外作为发动效果的代价）
function c52085072.btcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:GetLevel()==1 and c:IsAbleToRemoveAsCost()
end
-- 检查是否满足发动效果的条件（有1只1星怪兽可除外且未发动过此效果）
function c52085072.btcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家墓地是否存在至少1只1星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c52085072.btcfilter,tp,LOCATION_GRAVE,0,1,nil)
		and e:GetHandler():GetFlagEffect(52085072)==0 end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从玩家墓地中选择1只1星怪兽除外
	local g=Duel.SelectMatchingCard(tp,c52085072.btcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将指定的怪兽除外作为发动效果的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:GetHandler():RegisterFlagEffect(52085072,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
end
-- 使该卡在本次战斗中不受其他卡的效果影响且不会被战斗破坏
function c52085072.btop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 使该卡直到那次伤害步骤结束时不受其他卡的效果影响
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c52085072.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		c:RegisterEffect(e2)
	end
end
-- 判断效果来源是否不是该卡本身
function c52085072.efilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end
