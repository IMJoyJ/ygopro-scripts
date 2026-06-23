--E・HERO エリクシーラー
-- 效果：
-- 「元素英雄 羽翼侠」＋「元素英雄 爆热女郎」＋「元素英雄 黏土侠」＋「元素英雄 水泡侠」
-- 这只怪兽不能作融合召唤以外的特殊召唤。这张卡的属性也同时当作「风」「水」「炎」「地」使用。这张卡融合召唤成功时，从游戏中除外的全部卡回到持有者的卡组，并洗切卡组。对方场上每存在1只和这张卡相同属性的怪兽，这张卡攻击力上升300。
function c29343734.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤所需的4张融合素材卡号
	aux.AddFusionProcCode4(c,21844576,58932615,84327329,79979666,true,true)
	-- 这只怪兽不能作融合召唤以外的特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该怪兽只能通过融合召唤特殊召唤
	e2:SetValue(aux.fuslimit)
	c:RegisterEffect(e2)
	-- 这张卡的属性也同时当作「风」「水」「炎」「地」使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_ADD_ATTRIBUTE)
	e3:SetValue(0xf)
	c:RegisterEffect(e3)
	-- 这张卡融合召唤成功时，从游戏中除外的全部卡回到持有者的卡组，并洗切卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(29343734,0))  --"返回卡组"
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c29343734.retcon)
	e4:SetTarget(c29343734.rettg)
	e4:SetOperation(c29343734.retop)
	c:RegisterEffect(e4)
	-- 对方场上每存在1只和这张卡相同属性的怪兽，这张卡攻击力上升300。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetValue(c29343734.val)
	c:RegisterEffect(e5)
end
c29343734.material_setcode=0x8
-- 判断此卡是否为融合召唤成功
function c29343734.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 设置连锁处理时的操作信息，确定要将除外区的卡送回卡组
function c29343734.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取所有可以送回卡组的除外区卡片
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	-- 设置操作信息，指定要处理的卡数量和类型为回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 执行将除外区的卡送回卡组并洗牌的操作
function c29343734.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有除外区的卡片用于送回卡组
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	-- 将指定卡片送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 判断目标怪兽是否为表侧表示且具有指定属性
function c29343734.atkfilter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 计算对方场上与该卡属性相同的怪兽数量并乘以300作为攻击力加成
function c29343734.val(e,c)
	-- 获取对方场上与该卡属性相同的怪兽数量并乘以300
	return Duel.GetMatchingGroupCount(c29343734.atkfilter,c:GetControler(),0,LOCATION_MZONE,nil,c:GetAttribute())*300
end
