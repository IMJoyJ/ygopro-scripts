--メタルフォーゼ・オリハルク
-- 效果：
-- 「炼装」怪兽×2
-- ①：自己的「炼装」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的2倍数值的战斗伤害。
-- ②：这张卡从场上送去墓地的场合，以场上1张卡为对象才能发动。那张卡破坏。
function c28016193.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个满足「炼装」属性的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xe1),2,true)
	-- ①：自己的「炼装」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的2倍数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为场上所有「炼装」怪兽
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
-- 效果发动条件：此卡从场上离开墓地
function c28016193.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 选择破坏对象：选择场上1张卡作为破坏目标
function c28016193.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查是否满足破坏对象选择条件：场上存在至少1张可破坏的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，确定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏操作：将选定的卡破坏
function c28016193.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
