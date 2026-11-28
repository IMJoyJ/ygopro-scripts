--六武衆－カモン
-- 效果：
-- 自己场上有「六武众-火门」以外的名字带有「六武众」的怪兽存在的场合，1回合1次，可以选择场上表侧表示存在的1张魔法·陷阱卡破坏。这个效果发动的回合，这张卡不能攻击宣言。此外，场上表侧表示存在的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「六武众」的怪兽破坏。
function c90397998.initial_effect(c)
	-- 自己场上有「六武众-火门」以外的名字带有「六武众」的怪兽存在的场合，1回合1次，可以选择场上表侧表示存在的1张魔法·陷阱卡破坏。这个效果发动的回合，这张卡不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90397998,0))  --"表侧的1张魔法·陷阱卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c90397998.descon)
	e1:SetCost(c90397998.descost)
	e1:SetTarget(c90397998.destg)
	e1:SetOperation(c90397998.desop)
	c:RegisterEffect(e1)
	-- 此外，场上表侧表示存在的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「六武众」的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c90397998.desreptg)
	e2:SetOperation(c90397998.desrepop)
	c:RegisterEffect(e2)
end
-- 发动及处理条件过滤函数：筛选表侧表示且卡名不是「六武众-火门」的「六武众」怪兽
function c90397998.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(90397998)
end
-- 破坏魔陷发动条件：检查自己场上是否存在其他表侧「六武众」怪兽
function c90397998.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否存在至少1只「六武众-火门」以外的表侧「六武众」怪兽
	return Duel.IsExistingMatchingCard(c90397998.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 破坏效果代价处理：确认本回合未攻击宣言，并为自身施加本回合不能攻击宣言的誓约限制
function c90397998.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合，这张卡不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e:GetHandler():RegisterEffect(e1)
end
-- 破坏对象过滤函数：筛选表侧表示的魔法·陷阱卡
function c90397998.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果目标设定：取双方场上表侧表示的1张魔法·陷阱卡为对象并登记破坏操作信息
function c90397998.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c90397998.desfilter(chkc) end
	-- 检查双方场上是否存在至少1张表侧表示且可成为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c90397998.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要破坏的表侧魔法·陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张表侧表示的魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c90397998.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 声明本次效果将破坏选定的表侧魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理：确认自己场上仍有其他「六武众」怪兽且对象仍为表侧并与效果有联系，然后将其破坏
function c90397998.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选为效果对象的魔法·陷阱卡
	local tc=Duel.GetFirstTarget()
	-- 效果处理时再次确认自己场上仍存在其他「六武众」怪兽，否则中止处理
	if not Duel.IsExistingMatchingCard(c90397998.cfilter,tp,LOCATION_MZONE,0,1,nil) then return end
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标表侧魔法·陷阱卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 代破对象过滤函数：筛选自己场上表侧表示、可被破坏且未处于预定破坏或战破状态的「六武众」怪兽
function c90397998.repfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏目标判定：检查自身非因代破被破坏且存在其他可代破的「六武众」怪兽，询问玩家并选定代破怪兽
function c90397998.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		-- 检查自己怪兽区是否存在自身以外可代替破坏的「六武众」怪兽
		and Duel.IsExistingMatchingCard(c90397998.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问玩家是否适用这张卡的代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 向玩家提示选择要作为代替破坏的「六武众」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家从自己场上选择自身以外的1只表侧「六武众」怪兽代替破坏
		local g=Duel.SelectMatchingCard(tp,c90397998.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏执行：取消预定破坏状态并将选中的「六武众」怪兽作为代替破坏
function c90397998.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以效果及代替破坏原因破坏选中的「六武众」怪兽
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
