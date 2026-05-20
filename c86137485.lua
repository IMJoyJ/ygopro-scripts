--ヘル・ツイン・コップ
-- 效果：
-- 恶魔族调整＋调整以外的怪兽1只以上
-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。这张卡直到战斗阶段结束时攻击力上升800，只再1次可以继续攻击。
function c86137485.initial_effect(c)
	-- 设置同调召唤手续：恶魔族调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。这张卡直到战斗阶段结束时攻击力上升800，只再1次可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86137485,0))  --"连续攻击"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c86137485.atcon1)
	e1:SetOperation(c86137485.atop1)
	c:RegisterEffect(e1)
	-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。这张卡直到战斗阶段结束时攻击力上升800
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86137485,0))  --"连续攻击"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c86137485.atcon2)
	e2:SetOperation(c86137485.atop2)
	c:RegisterEffect(e2)
end
-- 自己回合战斗破坏对方怪兽送去墓地时，且该卡可以追加攻击时的发动条件判定
function c86137485.atcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判定当前是否为自己回合，且被战斗破坏的怪兽已送去墓地
	return Duel.GetTurnPlayer()==tp and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
		and c:IsChainAttackable() and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- 自己回合战斗破坏对方怪兽送去墓地时的效果处理：攻击力上升800并可以再进行1次攻击
function c86137485.atop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 这张卡直到战斗阶段结束时攻击力上升800
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_BATTLE)
	c:RegisterEffect(e1)
	-- 使这张卡可以再进行1次攻击
	Duel.ChainAttack()
end
-- 对方回合战斗破坏对方怪兽送去墓地时的发动条件判定
function c86137485.atcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判定当前是否为对方回合，且这张卡仍存在于场上并参与了战斗
	return Duel.GetTurnPlayer()~=tp and c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE)
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 对方回合战斗破坏对方怪兽送去墓地时的效果处理：攻击力上升800
function c86137485.atop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 这张卡直到战斗阶段结束时攻击力上升800
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_BATTLE)
	c:RegisterEffect(e1)
end
