--六武衆－ヤリザ
-- 效果：
-- 自己场上有「六武众-枪左」以外的名字带有「六武众」的怪兽存在的场合，这张卡可以直接攻击对方玩家。此外，场上表侧表示存在的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「六武众」的怪兽破坏。
function c69025477.initial_effect(c)
	-- 自己场上有「六武众-枪左」以外的名字带有「六武众」的怪兽存在的场合，这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c69025477.dircon)
	c:RegisterEffect(e1)
	-- 此外，场上表侧表示存在的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「六武众」的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c69025477.desreptg)
	e2:SetOperation(c69025477.desrepop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选场上表侧表示、卡名含有「六武众」且非本卡（六武众-枪左）的怪兽
function c69025477.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(69025477)
end
-- 直接攻击效果的启用条件：自己场上存在其他「六武众」怪兽
function c69025477.dircon(e)
	-- 检查自己场上是否存在至少1只表侧表示的「六武众-枪左」以外的「六武众」怪兽
	return Duel.IsExistingMatchingCard(c69025477.cfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：筛选场上表侧表示、可被效果破坏且未确定被破坏的「六武众」怪兽
function c69025477.repfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的Target函数：在自身即将被破坏时，确认是否存在可代替破坏的怪兽
function c69025477.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		-- 检查自己场上是否存在至少1只符合代替破坏条件的「六武众」怪兽
		and Duel.IsExistingMatchingCard(c69025477.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问玩家是否使用代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 在客户端显示提示信息：请选择要代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家选择1只自己场上表侧表示的「六武众」怪兽作为代替破坏的卡
		local g=Duel.SelectMatchingCard(tp,c69025477.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的Operation函数：执行代替破坏的具体动作
function c69025477.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选中的代替怪兽破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
