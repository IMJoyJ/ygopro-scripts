--リグラス・リーパー
-- 效果：
-- ①：这张卡反转的场合发动。双方玩家各自选自己1张手卡丢弃。
-- ②：这张卡被和怪兽的战斗破坏的场合发动。那只怪兽的攻击力·守备力下降500。
function c39180960.initial_effect(c)
	-- ①：这张卡反转的场合发动。双方玩家各自选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39180960,0))  --"丢弃手牌"
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c39180960.target)
	e1:SetOperation(c39180960.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被和怪兽的战斗破坏的场合发动。那只怪兽的攻击力·守备力下降500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39180960,1))  --"攻守下降500"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetOperation(c39180960.desop)
	c:RegisterEffect(e2)
end
-- 设置效果目标为丢弃手牌
function c39180960.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为丢弃手牌效果
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,PLAYER_ALL,1)
end
-- 执行丢弃手牌效果，双方各丢弃一张手牌
function c39180960.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择一方玩家的一张手牌
	local g1=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	-- 提示对方玩家选择丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择对方玩家的一张手牌
	local g2=Duel.SelectMatchingCard(1-tp,aux.TRUE,1-tp,LOCATION_HAND,0,1,1,nil)
	g1:Merge(g2)
	-- 将选择的卡片送去墓地
	Duel.SendtoGrave(g1,REASON_DISCARD+REASON_EFFECT)
end
-- 设置战斗破坏时的攻击力守备力下降效果
function c39180960.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 若当前怪兽为攻击怪兽，则获取攻击目标怪兽
	if c==tc then tc=Duel.GetAttackTarget() end
	if not tc:IsRelateToBattle() then return end
	-- 为攻击怪兽设置攻击力下降500的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-500)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	tc:RegisterEffect(e2)
end
