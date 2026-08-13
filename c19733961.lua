--電池メン－単二型
-- 效果：
-- ●当自己场上的「电池人-单二型」全部攻击表示的场合：每有1只「电池人-单二型」，自己场上的全部机械族怪兽攻击力上升500。
-- ●当自己场上的「电池人-单二型」全部守备表示的场合：每有1只「电池人-单二型」，自己场上的全部机械族怪兽守备力上升500。
function c19733961.initial_effect(c)
	-- 当自己场上的「电池人-单二型」全部攻击表示的场合：每有1只「电池人-单二型」，自己场上的全部机械族怪兽攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置该效果只对自己场上的机械族怪兽生效，用于筛选出攻击力上升的适用对象。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_MACHINE))
	e1:SetValue(c19733961.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c19733961.defval)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断场上怪兽是否为表侧表示且卡名为「电池人-单二型」（卡号19733961），用于查询自己场上存在的同名怪兽。
function c19733961.filter(c)
	return c:IsFaceup() and c:IsCode(19733961)
end
-- 攻击力增加值函数：先获取自己场上所有表侧表示且卡名为「电池人-单二型」的怪兽，若其中存在守备表示怪兽（即并非全部攻击表示），则攻击力上升0；否则上升500。
function c19733961.atkval(e,c)
	-- 获取自己场上所有表侧表示且卡名为「电池人-单二型」的怪兽组，用于后续判断是否全部为攻击表示。
	local g=Duel.GetMatchingGroup(c19733961.filter,c:GetControler(),LOCATION_MZONE,0,nil)
	if g:IsExists(Card.IsDefensePos,1,nil) then return 0 end
	return 500
end
-- 守备力增加值函数：先获取自己场上所有表侧表示且卡名为「电池人-单二型」的怪兽，若其中存在攻击表示怪兽（即并非全部守备表示），则守备力上升0；否则上升500。
function c19733961.defval(e,c)
	-- 获取自己场上所有表侧表示且卡名为「电池人-单二型」的怪兽组，用于后续判断是否全部为守备表示。
	local g=Duel.GetMatchingGroup(c19733961.filter,c:GetControler(),LOCATION_MZONE,0,nil)
	if g:IsExists(Card.IsAttackPos,1,nil) then return 0 end
	return 500
end
