--ガガガガードナー
-- 效果：
-- 对方怪兽的直接攻击宣言时，这张卡可以从手卡特殊召唤。此外，这张卡被选择作为攻击对象时，可以丢弃1张手卡，这张卡不会被那次战斗破坏。
function c12423762.initial_effect(c)
	-- 对方怪兽的直接攻击宣言时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12423762,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c12423762.spcon)
	e1:SetTarget(c12423762.sptg)
	e1:SetOperation(c12423762.spop)
	c:RegisterEffect(e1)
	-- 此外，这张卡被选择作为攻击对象时，可以丢弃1张手卡，这张卡不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12423762,1))  --"不被战破"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCost(c12423762.indcost)
	e2:SetOperation(c12423762.indop)
	c:RegisterEffect(e2)
end
-- 判断是否满足特殊召唤的发动条件：攻击者为对方怪兽且攻击目标为空（即直接攻击）。
function c12423762.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击宣言的攻击怪兽。
	local at=Duel.GetAttacker()
	-- 检查攻击者是对方怪兽且没有攻击目标，即确认是直接攻击。
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 特殊召唤效果的目标检查与发动合法性判定：在chk==0时确认自己场上存在空位且此卡可被特殊召唤，为后续处理做准备。
function c12423762.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果发动时（chk==0）检查自己主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，宣告本次效果将把此卡（c）特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的处理：若此卡仍与效果关联，则将其特殊召唤。
function c12423762.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到tp玩家场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 丢弃手卡作为效果发动代价：先检查手牌中是否有可丢弃的卡，然后选择1张丢弃。
function c12423762.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查（chk==0）：确认自己手牌中存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌丢弃1张卡作为代价，丢弃理由为代价与丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果处理：若此卡仍与效果关联，则赋予它“不会被那次战斗破坏”的保护，持续到伤害阶段结束。
function c12423762.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这张卡不会被那次战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
	end
end
