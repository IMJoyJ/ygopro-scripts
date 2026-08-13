--サイバー・チュチュ
-- 效果：
-- ①：对方场上的怪兽只有持有比这张卡高的攻击力的怪兽的场合，这张卡可以向对方直接攻击。
function c49375719.initial_effect(c)
	-- ①：对方场上的怪兽只有持有比这张卡高的攻击力的怪兽的场合，这张卡可以向对方直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c49375719.dacon)
	c:RegisterEffect(e1)
end
-- 该过滤函数用于识别不会阻挡直接攻击的对方怪兽：里侧表示或攻击力不高于此卡当前攻击力的怪兽返回 true；反之，表侧表示且攻击力高于此卡的怪兽不满足条件，会阻碍直接攻击。
function c49375719.filter(c,atk)
	return c:IsFacedown() or c:GetAttack()<=atk
end
-- 直接攻击条件：不存在任何满足过滤条件的对方怪兽，即对方场上不存在里侧表示或攻击力不高于此卡的怪兽，也就是对方场上怪兽均为表侧表示且攻击力都高于此卡。
function c49375719.dacon(e)
	-- 判定 not Duel.IsExistingMatchingCard 为真：在对方主要怪兽区不存在任何一只‘里侧表示或攻击力≤此卡攻击力’的怪兽。
	return not Duel.IsExistingMatchingCard(c49375719.filter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack())
end
