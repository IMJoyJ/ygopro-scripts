--メタルフォーゼ・オリハルク
-- 效果：
-- 「炼装」怪兽×2
-- ①：自己的「炼装」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的2倍数值的战斗伤害。
-- ②：这张卡从场上送去墓地的场合，以场上1张卡为对象才能发动。那张卡破坏。
function c28016193.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：可以以2只「炼装」怪兽作为融合素材进行融合召唤。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xe1),2,true)
	-- ①：自己的「炼装」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的2倍数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 将该贯穿伤害效果的影响对象限定为己方场上的「炼装」怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xe1))
	e1:SetValue(DOUBLE_DAMAGE)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCondition(c28016193.descon)
	e3:SetTarget(c28016193.destg)
	e3:SetOperation(c28016193.desop)
	c:RegisterEffect(e3)
end
-- 判定触发条件：这张卡从场上送去墓地（其之前的位置为场上）。
function c28016193.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 发动时的目标处理：以场上1张卡为对象，并登记破坏效果的相关信息。
function c28016193.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动合法性检查：场上是否存在至少1张可以作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家弹出“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 令玩家从双方场上选择1张卡作为效果对象，并将其设为当前连锁的目标。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记操作信息：本次效果将破坏1张卡，供相关时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：将之前选择的对象卡破坏（对象仍与效果关联时）。
function c28016193.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一个目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将目标卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
