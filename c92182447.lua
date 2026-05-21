--時の女神の悪戯
-- 效果：
-- 这张卡不能连锁发动，不能对应这张卡的发动让魔法·陷阱·怪兽的效果发动。
-- ①：自己场上的怪兽只有「女武神」怪兽的场合，自己战斗阶段结束时才能发动。这张卡送去墓地。把回合跳到下次的自己回合的战斗阶段开始时。直到那个回合的结束时自己不能把「时间女神的恶作剧」发动。
function c92182447.initial_effect(c)
	-- 这张卡不能连锁发动，不能对应这张卡的发动让魔法·陷阱·怪兽的效果发动。①：自己场上的怪兽只有「女武神」怪兽的场合，自己战斗阶段结束时才能发动。这张卡送去墓地。把回合跳到下次的自己回合的战斗阶段开始时。直到那个回合的结束时自己不能把「时间女神的恶作剧」发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_END)
	e1:SetCondition(c92182447.condition)
	e1:SetTarget(c92182447.target)
	e1:SetOperation(c92182447.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上的表侧表示「女武神」怪兽
function c92182447.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x122)
end
-- 发动条件判定：自己场上的怪兽只有「女武神」怪兽，且在自己战斗阶段结束时，且当前没有其他连锁
function c92182447.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前连锁数为0（不能连锁发动），且处于自己回合的战斗阶段
	if Duel.GetCurrentChain()>0 or Duel.GetCurrentPhase()~=PHASE_BATTLE or Duel.GetTurnPlayer()~=tp then return false end
	-- 获取自己场上的所有怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return g:GetCount()>0 and g:FilterCount(c92182447.cfilter,nil)==g:GetCount()
end
-- 效果发动时的目标处理，并设置不能对应此卡发动进行连锁的限制
function c92182447.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 限制双方不能对应这张卡的发动把魔法·陷阱·怪兽的效果发动
		Duel.SetChainLimit(aux.FALSE)
	end
end
-- 效果处理核心逻辑：将自身送去墓地，跳过当前回合的剩余阶段，跳过对方的整个回合，并跳过下个自己回合的非战斗阶段，实现“跳到下次自己回合的战斗阶段开始时”
function c92182447.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
	-- 跳过当前回合的战斗阶段
	Duel.SkipPhase(tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1)
	-- 跳过当前回合的主要阶段2
	Duel.SkipPhase(tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
	-- 跳过当前回合的结束阶段
	Duel.SkipPhase(tp,PHASE_END,RESET_PHASE+PHASE_END,1)
	-- 把回合跳到下次的自己回合的战斗阶段开始时。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_TURN)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 注册跳过对方回合的效果
	Duel.RegisterEffect(e1,tp)
	-- 跳过下个自己回合的抽卡阶段
	Duel.SkipPhase(tp,PHASE_DRAW,RESET_PHASE+PHASE_END,2)
	-- 跳过下个自己回合的准备阶段
	Duel.SkipPhase(tp,PHASE_STANDBY,RESET_PHASE+PHASE_END,2)
	-- 跳过下个自己回合的主要阶段1
	Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,2)
	-- 把回合跳到下次的自己回合的战斗阶段开始时。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_EP)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_MAIN1+RESET_SELF_TURN)
	-- 注册在下个自己回合的主要阶段1结束前不能直接进入结束阶段的效果（强制进入战斗阶段）
	Duel.RegisterEffect(e2,tp)
	-- 直到那个回合的结束时自己不能把「时间女神的恶作剧」发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(1,0)
	e3:SetValue(c92182447.aclimit)
	e3:SetReset(RESET_PHASE+PHASE_END,3)
	-- 注册直到下个回合结束时自己不能发动「时间女神的恶作剧」的效果
	Duel.RegisterEffect(e3,tp)
end
-- 限制发动的卡片判定：判定是否为发动卡名为「时间女神的恶作剧」的卡的效果
function c92182447.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(92182447)
end
