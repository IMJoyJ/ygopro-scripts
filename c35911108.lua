--ランチャー・コマンダー
-- 效果：
-- ①：只要这张卡在怪兽区域存在，这张卡以外的自己场上的电子界族怪兽的攻击力·守备力上升300。
-- ②：1回合1次，把自己场上1只电子界族怪兽解放，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
function c35911108.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，这张卡以外的自己场上的电子界族怪兽的攻击力·守备力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c35911108.atktg)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把自己场上1只电子界族怪兽解放，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35911108,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c35911108.descost)
	e3:SetTarget(c35911108.destg)
	e3:SetOperation(c35911108.desop)
	c:RegisterEffect(e3)
end
-- 该效果影响的怪兽必须是电子界族且不能是自身
function c35911108.atktg(e,c)
	return c:IsRace(RACE_CYBERSE) and c~=e:GetHandler()
end
-- 支付效果代价：检查自己场上是否存在可解放的电子界族怪兽，若存在则选择1只进行解放
function c35911108.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的电子界族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_CYBERSE) end
	-- 选择1张满足条件的可解放的电子界族怪兽
	local sg=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_CYBERSE)
	-- 将选中的怪兽进行解放，作为支付代价
	Duel.Release(sg,REASON_COST)
end
-- 选择破坏对象：选择对方场上1只表侧表示怪兽作为破坏目标
function c35911108.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 确认是否能选择破坏对象：检查对方场上是否存在1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示怪兽作为破坏目标
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表明本次效果将破坏1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果：若目标怪兽仍存在于场上，则将其破坏
function c35911108.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏，原因视为效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
