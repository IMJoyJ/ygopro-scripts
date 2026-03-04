--麗しき磁律機壊
-- 效果：
-- 效果怪兽2只以上
-- 自己不能在这张卡所连接区让怪兽出现。
-- ①：这张卡所连接区的怪兽不能攻击，那些怪兽的所发动的效果无效化。
-- ②：这张卡的攻击力上升这张卡所连接区的怪兽的原本攻击力数值。
-- ③：这张卡所连接区没有怪兽存在的场合，这张卡不会被战斗以及怪兽的效果破坏。
local s,id,o=GetID()
-- 初始化效果函数
function s.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2只效果怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- 自己不能在这张卡所连接区让怪兽出现。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_USE_MZONE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.zonelimit)
	c:RegisterEffect(e1)
	-- 这张卡所连接区的怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.antg)
	c:RegisterEffect(e2)
	-- 那些怪兽的所发动的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.discon)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	-- 这张卡的攻击力上升这张卡所连接区的怪兽的原本攻击力数值。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
	-- 这张卡所连接区没有怪兽存在的场合，这张卡不会被战斗以及怪兽的效果破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetValue(1)
	e5:SetCondition(s.incon)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e6:SetValue(s.efilter)
	c:RegisterEffect(e6)
end
-- zone限制函数，返回不能使用的区域
function s.zonelimit(e)
	return 0x7f007f & ~e:GetHandler():GetLinkedZone()
end
-- 攻击限制目标函数，判断目标是否在连接区
function s.antg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 无效化连锁效果的条件函数
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc and re:IsActiveType(TYPE_MONSTER) and rc:IsRelateToChain() and e:GetHandler():GetLinkedGroup():IsContains(rc)
		-- 判断效果是否可以被无效
		and rc:IsCanBeDisabledByEffect(e) and Duel.IsChainDisablable(ev)
end
-- 无效化连锁效果的操作函数
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示对方发动了卡片效果
	Duel.Hint(HINT_CARD,0,id)
	-- 使连锁效果无效
	Duel.NegateEffect(ev)
end
-- 攻击力计算函数，返回连接区怪兽原始攻击力总和
function s.atkval(e,c)
	local g=e:GetHandler():GetLinkedGroup():Filter(Card.IsFaceup,nil)
	return g:GetSum(Card.GetBaseAttack)
end
-- 不被破坏的条件函数，判断连接区是否为空
function s.incon(e)
	local c=e:GetHandler()
	return c:IsType(TYPE_LINK) and c:GetLinkedGroupCount()==0
end
-- 效果过滤函数，判断是否为效果怪兽
function s.efilter(e,re)
	return re:IsActiveType(TYPE_EFFECT)
end
