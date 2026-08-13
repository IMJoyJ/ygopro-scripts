--コード・トーカー
-- 效果：
-- 效果怪兽2只
-- ①：这张卡的攻击力上升这张卡所连接区的怪兽数量×500。
-- ②：只要这张卡所连接区有怪兽存在，这张卡不会被战斗以及对方的效果破坏。
function c53413628.initial_effect(c)
	-- 为「码语者」添加连接召唤手续：以2只效果怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡所连接区的怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c53413628.atkval)
	c:RegisterEffect(e1)
	-- ②：只要这张卡所连接区有怪兽存在，这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c53413628.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置效果破坏免疫的判定：仅当破坏效果来自对方玩家时适用，即「不会被对方的效果破坏」。
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
end
-- 攻击力上升值的计算函数：返回这张卡所连接区的怪兽数量×500。
function c53413628.atkval(e,c)
	return c:GetLinkedGroupCount()*500
end
-- ②效果的发动条件：这张卡所连接区有怪兽存在时返回true。
function c53413628.indcon(e)
	return e:GetHandler():GetLinkedGroupCount()>0
end
