--キラー・ラブカ
-- 效果：
-- 自己场上表侧表示存在的鱼族·海龙族·水族怪兽被选择作为攻击对象时，把墓地存在的这张卡从游戏中除外发动。把1只攻击怪兽的攻击无效，那个攻击力直到下次的自己的结束阶段时下降500。「杀人皱鳃鲨」的效果1回合只能使用1次。
function c93830681.initial_effect(c)
	-- 自己场上表侧表示存在的鱼族·海龙族·水族怪兽被选择作为攻击对象时，把墓地存在的这张卡从游戏中除外发动。把1只攻击怪兽的攻击无效，那个攻击力直到下次的自己的结束阶段时下降500。「杀人皱鳃鲨」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93830681,0))  --"攻击无效"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,93830681)
	e1:SetCondition(c93830681.condition)
	-- 设置发动代价为将墓地的这张卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c93830681.target)
	e1:SetOperation(c93830681.operation)
	c:RegisterEffect(e1)
end
-- 验证发动条件：被攻击的怪兽必须是自己场上表侧表示的鱼族、海龙族或水族怪兽
function c93830681.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择作为攻击对象的怪兽
	local at=Duel.GetAttackTarget()
	return at and at:IsControler(tp) and at:IsFaceup() and at:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA)
end
-- 设置效果目标：获取攻击怪兽并将其作为效果的对象
function c93830681.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取发起攻击的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设为效果的目标
	Duel.SetTargetCard(tg)
end
-- 效果处理：无效攻击怪兽的攻击，并使其攻击力直到下次自己的结束阶段时下降500
function c93830681.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发起攻击的怪兽
	local tc=Duel.GetAttacker()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 无效此次攻击
		Duel.NegateAttack()
		-- 那个攻击力直到下次的自己的结束阶段时下降500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
	end
end
