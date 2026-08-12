--E・HERO プラズマヴァイスマン
-- 效果：
-- 「元素英雄 电光侠」＋「元素英雄 金刃侠」
-- 这只怪兽不能作融合召唤以外的特殊召唤。这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。可以丢弃1张手卡把对方场上1只攻击表示怪兽破坏。
function c60493189.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定「元素英雄 电光侠」和「元素英雄 金刃侠」为融合素材
	aux.AddFusionProcCode2(c,20721928,59793705,true,true)
	-- 这只怪兽不能作融合召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该卡只能通过融合召唤的方式特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- 可以丢弃1张手卡把对方场上1只攻击表示怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(60493189,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c60493189.descost)
	e3:SetTarget(c60493189.destg)
	e3:SetOperation(c60493189.desop)
	c:RegisterEffect(e3)
end
c60493189.material_setcode=0x8
-- 破坏效果的代价（Cost）处理函数，用于丢弃手牌
function c60493189.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检查手牌中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 作为发动代价，从手牌中选择1张卡丢弃
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，筛选处于攻击表示的怪兽
function c60493189.filter(c)
	return c:IsAttackPos()
end
-- 破坏效果的目标（Target）处理函数，用于选择破坏对象
function c60493189.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c60493189.filter(chkc) end
	-- 在发动效果前，检查对方场上是否存在至少1只攻击表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c60493189.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示其选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只攻击表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c60493189.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息，表明此效果的处理是破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的操作（Operation）处理函数，执行实际的破坏
function c60493189.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsAttackPos() and tc:IsControler(1-tp) and tc:IsRelateToEffect(e) then
		-- 将选中的效果对象因效果而破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
