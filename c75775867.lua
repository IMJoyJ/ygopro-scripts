--D・パッチン
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：1回合1次，可以把「变形斗士·弹弓」以外的1只名字带有「变形斗士」的怪兽解放让场上1张卡破坏。
-- ●守备表示：这张卡被破坏的场合，可以作为代替把这张卡以外的1只名字带有「变形斗士」的怪兽破坏。
function c75775867.initial_effect(c)
	-- ●攻击表示：1回合1次，可以把「变形斗士·弹弓」以外的1只名字带有「变形斗士」的怪兽解放让场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75775867,0))  --"场上1张卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c75775867.descon)
	e1:SetCost(c75775867.descost)
	e1:SetTarget(c75775867.destg)
	e1:SetOperation(c75775867.desop)
	c:RegisterEffect(e1)
	-- ●守备表示：这张卡被破坏的场合，可以作为代替把这张卡以外的1只名字带有「变形斗士」的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c75775867.reptg)
	e2:SetOperation(c75775867.repop)
	c:RegisterEffect(e2)
end
-- 检查自身是否未被无效且处于攻击表示
function c75775867.descon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsAttackPos()
end
-- 过滤自身以外的名字带有「变形斗士」的卡
function c75775867.cfilter(c)
	return not c:IsCode(75775867) and c:IsSetCard(0x26)
end
-- 处理解放怪兽作为发动代价的逻辑
function c75775867.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可解放的「变形斗士·弹弓」以外的「变形斗士」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c75775867.cfilter,1,nil) end
	-- 选择1只「变形斗士·弹弓」以外的「变形斗士」怪兽
	local g=Duel.SelectReleaseGroup(tp,c75775867.cfilter,1,1,nil)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 处理选择破坏对象和设置效果分类的逻辑
function c75775867.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可以作为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理破坏效果的执行逻辑
function c75775867.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选中的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏选中的卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤场上表侧表示、可被效果破坏且未确定被破坏的「变形斗士」怪兽
function c75775867.repfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x26)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 处理代替破坏效果的条件判定与目标检查逻辑
function c75775867.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE) and c:IsDefensePos()
		-- 检查自己场上是否存在可以代替破坏的「变形斗士」怪兽
		and Duel.IsExistingMatchingCard(c75775867.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择自己场上1只「变形斗士」怪兽代替破坏
		local g=Duel.SelectMatchingCard(tp,c75775867.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 处理代替破坏效果的执行逻辑
function c75775867.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 破坏选中的代替怪兽
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
