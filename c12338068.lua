--真魔獣 ガーゼット
-- 效果：
-- 这张卡不能通常召唤。把自己场上的怪兽全部解放的场合才能特殊召唤。
-- ①：这张卡的攻击力变成因为这张卡特殊召唤而解放的怪兽的原本攻击力合计数值。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c12338068.initial_effect(c)
	c:EnableReviveLimit()
	-- 对应效果原文：这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 对应效果原文：把自己场上的怪兽全部解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c12338068.spcon)
	e2:SetOperation(c12338068.spop)
	c:RegisterEffect(e2)
	-- 对应效果原文：②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
end
-- 特殊召唤条件判定：若c为空则直接允许；否则获取这张卡控制者tp，检索tp场上的全部怪兽g及tp可解放的怪兽组rg，只有场上存在怪兽且场上所有怪兽均可解放时，才满足“把自己场上的怪兽全部解放”的特殊召唤条件。
function c12338068.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取控制者tp自己场上的全部怪兽，作为解放对象检查范围。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 获取tp为特殊召唤可解放的怪兽组（不含手卡），用于确认可解放的怪兽范围。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	return (g:GetCount()>0 or rg:GetCount()>0) and g:FilterCount(Card.IsReleasable,nil,REASON_SPSUMMON)==g:GetCount()
end
-- 执行特殊召唤手续：Duel.GetReleaseGroup(tp)取得本次可解放的怪兽组并全部解放；随后遍历该组，累加每只怪兽大于0的原本攻击力得到atk；再给这张卡注册一个EFFECT_SET_ATTACK效果，使其攻击力变为atk，并在离开场上时重置，对应效果①。
function c12338068.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 取得tp可解放的怪兽组（实际是本次特殊召唤中需要解放的自己场上全部怪兽）。
	local g=Duel.GetReleaseGroup(tp)
	-- 解放全部这些怪兽，作为这张卡特殊召唤的代价。
	Duel.Release(g,REASON_SPSUMMON)
	local atk=0
	local tc=g:GetFirst()
	while tc do
		local batk=tc:GetTextAttack()
		if batk>0 then
			atk=atk+batk
		end
		tc=g:GetNext()
	end
	-- 对应效果原文：①：这张卡的攻击力变成因为这张卡特殊召唤而解放的怪兽的原本攻击力合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
