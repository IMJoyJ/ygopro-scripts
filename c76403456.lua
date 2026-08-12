--パワー・ウォール
-- 效果：
-- ①：对方怪兽的攻击要让自己受到战斗伤害的伤害计算时才能发动。直到那次战斗发生的对自己的战斗伤害变成0为止，作为受到的伤害的代替而把每500伤害1张卡从自己卡组上面送去墓地。
function c76403456.initial_effect(c)
	-- ①：对方怪兽的攻击要让自己受到战斗伤害的伤害计算时才能发动。直到那次战斗发生的对自己的战斗伤害变成0为止，作为受到的伤害的代替而把每500伤害1张卡从自己卡组上面送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c76403456.condition)
	e1:SetTarget(c76403456.target)
	e1:SetOperation(c76403456.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：对方怪兽攻击导致自己受到战斗伤害的伤害计算时
function c76403456.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动攻击的怪兽是否由对方玩家控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 发动检查：计算需要送墓的卡片数量，并确认玩家是否能执行该操作
function c76403456.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算本次战斗伤害对应的送墓卡片数量（每500伤害1张，向上取整）
	local val=math.ceil(Duel.GetBattleDamage(tp)/500)
	-- 若为发动检查，则确认需要送墓的卡片数量大于0且玩家卡组有足够数量的卡可以送去墓地
	if chk==0 then return val>0 and Duel.IsPlayerCanDiscardDeck(tp,val)
		-- 且玩家当前未受到“不会受到战斗伤害”效果的影响
		and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_AVOID_BATTLE_DAMAGE) end
	-- 设置效果处理的操作信息为包含从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,0)
end
-- 效果处理：将卡组顶端的卡送去墓地，并使本次战斗伤害变为0
function c76403456.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算本次战斗伤害对应的送墓卡片数量（每500伤害1张，向上取整）
	local val=math.ceil(Duel.GetBattleDamage(tp)/500)
	-- 将对应数量的卡片从卡组最上方送去墓地
	Duel.DiscardDeck(tp,val,REASON_EFFECT)
	-- 获取刚刚因效果送去墓地的卡片组
	local og=Duel.GetOperatedGroup()
	if og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<val then return end
	-- 直到那次战斗发生的对自己的战斗伤害变成0为止
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 向玩家注册该效果，使其在本次伤害步骤内免受战斗伤害
	Duel.RegisterEffect(e1,tp)
end
