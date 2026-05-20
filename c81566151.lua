--E・HERO フレア・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·火焰甲虫」
-- 把自己场上存在的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。这张卡的攻击力上升场上的魔法·陷阱卡数量×400的数值。结束阶段时这张卡回到额外卡组。
function c81566151.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「元素英雄 新宇侠」和「新空间侠·火焰甲虫」
	aux.AddFusionProcCode2(c,89943723,89621922,false,false)
	-- 添加接触融合的特殊召唤规则，将自己场上的素材回到卡组
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 把自己场上存在的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c81566151.splimit)
	c:RegisterEffect(e1)
	-- 注册新宇侠融合怪兽共通的结束阶段返回额外卡组的效果
	aux.EnableNeosReturn(c,c81566151.retop)
	-- 这张卡的攻击力上升场上的魔法·陷阱卡数量×400的数值。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(c81566151.atkval)
	c:RegisterEffect(e5)
end
c81566151.material_setcode=0x8
-- 限制该卡从额外卡组特殊召唤时，必须满足其自身规定的特殊召唤条件
function c81566151.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 定义结束阶段将该卡回到额外卡组的具体操作
function c81566151.retop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 将该卡送回持有者的额外卡组并洗牌
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 计算攻击力上升值的函数
function c81566151.atkval(e,c)
	-- 获取双方场上魔法和陷阱卡的总数，并乘以400作为攻击力上升值返回
	return Duel.GetMatchingGroupCount(Card.IsType,0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)*400
end
