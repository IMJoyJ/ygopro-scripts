--ディフェンシブ・タクティクス
-- 效果：
-- 自己场上存在名字带有「剑斗兽」的怪兽场合才能发动，这回合内自己控制的怪兽不会被战斗破坏且自己受到的战斗伤害为0。这张卡回到自己卡组最下面。
function c28877100.initial_effect(c)
	-- 自己场上存在名字带有「剑斗兽」的怪兽场合才能发动，这回合内自己控制的怪兽不会被战斗破坏且自己受到的战斗伤害为0。这张卡回到自己卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(c28877100.condition)
	e1:SetOperation(c28877100.activate)
	c:RegisterEffect(e1)
end
-- 筛选表侧表示且卡名属于「剑斗兽」的怪兽，用于判断场上是否存在满足发动条件的剑斗兽。
function c28877100.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1019)
end
-- 发动条件判定：自己场上存在至少1只表侧表示且名字带有「剑斗兽」的怪兽时条件成立，允许发动。
function c28877100.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足筛选条件的「剑斗兽」怪兽（至少1只）。
	return Duel.IsExistingMatchingCard(c28877100.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果处理：给己方玩家附加战斗伤害为0的防护效果，给自己场上怪兽附加不会被战斗破坏的效果，然后将这张卡送回卡组最下面。
function c28877100.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 自己受到的战斗伤害为0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将战斗伤害为0的效果注册生效，作用于己方玩家。
	Duel.RegisterEffect(e1,tp)
	-- 自己控制的怪兽不会被战斗破坏；这张卡回到自己卡组最下面。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	-- 将‘怪兽不会被战斗破坏’的效果注册生效，作用于己方场上所有怪兽。
	Duel.RegisterEffect(e2,tp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():CancelToGrave()
		-- 将发动后的这张卡以效果形式送回持有者卡组最下面。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
