--E・HERO エリクシーラー
-- 效果：
-- 「元素英雄 羽翼侠」＋「元素英雄 爆热女郎」＋「元素英雄 黏土侠」＋「元素英雄 水泡侠」
-- 这只怪兽不能作融合召唤以外的特殊召唤。这张卡的属性也同时当作「风」「水」「炎」「地」使用。这张卡融合召唤成功时，从游戏中除外的全部卡回到持有者的卡组，并洗切卡组。对方场上每存在1只和这张卡相同属性的怪兽，这张卡攻击力上升300。
function c29343734.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，指定「元素英雄 羽翼侠」「元素英雄 爆热女郎」「元素英雄 黏土侠」「元素英雄 水泡侠」作为融合素材。
	aux.AddFusionProcCode4(c,21844576,58932615,84327329,79979666,true,true)
	-- 这只怪兽不能作融合召唤以外的特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的判定函数，仅允许通过『融合召唤』这种方式进行特殊召唤，其他特殊召唤方式均不能适用。
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
-- 诱发效果的发动条件：此卡以融合召唤方式特殊召唤成功时满足条件。
function c29343734.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 诱发效果的发动处理目标判定：在效果发动时，收集除外区所有可以回到卡组的卡，并将『回到卡组』的操作信息登记为这些卡，保证后续处理与连锁判定正确。
function c29343734.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取除外区中满足可回到卡组条件的所有卡，作为本效果处理时将被送回卡组的对象列表。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	-- 将本次连锁的操作信息登记为『使这些卡回到卡组』，数量为对象卡数量，供效果处理及连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 诱发效果的实际处理：将除外区的所有卡送回持有者的卡组，并洗切卡组。
function c29343734.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方除外区的所有卡（不作额外过滤），作为本次要送回卡组的全部对象。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	-- 以效果原因将对象卡组全部送回其持有者的卡组，并以SEQ_DECKSHUFFLE方式洗切卡组。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 定义攻击力判定用的过滤器：怪兽需表侧表示且属性等于永生侠的当前属性。
function c29343734.atkfilter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 计算攻击力上升数值：统计对方场上满足相同属性条件的表侧表示怪兽的数量，每个300攻击力。
function c29343734.val(e,c)
	-- 取对方场上与自身属性相同的表侧表示怪兽数量，乘以300后作为攻击力上升值。
	return Duel.GetMatchingGroupCount(c29343734.atkfilter,c:GetControler(),0,LOCATION_MZONE,nil,c:GetAttribute())*300
end
