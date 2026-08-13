--麗しき磁律機壊
-- 效果：
-- 效果怪兽2只以上
-- 自己不能在这张卡所连接区让怪兽出现。
-- ①：这张卡所连接区的怪兽不能攻击，那些怪兽的所发动的效果无效化。
-- ②：这张卡的攻击力上升这张卡所连接区的怪兽的原本攻击力数值。
-- ③：这张卡所连接区没有怪兽存在的场合，这张卡不会被战斗以及怪兽的效果破坏。
local s,id,o=GetID()
-- 初始化效果：为这张卡设置连接召唤手续（效果怪兽2只以上）和苏生限制，再分别注册①的不能攻击/效果无效化、②的攻击力上升、③的战斗/效果破坏抗性。
function s.initial_effect(c)
	-- 添加连接召唤手续：这张卡可用2只以上效果怪兽作为连接素材进行连接召唤。
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
	-- ①：这张卡所连接区的怪兽不能攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.antg)
	c:RegisterEffect(e2)
	-- ①：那些怪兽的所发动的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.discon)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	-- ②：这张卡的攻击力上升这张卡所连接区的怪兽的原本攻击力数值。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
	-- ③：这张卡所连接区没有怪兽存在的场合，这张卡不会被战斗以及怪兽的效果破坏。
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
-- 作为EFFECT_MUST_USE_MZONE的Value：将全怪兽区域掩码0x7f007f清除这张卡连接区后的值作为可用区域，使怪兽不能出现在这张卡所连接区。
function s.zonelimit(e)
	return 0x7f007f & ~e:GetHandler():GetLinkedZone()
end
-- e2的Target函数：判断要攻击的怪兽c是否位于这张卡的连接区；若在连接区则不能攻击。
function s.antg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- e3的Condition：当有怪兽在连接区发动的效果进入连锁且仍与连锁相关、能被本卡无效、连锁也可被无效时，本次处理才执行无效化。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc and re:IsActiveType(TYPE_MONSTER) and rc:IsRelateToChain() and e:GetHandler():GetLinkedGroup():IsContains(rc)
		-- 追加判定：该发动效果能被本卡无效，并且该连锁效果当前可被无效。
		and rc:IsCanBeDisabledByEffect(e) and Duel.IsChainDisablable(ev)
end
-- e3的Operation：无效化处理时向双方展示这张卡，并直接无效对应连锁的效果。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示本卡的卡图/发动动画，作为不入连锁的无效效果提示。
	Duel.Hint(HINT_CARD,0,id)
	-- 使编号为ev的连锁效果无效化。
	Duel.NegateEffect(ev)
end
-- e4的Value：检索这张卡连接区的表侧表示怪兽，将其原本攻击力合计作为这张卡的攻击力上升数值。
function s.atkval(e,c)
	local g=e:GetHandler():GetLinkedGroup():Filter(Card.IsFaceup,nil)
	return g:GetSum(Card.GetBaseAttack)
end
-- e5/e6共同的Condition：这张卡是连接怪兽，且所连接区没有怪兽存在时，③的破坏抗性适用。
function s.incon(e)
	local c=e:GetHandler()
	return c:IsType(TYPE_LINK) and c:GetLinkedGroupCount()==0
end
-- e6的Value：只要试图破坏这张卡的效果来源于怪兽（效果怪兽）效果，就视为符合③的‘怪兽的效果’，不破坏。
function s.efilter(e,re)
	return re:IsActiveType(TYPE_EFFECT)
end
