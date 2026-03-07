--憑依装着－アウス
-- 效果：
-- ①：这张卡可以把自己场上的表侧表示的1只「地灵使 奥丝」和1只地属性怪兽送去墓地，从手卡·卡组特殊召唤。
-- ②：这张卡的①的方法特殊召唤的这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c31887905.initial_effect(c)
	-- 效果原文内容：①：这张卡可以把自己场上的表侧表示的1只「地灵使 奥丝」和1只地属性怪兽送去墓地，从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCondition(c31887905.spcon)
	e1:SetTarget(c31887905.sptg)
	e1:SetOperation(c31887905.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡的①的方法特殊召唤的这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetCondition(c31887905.condition)
	c:RegisterEffect(e2)
end
-- 检索满足条件的卡片组：场上的表侧表示的怪兽且可以作为cost送去墓地
function c31887905.spfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 检查卡片组是否满足条件：怪兽区空位足够且包含1只「地灵使 奥丝」和1只地属性怪兽
function c31887905.fselect(g,tp)
	-- 检查卡片组是否满足条件：怪兽区空位足够且包含1只「地灵使 奥丝」和1只地属性怪兽
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,Card.IsCode,37970940,Card.IsAttribute,ATTRIBUTE_EARTH)
end
-- 判断特殊召唤条件是否满足：场上有满足条件的2张怪兽卡
function c31887905.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足条件的卡片组：场上表侧表示的可以送去墓地的怪兽
	local g=Duel.GetMatchingGroup(c31887905.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c31887905.fselect,2,2,tp)
end
-- 设置特殊召唤目标：选择满足条件的2张怪兽卡并标记为即将送去墓地
function c31887905.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的卡片组：场上表侧表示的可以送去墓地的怪兽
	local g=Duel.GetMatchingGroup(c31887905.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c31887905.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤后的处理：将标记的卡片组送去墓地
function c31887905.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标卡片组以特殊召唤原因送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断是否满足贯穿伤害效果的触发条件：该卡是通过①的效果特殊召唤的
function c31887905.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
