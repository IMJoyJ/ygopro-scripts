--真六武衆－ミズホ
-- 效果：
-- 自己场上有「真六武众-竹刀」表侧表示存在的场合，这张卡可以从手卡特殊召唤。此外，1回合1次，可以把这张卡以外的自己场上存在的1只名字带有「六武众」的怪兽解放，选择场上存在的1张卡破坏。
function c74094021.initial_effect(c)
	-- 自己场上有「真六武众-竹刀」表侧表示存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c74094021.spcon)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，可以把这张卡以外的自己场上存在的1只名字带有「六武众」的怪兽解放，选择场上存在的1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74094021,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c74094021.cost)
	e2:SetTarget(c74094021.target)
	e2:SetOperation(c74094021.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示存在的「真六武众-竹刀」
function c74094021.spfilter(c)
	return c:IsFaceup() and c:IsCode(48505422)
end
-- 特殊召唤规则的条件判定函数
function c74094021.spcon(e,c)
	if c==nil then return true end
	-- 判定自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 判定自己场上是否存在满足过滤条件的卡（表侧表示的「真六武众-竹刀」）
		Duel.IsExistingMatchingCard(c74094021.spfilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：名字带有「六武众」的怪兽
function c74094021.costfilter(c,tp)
	return c:IsSetCard(0x103d) and (c:IsControler(tp) or c:IsFaceup())
end
-- 效果发动的代价处理函数
function c74094021.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定是否能解放这张卡以外的自己场上存在的1只名字带有「六武众」的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c74094021.costfilter,1,e:GetHandler(),tp) end
	-- 选择要解放的1只名字带有「六武众」的怪兽
	local sg=Duel.SelectReleaseGroup(tp,c74094021.costfilter,1,1,e:GetHandler(),tp)
	-- 将选择的怪兽解放作为发动代价
	Duel.Release(sg,REASON_COST)
end
-- 效果发动的目标选择与操作信息注册函数
function c74094021.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 判定场上是否存在可以作为破坏对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上存在的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为“破坏选中的1张卡”
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理的执行函数
function c74094021.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选中的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
