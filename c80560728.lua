--ディメンション・ミラージュ
-- 效果：
-- 以对方场上1只表侧攻击表示怪兽为对象才能把这张卡发动。
-- ①：作为对象的怪兽的攻击没让攻击对象怪兽被破坏的伤害步骤结束时，把自己墓地1只怪兽除外才能把这个效果发动。作为对象的怪兽变成再1次可以攻击，必须继续攻击。
-- ②：作为对象的怪兽从场上离开的场合这张卡破坏。
function c80560728.initial_effect(c)
	-- 以对方场上1只表侧攻击表示怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c80560728.target)
	c:RegisterEffect(e1)
	-- 以对方场上1只表侧攻击表示怪兽为对象才能把这张卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetCondition(c80560728.tgcon)
	e2:SetOperation(c80560728.tgop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ①：作为对象的怪兽的攻击没让攻击对象怪兽被破坏的伤害步骤结束时，把自己墓地1只怪兽除外才能把这个效果发动。作为对象的怪兽变成再1次可以攻击，必须继续攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(80560728,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c80560728.atcon)
	e3:SetCost(c80560728.atcost)
	e3:SetOperation(c80560728.atop)
	c:RegisterEffect(e3)
	-- ②：作为对象的怪兽从场上离开的场合这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c80560728.descon)
	e4:SetOperation(c80560728.desop)
	c:RegisterEffect(e4)
end
-- 过滤条件：判断卡片是否为表侧攻击表示
function c80560728.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
-- 卡片发动时的效果处理：选择对方场上1只表侧攻击表示怪兽作为对象
function c80560728.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c80560728.filter(chkc) end
	-- 判断对方场上是否存在符合条件的表侧攻击表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c80560728.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧攻击表示怪兽作为效果对象
	Duel.SelectTarget(tp,c80560728.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 判断当前处理完毕的连锁是否为这张卡的发动
function c80560728.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
-- 在卡片发动成功后，为这张卡建立与对象怪兽的持续对象关系
function c80560728.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):GetFirst()
	if c:IsRelateToEffect(re) and tc:IsFaceup() and tc:IsRelateToEffect(re) then
		c:SetCardTarget(tc)
	end
end
-- 判断是否为作为对象的怪兽进行攻击且攻击对象怪兽未被破坏的伤害步骤结束时
function c80560728.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	-- 获取本次战斗的攻击怪兽
	local at=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	return at==tc and d and d:IsRelateToBattle()
end
-- 过滤条件：判断自己墓地的卡是否为可以除外的怪兽
function c80560728.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动代价：把自己墓地1只怪兽除外
function c80560728.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己墓地是否存在可以除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c80560728.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1只怪兽
	local g=Duel.SelectMatchingCard(tp,c80560728.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的墓地怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理：使作为对象的怪兽必须继续攻击，并可以再进行1次攻击
function c80560728.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if tc:IsRelateToBattle() then
		-- 必须继续攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_FIRST_ATTACK)
		tc:RegisterEffect(e2)
		-- 使该怪兽可以再进行1次攻击
		Duel.ChainAttack()
	end
end
-- 判断作为对象的怪兽是否从场上离开
function c80560728.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 效果处理：将这张卡破坏
function c80560728.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将这张卡自身破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
