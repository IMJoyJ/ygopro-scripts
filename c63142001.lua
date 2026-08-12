--電池メン－単三型
-- 效果：
-- ●自己场上的「电池人-单三型」全部攻击表示的场合，每存在1张「电池人-单三型」这张卡的攻击力上升1000。
-- ●自己场上的「电池人-单三型」全部守备表示的场合，每存在1张「电池人-单三型」这张卡的守备力上升1000。
function c63142001.initial_effect(c)
	-- ●自己场上的「电池人-单三型」全部攻击表示的场合，每存在1张「电池人-单三型」这张卡的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c63142001.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c63142001.defval)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的「电池人-单三型」的过滤函数
function c63142001.filter(c)
	return c:IsFaceup() and c:IsCode(63142001)
end
-- 计算攻击力上升值的函数，若存在守备表示的「电池人-单三型」则不上升，否则每存在1张上升1000
function c63142001.atkval(e,c)
	-- 获取自己场上所有表侧表示的「电池人-单三型」
	local g=Duel.GetMatchingGroup(c63142001.filter,c:GetControler(),LOCATION_MZONE,0,nil)
	if g:IsExists(Card.IsDefensePos,1,nil) then return 0 end
	return g:GetCount()*1000
end
-- 计算守备力上升值的函数，若存在攻击表示的「电池人-单三型」则不上升，否则每存在1张上升1000
function c63142001.defval(e,c)
	-- 获取自己场上所有表侧表示的「电池人-单三型」
	local g=Duel.GetMatchingGroup(c63142001.filter,c:GetControler(),LOCATION_MZONE,0,nil)
	if g:IsExists(Card.IsAttackPos,1,nil) then return 0 end
	return g:GetCount()*1000
end
