--EMブランコブラ
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，自己怪兽给与对方战斗伤害时才能发动。对方卡组最上面的卡送去墓地。
-- 【怪兽效果】
-- ①：这张卡可以直接攻击。
-- ②：这张卡攻击的场合，战斗阶段结束时变成守备表示。
function c93892436.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤、灵摆卡的发动等）。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己怪兽给与对方战斗伤害时才能发动。对方卡组最上面的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93892436,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c93892436.ddescon)
	e1:SetTarget(c93892436.ddestg)
	e1:SetOperation(c93892436.ddesop)
	c:RegisterEffect(e1)
	-- ①：这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	-- ②：这张卡攻击的场合，战斗阶段结束时变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c93892436.poscon)
	e3:SetOperation(c93892436.posop)
	c:RegisterEffect(e3)
end
-- 检查造成战斗伤害的怪兽是否由自己控制，且受到伤害的玩家为对方。
function c93892436.ddescon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst():IsControler(tp)
end
-- 灵摆效果的发动条件检查与操作信息设置。
function c93892436.ddestg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方是否可以从卡组顶端将1张卡送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,1) end
	-- 设置操作信息，表示该效果包含将对方卡组顶端的1张卡送去墓地的处理。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,1-tp,1)
end
-- 灵摆效果的实际处理函数。
function c93892436.ddesop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将对方卡组最上面的1张卡送去墓地。
	Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
end
-- 检查这张卡在当前回合是否进行过攻击。
function c93892436.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 战斗阶段结束时的效果处理：若这张卡处于攻击表示，则将其变为表侧守备表示。
function c93892436.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡改变为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
