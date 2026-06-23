--門前払い
-- 效果：
-- ①：这张卡已在魔法与陷阱区域存在的状态，怪兽给与玩家战斗伤害的场合发动。那只怪兽回到持有者手卡。
function c20374520.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：这张卡已在魔法与陷阱区域存在的状态，怪兽给与玩家战斗伤害的场合发动。那只怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20374520,0))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c20374520.condition)
	e2:SetTarget(c20374520.target)
	e2:SetOperation(c20374520.operation)
	c:RegisterEffect(e2)
end
-- 效果发动时，检查此卡是否处于效果适用状态
function c20374520.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 设置效果处理目标为造成战斗伤害的怪兽，并设置操作信息为回手牌效果
function c20374520.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将造成战斗伤害的怪兽设置为效果处理对象
	Duel.SetTargetCard(eg)
	-- 设置连锁操作信息为回手牌效果，目标为造成战斗伤害的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,1,0,0)
end
-- 效果处理函数，检索造成战斗伤害的怪兽并将其送回手牌
function c20374520.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) then
		-- 将怪兽以效果原因送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
