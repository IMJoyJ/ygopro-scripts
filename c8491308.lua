--閃刀姫－ハヤテ
-- 效果：
-- 风属性以外的「闪刀姬」怪兽1只
-- 自己对「闪刀姬-飒天」1回合只能有1次特殊召唤。
-- ①：这张卡可以直接攻击。
-- ②：这张卡进行战斗的伤害计算后才能发动。从卡组把1张「闪刀」卡送去墓地。
function c8491308.initial_effect(c)
	c:SetSPSummonOnce(8491308)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，需要1只满足过滤条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,c8491308.matfilter,1,1)
	-- ①：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的伤害计算后才能发动。从卡组把1张「闪刀」卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8491308,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetTarget(c8491308.tgtg)
	e2:SetOperation(c8491308.tgop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤条件：风属性以外的「闪刀姬」怪兽
function c8491308.matfilter(c)
	return c:IsLinkSetCard(0x1115) and c:IsLinkAttribute(ATTRIBUTE_ALL&~ATTRIBUTE_WIND)
end
-- 送去墓地的卡片过滤条件：卡组中的「闪刀」卡
function c8491308.tgfilter(c)
	return c:IsSetCard(0x115) and c:IsAbleToGrave()
end
-- 效果②的发动条件与效果处理检查（检查卡组中是否存在可送去墓地的「闪刀」卡，并设置送去墓地的操作信息）
function c8491308.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己卡组是否存在至少1张满足过滤条件的「闪刀」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c8491308.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息：将自己卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组选择1张「闪刀」卡送去墓地
function c8491308.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己卡组选择1张满足过滤条件的「闪刀」卡
	local g=Duel.SelectMatchingCard(tp,c8491308.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
