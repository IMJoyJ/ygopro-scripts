--六武衆－ザンジ
-- 效果：
-- 自己场上有「六武众-斩次」以外的名字带有「六武众」的怪兽存在的场合，这张卡攻击的怪兽在伤害步骤结束时破坏。此外，场上表侧表示存在的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「六武众」的怪兽破坏。
function c95519486.initial_effect(c)
	-- 自己场上有「六武众-斩次」以外的名字带有「六武众」的怪兽存在的场合，这张卡攻击的怪兽在伤害步骤结束时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95519486,0))  --"攻击过的怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c95519486.descon)
	e1:SetTarget(c95519486.destg)
	e1:SetOperation(c95519486.desop)
	c:RegisterEffect(e1)
	-- 此外，场上表侧表示存在的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「六武众」的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c95519486.desreptg)
	e2:SetOperation(c95519486.desrepop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选场上表侧表示、非自身且名字带有「六武众」的怪兽
function c95519486.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(95519486)
end
-- 伤害步骤结束时破坏被攻击怪兽效果的发动条件判断
function c95519486.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否在伤害步骤结束时、自身是攻击方且存在被攻击的怪兽
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler()==Duel.GetAttacker() and Duel.GetAttackTarget()
		-- 检查自己场上是否存在「六武众-斩次」以外的名字带有「六武众」的怪兽
		and Duel.IsExistingMatchingCard(c95519486.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 伤害步骤结束时破坏被攻击怪兽效果的靶向与操作信息设置
function c95519486.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查被攻击的怪兽是否仍存在于战斗关联中
	if chk==0 then return Duel.GetAttackTarget():IsRelateToBattle() end
	-- 设置操作信息：破坏1只被攻击的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 伤害步骤结束时破坏被攻击怪兽效果的具体执行
function c95519486.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被攻击的怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 将该被攻击的怪兽因效果破坏
		Duel.Destroy(d,REASON_EFFECT)
	end
end
-- 过滤函数：筛选场上表侧表示、可被破坏且未处于确定破坏状态的名字带有「六武众」的怪兽
function c95519486.repfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的触发条件与目标选择处理
function c95519486.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		-- 检查自己场上是否存在可用于代替破坏的「六武众」怪兽
		and Duel.IsExistingMatchingCard(c95519486.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问玩家是否使用代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 发送系统提示，要求玩家选择用于代替破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家选择1只符合条件的「六武众」怪兽作为代替破坏的对象
		local g=Duel.SelectMatchingCard(tp,c95519486.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的具体执行
function c95519486.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选作为代替的怪兽破坏，以代替自身被破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
