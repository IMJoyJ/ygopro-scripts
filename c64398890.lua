--六武衆－ヤイチ
-- 效果：
-- 自己场上有「六武众-矢一」以外的名字带有「六武众」的怪兽存在的场合，1回合1次，可以选择场上盖放的1张魔法·陷阱卡破坏。这个效果发动的回合，这张卡不能攻击宣言。此外，场上表侧表示存在的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「六武众」的怪兽破坏。
function c64398890.initial_effect(c)
	-- 自己场上有「六武众-矢一」以外的名字带有「六武众」的怪兽存在的场合，1回合1次，可以选择场上盖放的1张魔法·陷阱卡破坏。这个效果发动的回合，这张卡不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64398890,0))  --"盖伏的1张魔法·陷阱卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c64398890.descon)
	e1:SetCost(c64398890.descost)
	e1:SetTarget(c64398890.destg)
	e1:SetOperation(c64398890.desop)
	c:RegisterEffect(e1)
	-- 此外，场上表侧表示存在的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「六武众」的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c64398890.desreptg)
	e2:SetOperation(c64398890.desrepop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示存在的「六武众-矢一」以外的名字带有「六武众」的怪兽
function c64398890.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(64398890)
end
-- 破坏效果的发动条件：自己场上存在「六武众-矢一」以外的名字带有「六武众」的怪兽
function c64398890.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足过滤条件的怪兽
	return Duel.IsExistingMatchingCard(c64398890.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 破坏效果的发动代价：检查本回合是否未进行攻击宣言，并添加不能攻击宣言的限制
function c64398890.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合，这张卡不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤条件：场上盖放的卡（里侧表示）
function c64398890.desfilter(c)
	return c:IsFacedown()
end
-- 破坏效果的发动阶段：选择场上盖放的1张魔法·陷阱卡作为对象，并设置破坏操作信息
function c64398890.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c64398890.desfilter(chkc) end
	-- 检查双方魔陷区是否存在至少1张盖放的卡作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c64398890.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 给玩家发送“请选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1张盖放的魔陷卡作为效果对象
	local g=Duel.SelectTarget(tp,c64398890.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	-- 设置效果处理信息，包含破坏分类和选中的对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理阶段：检查场上是否仍存在其他「六武众」怪兽，若对象卡仍为里侧表示则将其破坏
function c64398890.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 效果处理时，若自己场上已不存在「六武众-矢一」以外的名字带有「六武众」的怪兽，则效果不适用
	if not Duel.IsExistingMatchingCard(c64398890.cfilter,tp,LOCATION_MZONE,0,1,nil) then return end
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤条件：自己场上表侧表示存在、可被效果破坏且未确定被破坏的其他「六武众」怪兽
function c64398890.repfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的发动阶段：检查自身是否因非代替破坏的原因被破坏，并询问玩家是否使用代替破坏效果
function c64398890.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		-- 检查自己场上是否存在至少1只可用于代替破坏的其他「六武众」怪兽
		and Duel.IsExistingMatchingCard(c64398890.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 给玩家发送“请选择要代替破坏的卡”的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家选择1只自己场上表侧表示存在的其他「六武众」怪兽作为代替
		local g=Duel.SelectMatchingCard(tp,c64398890.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的处理阶段：将选中的代替怪兽破坏，从而使自身免于被破坏
function c64398890.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选中的代替怪兽因代替破坏的效果而破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
