--エレメント・ドラゴン
-- 效果：
-- ①：场上的怪兽属性让这张卡得到以下效果。
-- ●炎属性：这张卡的攻击力上升500。
-- ●风属性：这张卡战斗破坏对方怪兽时才能发动。这张卡只再1次可以继续攻击。
function c30314994.initial_effect(c)
	-- ●炎属性：这张卡的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetCondition(c30314994.atkcon)
	c:RegisterEffect(e1)
	-- ●风属性：这张卡战斗破坏对方怪兽时才能发动。这张卡只再1次可以继续攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30314994,0))  --"连续攻击"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c30314994.atcon)
	e2:SetOperation(c30314994.atop)
	c:RegisterEffect(e2)
end
-- 过滤条件：判定怪兽为表侧表示且拥有指定属性（炎属性或风属性）。
function c30314994.filter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 攻击力上升效果的发动条件：场上存在至少1只表侧表示的炎属性怪兽。
function c30314994.atkcon(e)
	-- 检查双方场上是否存在至少1只表侧表示且炎属性的怪兽。
	return Duel.IsExistingMatchingCard(c30314994.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_FIRE)
end
-- 连续攻击效果的发动条件：此卡与对方怪兽的战斗破坏事件相关且自身可连续攻击，同时场上存在表侧表示的风属性怪兽。
function c30314994.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认此卡与对方怪兽战斗破坏事件相关，且此卡尚未满足连续攻击次数上限，可以再攻击。
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
		-- 追加确认场上存在表侧表示的风属性怪兽，以满足风属性效果条件。
		and Duel.IsExistingMatchingCard(c30314994.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_WIND)
end
-- 连续攻击效果的处理：为自身赋予1次追加攻击机会。
function c30314994.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该卡可以再进行1次攻击。
	Duel.ChainAttack()
end
