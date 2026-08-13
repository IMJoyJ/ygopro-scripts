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
-- 判定攻击力上升效果的适用对象：该卡必须是电子界族，且不能是效果持有者自身（即“这张卡以外的自己场上的电子界族怪兽”）。
function c35911108.atktg(e,c)
	return c:IsRace(RACE_CYBERSE) and c~=e:GetHandler()
end
-- ②效果的发动代价处理：灵摆召唤/起动效果的代价判定与选择并解放自己场上1只电子界族怪兽。
function c35911108.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认自己场上是否存在至少1只可解放的电子界族怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_CYBERSE) end
	-- 玩家选择要解放的1只电子界族怪兽（作为发动代价）。
	local sg=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_CYBERSE)
	-- 将选择的怪兽解放，并作为COST处理。
	Duel.Release(sg,REASON_COST)
end
-- ②效果的目标选择与发动条件判定：以对方场上1只表侧表示怪兽为对象，并设置破坏效果的信息。
function c35911108.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 效果发动时检查：对方场上是否存在1只表侧表示怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出“请选择要破坏的卡”的选择提示，引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象，并建立该对象与当前效果的关联。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 向连锁系统登记本次破坏效果的处理信息（对象1张、不取对象时的持有者/位置参数），用于后续时点检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理时的操作：取得之前选择的对象，若该对象仍与效果关联则将其破坏。
function c35911108.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
