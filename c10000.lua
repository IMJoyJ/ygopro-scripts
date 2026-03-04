--万物創世龍
-- 效果：
-- 这张卡不能通常召唤。把攻击力合计和守备力合计的总计直到10000以上的自己场上的怪兽解放的场合才能特殊召唤。
-- ①：这个方法特殊召唤的这张卡的攻击力·守备力变成10000。
function c10000.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把攻击力合计和守备力合计的总计直到10000以上的自己场上的怪兽解放的场合才能特殊召唤。
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
-- 用于筛选可以被解放的怪兽，只要怪兽在场上或控制者是当前玩家即可。
function c10000.rfilter(c,tp)
	return c:IsControler(tp) or c:IsFaceup()
end
-- 用于计算单个怪兽的攻击力与守备力之和。
function c10000.sumfilter(c)
	return c:GetAttack()+c:GetDefense()
end
-- 用于检查所选怪兽组是否满足攻击力与守备力合计大于10000的条件，并确保释放后主怪兽区仍有空位。
function c10000.fselect(g,tp)
	-- 将已选择的卡片组设置为后续检查的参考对象。
	Duel.SetSelectedCard(g)
	-- 检查所选卡片组的攻击力与守备力之和是否大于10000，并验证释放后主怪兽区是否仍有空位。
	return g:CheckWithSumGreater(c10000.sumfilter,10000) and aux.mzctcheckrel(g,tp,REASON_SPSUMMON)
end
-- 判断特殊召唤条件是否满足，即是否存在满足条件的怪兽组可被解放。
function c10000.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家可解放的怪兽组，并筛选出符合条件的怪兽。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c10000.rfilter,nil,tp)
	return rg:CheckSubGroup(c10000.fselect,1,rg:GetCount(),tp)
end
-- 设置特殊召唤的目标选择函数，用于选择需要解放的怪兽。
function c10000.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家可解放的怪兽组，并筛选出符合条件的怪兽。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c10000.rfilter,nil,tp)
	-- 向玩家发送提示信息，提示其选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=rg:SelectSubGroup(tp,c10000.fselect,true,1,rg:GetCount(),tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的操作函数，包括解放怪兽并设置攻击力与守备力为10000。
function c10000.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的怪兽组以特殊召唤原因为由进行解放。
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
