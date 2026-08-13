--妖仙獣 閻魔巳裂
-- 效果：
-- ①：这张卡和风属性以外的表侧表示怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。
-- ②：这张卡灵摆召唤成功时，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ③：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡。
function c39853199.initial_effect(c)
	-- ①：这张卡和风属性以外的表侧表示怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39853199,0))  --"破坏怪兽"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(c39853199.destg1)
	e1:SetOperation(c39853199.desop1)
	c:RegisterEffect(e1)
	-- ②：这张卡灵摆召唤成功时，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39853199,1))  --"破坏1张卡"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c39853199.descon2)
	e2:SetTarget(c39853199.destg2)
	e2:SetOperation(c39853199.desop2)
	c:RegisterEffect(e2)
	-- ③：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39853199,2))  --"返回手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCondition(c39853199.retcon)
	e3:SetTarget(c39853199.rettg)
	e3:SetOperation(c39853199.retop)
	c:RegisterEffect(e3)
	if not c39853199.global_check then
		c39853199.global_check=true
		-- 这张卡特殊召唤的回合的结束阶段发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetLabel(39853199)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置特殊召唤成功时的处理函数为aux.sumreg，用于记录怪兽在本回合被特殊召唤过，供③的结束阶段回手效果判断“特殊召唤的回合”。
		ge1:SetOperation(aux.sumreg)
		-- 将全局辅助效果注册到决斗中，使所有特殊召唤成功时都会触发该效果，从而为③的回手效果记录特殊召唤状态。
		Duel.RegisterEffect(ge1,0)
	end
end
-- ①效果的发动条件与目标设定：当此卡与风属性以外的表侧表示怪兽进行战斗的伤害步骤开始时，检查战斗对象合法后，将其设定为将被破坏的卡。
function c39853199.destg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsFaceup() and tc:IsNonAttribute(ATTRIBUTE_WIND) end
	-- 将本次连锁的操作信息设为“破坏”类别，目标为tc，数量1，用于其他卡响应时获取信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- ①的效果处理：在伤害步骤开始时，若战斗对象仍与本次战斗相关（未离开战场），将其破坏。
function c39853199.desop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc:IsRelateToBattle() then
		-- 以卡片效果将tc破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②的发动条件：这张卡是灵摆召唤成功的场合，该效果才能发动。
function c39853199.descon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- ②的取对象发动处理：在灵摆召唤成功时，检查对方场上是否有可选择的卡；若有，让玩家从对方场上选择1张卡作为效果对象，并设定破坏操作信息。
function c39853199.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 发动效果的合法性检查：对方场上是否存在至少1张卡可以作为效果对象（任意卡）。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示选择卡片的提示信息，内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家tp从对方场上选择1张卡，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为破坏类别，对象为选出的卡g，数量1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②的效果处理：取得效果对象，若该对象仍与效果相关（未被无效或离场），将其破坏。
function c39853199.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中效果选择的第一张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果将对象卡tc破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ③的发动条件：通过标志位确认这张卡在本回合特殊召唤过，满足条件则在结束阶段发动。
function c39853199.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(39853199)~=0
end
-- ③的发动处理：直接以这张卡自身为对象，设定将其送回手卡的操作信息；由于是必发效果，choosing时直接返回true。
function c39853199.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为返回手卡类别，对象为这张卡自身，数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ③的效果处理：若这张卡仍与效果相关，则将其送回持有者手卡。
function c39853199.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以效果将这张卡返回其持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
