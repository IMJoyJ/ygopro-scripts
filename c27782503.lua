--六武衆－イロウ
-- 效果：
-- 自己场上有「六武众-伊郎」以外的名字带有「六武众」的怪兽存在，这张卡向里侧守备表示怪兽攻击的场合，不进行伤害计算以里侧守备表示的状态把那只怪兽破坏。此外，场上表侧表示存在的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「六武众」的怪兽破坏。
function c27782503.initial_effect(c)
	-- 自己场上有「六武众-伊郎」以外的名字带有「六武众」的怪兽存在，这张卡向里侧守备表示怪兽攻击的场合，不进行伤害计算以里侧守备表示的状态把那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27782503,0))  --"里侧守备的攻击对象怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(c27782503.descon)
	e1:SetTarget(c27782503.destg)
	e1:SetOperation(c27782503.desop)
	c:RegisterEffect(e1)
	-- 此外，场上表侧表示存在的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「六武众」的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c27782503.desreptg)
	e2:SetOperation(c27782503.desrepop)
	c:RegisterEffect(e2)
end
-- 定义筛选函数：检查怪兽是否为表侧表示、是否属于「六武众」字段（0x103d）且不是这张卡自身，用于确认场上是否存在这张卡以外的表侧表示「六武众」怪兽。
function c27782503.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(27782503)
end
-- 第一个效果的发动条件：本卡是攻击宣言的怪兽，攻击对象为里侧守备表示怪兽，且自己场上存在这张卡以外的表侧表示「六武众」怪兽。
function c27782503.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击对象怪兽，用于判定是否为里侧守备表示。
	local d=Duel.GetAttackTarget()
	-- 判定触发条件：效果持有者（这张卡）是攻击怪兽，攻击对象存在且为里侧守备表示。
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsFacedown() and d:IsDefensePos()
		-- 追加条件：自己场上存在至少1张满足筛选条件的卡，即这张卡以外的表侧表示「六武众」怪兽。
		and Duel.IsExistingMatchingCard(c27782503.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 第一个效果的目标处理：确认攻击对象仍与本次战斗关联，并登记效果将破坏的对象为攻击对象（那只里侧守备表示怪兽）。
function c27782503.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：攻击对象必须仍然与本次战斗相关（未被移出战斗或离场），否则效果不适用。
	if chk==0 then return Duel.GetAttackTarget():IsRelateToBattle() end
	-- 将本次连锁的效果操作信息登记为：以效果破坏攻击对象1只，用于后续卡片的响应和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 第一个效果的处理：在伤害计算前，将仍与本次战斗关联的攻击对象（里侧守备表示怪兽）以效果破坏，不进行伤害计算。
function c27782503.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取当前攻击对象，用于效果处理时确认对象。
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 以效果原因破坏攻击对象，实现不进行伤害计算直接破坏里侧守备表示怪兽。
		Duel.Destroy(d,REASON_EFFECT)
	end
end
-- 定义可代替破坏的候选怪兽条件：表侧表示、属于「六武众」字段、能够被该效果破坏，且尚未处于预定破坏或战斗破坏确定状态。
function c27782503.repfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的Target函数：获取效果持有者，并在chk=0时验证发动条件——该卡不处于代替破坏流程、表侧表示在场，且场上存在可代替破坏的「六武众」候选怪兽。
function c27782503.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		-- 并列条件：确认场上存在满足repfilter的候选怪兽（排除自身），同时结束发动条件的判断。
		and Duel.IsExistingMatchingCard(c27782503.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问玩家是否发动代替破坏效果（选择是则进行后续选卡）。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 显示选择提示，提示玩家选择要代替破坏的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 从符合条件的怪兽中选择1张作为代替破坏的对象，并记录在效果中。
		local g=Duel.SelectMatchingCard(tp,c27782503.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的处理：取出选定的代替破坏怪兽，解除其预定破坏标记，并以效果+代替原因将其破坏，从而代替这张卡被破坏。
function c27782503.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以效果破坏原因并附加代替原因（REASON_REPLACE）破坏代替怪兽，使其替代原卡片被破坏。
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
