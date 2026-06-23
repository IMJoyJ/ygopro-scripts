--グレイ・ウイング
-- 效果：
-- 在主要阶段一丢弃1张手卡。这张卡在那个回合的战斗阶段中可以2次攻击。
function c29618570.initial_effect(c)
	-- 创建一个永续效果，使灰翼龙在主要阶段一丢弃1张手卡后可以在该回合战斗阶段中进行2次攻击
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29618570,0))  --"两次攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c29618570.atkcon)
	e1:SetCost(c29618570.atkcost)
	e1:SetTarget(c29618570.atktg)
	e1:SetOperation(c29618570.atkop)
	c:RegisterEffect(e1)
end
-- 检查回合玩家能否进入战斗阶段
function c29618570.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若能进入战斗阶段则效果可用
	return Duel.IsAbleToEnterBP()
end
-- 检查玩家是否能丢弃1张手卡作为效果的代价
function c29618570.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手牌作为效果的代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检查该卡是否未受到额外攻击效果影响
function c29618570.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0 end
end
-- 若该卡在场且表侧表示，则获得额外1次攻击机会
function c29618570.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 使该卡获得额外1次攻击次数
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
