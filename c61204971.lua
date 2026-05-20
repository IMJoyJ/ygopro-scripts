--E・HERO サンダー・ジャイアント
-- 效果：
-- 「元素英雄 电光侠」＋「元素英雄 黏土侠」
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：1回合1次，丢弃1张手卡，以场上1只表侧表示怪兽为对象才能发动。原本攻击力比这张卡的攻击力低的那只怪兽破坏。
function c61204971.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「元素英雄 电光侠」和「元素英雄 黏土侠」
	aux.AddFusionProcCode2(c,20721928,84327329,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制特殊召唤方式为仅能通过融合召唤进行
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，丢弃1张手卡，以场上1只表侧表示怪兽为对象才能发动。原本攻击力比这张卡的攻击力低的那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61204971,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c61204971.descost)
	e2:SetTarget(c61204971.destg)
	e2:SetOperation(c61204971.desop)
	c:RegisterEffect(e2)
end
c61204971.material_setcode=0x8
-- 效果①的代价（Cost）函数：丢弃1张手卡
function c61204971.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：场上表侧表示且原本攻击力小于指定数值的怪兽
function c61204971.filter(c,atk)
	return c:IsFaceup() and c:GetBaseAttack()<atk
end
-- 效果①的发动条件与对象选择（Target）函数
function c61204971.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c61204971.filter(chkc,e:GetHandler():GetAttack()) end
	-- 检查场上是否存在原本攻击力低于此卡当前攻击力的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c61204971.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1只原本攻击力低于此卡当前攻击力的表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c61204971.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e:GetHandler():GetAttack())
	-- 设置效果处理信息：包含破坏操作，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的效果处理（Operation）函数
function c61204971.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and tc:GetBaseAttack()<c:GetAttack() then
		-- 破坏该对象怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
