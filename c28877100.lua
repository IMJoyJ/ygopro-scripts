--ディフェンシブ・タクティクス
-- 效果：
-- 自己场上存在名字带有「剑斗兽」的怪兽场合才能发动，这回合内自己控制的怪兽不会被战斗破坏且自己受到的战斗伤害为0。这张卡回到自己卡组最下面。
function c28877100.initial_effect(c)
	-- 效果原文：自己场上存在名字带有「剑斗兽」的怪兽场合才能发动，这回合内自己控制的怪兽不会被战斗破坏且自己受到的战斗伤害为0。这张卡回到自己卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(c28877100.condition)
	e1:SetOperation(c28877100.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查场上是否存在表侧表示且名字带有「剑斗兽」的怪兽
function c28877100.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1019)
end
-- 条件函数，判断是否满足发动条件：自己场上存在名字带有「剑斗兽」的怪兽
function c28877100.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以自己为玩家，在自己的主要怪兽区是否存在至少1张满足filter条件的卡
	return Duel.IsExistingMatchingCard(c28877100.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动效果函数，设置永续效果使自己控制的怪兽不会被战斗破坏且自己受到的战斗伤害为0，并将此卡送回卡组底端
function c28877100.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文：这回合内自己控制的怪兽不会被战斗破坏
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家tp，使其生效
	Duel.RegisterEffect(e1,tp)
	-- 效果原文：这回合内自己控制的怪兽不会被战斗破坏且自己受到的战斗伤害为0
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	-- 将效果e2注册给玩家tp，使其生效
	Duel.RegisterEffect(e2,tp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():CancelToGrave()
		-- 将此卡以效果为原因送回自己卡组底端
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
