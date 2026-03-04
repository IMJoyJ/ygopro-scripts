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
	-- 这张卡被选择作为攻击对象时，可以丢弃1张手卡，这张卡不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12423762,1))  --"不被战破"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCost(c12423762.indcost)
	e2:SetOperation(c12423762.indop)
	c:RegisterEffect(e2)
end
-- 判断攻击宣言是否满足条件：攻击怪兽控制者不是自己且没有攻击目标
function c12423762.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击的怪兽
	local at=Duel.GetAttacker()
	-- 返回攻击怪兽控制者不是自己且没有攻击目标
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 设置特殊召唤的处理目标
function c12423762.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤的操作
function c12423762.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡片特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 设置不被战斗破坏效果的处理成本
function c12423762.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手卡作为效果的代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置不被战斗破坏效果的处理操作
function c12423762.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 使该卡在战斗步骤结束时不会被那次战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
	end
end
