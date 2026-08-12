--E・HERO ワイルド・ウィングマン
-- 效果：
-- 「元素英雄 荒野侠」＋「元素英雄 羽翼侠」
-- 这只怪兽不能作融合召唤以外的特殊召唤。可以丢弃1张手卡，把场上的1张魔法·陷阱卡破坏。
function c55615891.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，素材为「元素英雄 荒野侠」与「元素英雄 羽翼侠」
	aux.AddFusionProcCode2(c,86188410,21844576,true,true)
	-- 这只怪兽不能作融合召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为仅能进行融合召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 可以丢弃1张手卡，把场上的1张魔法·陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55615891,0))  --"魔陷破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(c55615891.descost)
	e2:SetTarget(c55615891.destg)
	e2:SetOperation(c55615891.desop)
	c:RegisterEffect(e2)
end
c55615891.material_setcode=0x8
-- 效果发动代价（丢弃手卡）的检测与执行函数
function c55615891.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手牌中是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中丢弃1张卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤场上的魔法、陷阱卡
function c55615891.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动阶段的检测与对象选择函数
function c55615891.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c55615891.filter(chkc) end
	-- 在发动阶段，检查场上是否存在可以作为对象的魔法、陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c55615891.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法、陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c55615891.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理阶段的执行函数
function c55615891.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏该效果对象
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
