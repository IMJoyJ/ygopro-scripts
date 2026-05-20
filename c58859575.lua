--VW－タイガー・カタパルト
-- 效果：
-- 「V-喷气虎」＋「W-弹射飞翼」
-- 把自己场上的上记卡除外的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：丢弃1张手卡，以对方场上1只怪兽为对象才能发动。那只对方怪兽的表示形式变更。这个时候，反转怪兽的效果不发动。
function c58859575.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「V-喷气虎」与「W-弹射飞翼」
	aux.AddFusionProcCode2(c,51638941,96300057,true,true)
	-- 添加接触融合的特殊召唤规则，将自己场上的素材表侧表示除外
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 把自己场上的上记卡除外的场合才能从额外卡组特殊召唤（不需要「融合」）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c58859575.splimit)
	c:RegisterEffect(e1)
	-- ①：丢弃1张手卡，以对方场上1只怪兽为对象才能发动。那只对方怪兽的表示形式变更。这个时候，反转怪兽的效果不发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58859575,0))  --"改变表示形式"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c58859575.poscost)
	e3:SetTarget(c58859575.postg)
	e3:SetOperation(c58859575.posop)
	c:RegisterEffect(e3)
end
-- 限制从额外卡组特殊召唤时必须满足上述特殊召唤条件
function c58859575.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 效果①的发动代价：丢弃1张手卡
function c58859575.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张手牌作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：可以改变表示形式的怪兽
function c58859575.filter(c)
	return c:IsCanChangePosition()
end
-- 效果①的发动准备（检查与选择对象）
function c58859575.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c58859575.filter(chkc) end
	-- 检查对方场上是否存在可以改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingTarget(c58859575.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上1只可以改变表示形式的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c58859575.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果①的效果处理（变更表示形式且不发动反转效果）
function c58859575.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 变更该怪兽的表示形式，且不触发反转效果
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,true)
	end
end
