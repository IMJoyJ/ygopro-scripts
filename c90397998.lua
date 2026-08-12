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
-- 过滤条件：自己场上表侧表示存在的「六武众-火门」以外的「六武众」怪兽
function c90397998.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(90397998)
end
-- 效果发动条件：自己场上存在「六武众-火门」以外的「六武众」怪兽
function c90397998.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足过滤条件的怪兽
	return Duel.IsExistingMatchingCard(c90397998.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动消耗/限制：检查本回合是否未进行攻击宣言，并添加不能攻击宣言的限制
function c90397998.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合，这张卡不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示存在的魔法·陷阱卡
function c90397998.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动目标：选择场上表侧表示存在的1张魔法·陷阱卡为对象
function c90397998.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c90397998.desfilter(chkc) end
	-- 检查场上是否存在可以作为对象的表侧表示的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c90397998.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择1张表侧表示的魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c90397998.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：再次检查条件，若满足则破坏作为对象的卡
function c90397998.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象卡
	local tc=Duel.GetFirstTarget()
	-- 效果处理时再次检查自己场上是否存在「六武众-火门」以外的「六武众」怪兽，若不存在则不处理
	if not Duel.IsExistingMatchingCard(c90397998.cfilter,tp,LOCATION_MZONE,0,1,nil) then return end
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 代替破坏的过滤条件：自己场上表侧表示存在、可被效果破坏且未确定被破坏的「六武众」怪兽
function c90397998.repfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏的目标：检查自身是否因非代替原因被破坏，并询问玩家是否使用代替效果
function c90397998.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		-- 检查自己场上是否存在可以代替破坏的「六武众」怪兽
		and Duel.IsExistingMatchingCard(c90397998.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择用于代替破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择1只自己场上表侧表示存在的「六武众」怪兽作为代替
		local g=Duel.SelectMatchingCard(tp,c90397998.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏的处理：将选中的代替怪兽破坏
function c90397998.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 破坏选中的代替怪兽
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
