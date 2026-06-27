--万物創世龍
-- 效果：
-- 这张卡不能通常召唤。把攻击力合计和守备力合计的总计直到10000以上的自己场上的怪兽解放的场合才能特殊召唤。
-- ①：这个方法特殊召唤的这张卡的攻击力·守备力变成10000。
function c10000.initial_effect(c)
	c:EnableReviveLimit()
	-- 不能通常召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把攻击力合计和守备力合计的总计直到10000以上的自己场上的怪兽解放的场合才能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c10000.spcon)
	e2:SetTarget(c10000.sptg)
	e2:SetOperation(c10000.spop)
	c:RegisterEffect(e2)
end
-- 解放怪兽的过滤条件（自己场上的怪兽）
function c10000.rfilter(c,tp)
	return c:IsControler(tp) or c:IsFaceup()
end
-- 获取怪兽攻击力与守备力的合计值
function c10000.sumfilter(c)
	return c:GetAttack()+c:GetDefense()
end
-- 检查选中的怪兽攻守合计是否达10000以上且满足怪兽区域的位置限制
function c10000.fselect(g,tp)
	-- 设置已选中的怪兽以用于攻防值合计计算
	Duel.SetSelectedCard(g)
	-- 检查选中的怪兽攻防合计是否达10000以上且满足怪兽区域的位置限制
	return g:CheckWithSumGreater(c10000.sumfilter,10000) and aux.mzctcheckrel(g,tp,REASON_SPSUMMON)
end
-- 特殊召唤条件：检查是否存在符合解放条件的怪兽组合
function c10000.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取可解放的怪兽组并过滤出符合条件的怪兽
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c10000.rfilter,nil,tp)
	return rg:CheckSubGroup(c10000.fselect,1,rg:GetCount(),tp)
end
-- 特殊召唤的准备操作：选择并锁定制定的解放怪兽
function c10000.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取可解放的怪兽组并过滤出符合条件的怪兽
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c10000.rfilter,nil,tp)
	-- 提示选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,c10000.fselect,true,1,rg:GetCount(),tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤的实际操作：解放怪兽并将自身的攻防永久设定为10000
function c10000.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选定的怪兽
	Duel.Release(g,REASON_SPSUMMON)
	-- ①：这个方法特殊召唤的这张卡的攻击力·守备力变成10000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(10000)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
	g:DeleteGroup()
end
