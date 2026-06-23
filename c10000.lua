--万物創世龍
-- 效果：
-- 这张卡不能通常召唤。把攻击力合计和守备力合计的总计直到10000以上的自己场上的怪兽解放的场合才能特殊召唤。
-- ①：这个方法特殊召唤的这张卡的攻击力·守备力变成10000。
function c10000.initial_effect(c)
	c:EnableReviveLimit()
	-- 创建单体效果，设置特殊召唤条件。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这个方法特殊召唤的这张卡的攻击力·守备力变成10000。
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
-- 定义一个过滤器函数，用于筛选控制者为当前玩家或表侧表示的卡片。
function c10000.rfilter(c,tp)
	return c:IsControler(tp) or c:IsFaceup()
end
-- 定义一个过滤器函数，计算一张卡片的攻击力和守备力的总和。
function c10000.sumfilter(c)
	return c:GetAttack()+c:GetDefense()
end
-- 定义一个选择器函数，用于检查卡片组的总计是否大于等于10000，并验证主怪兽区是否有足够的空位。
function c10000.fselect(g,tp)
	-- 设置Duel.CheckWithSum，Group.CheckSubGroup等函数已选择/必须选择的卡片
	Duel.SetSelectedCard(g)
	-- 检查卡片组的总和是否大于10000，并且使用aux.mzctcheckrel函数验证主怪兽区是否有足够的空位。
	return g:CheckWithSumGreater(c10000.sumfilter,10000) and aux.mzctcheckrel(g,tp,REASON_SPSUMMON)
end
-- 定义特殊召唤条件判断函数，如果当前回合结束则返回true。获取控制者，筛选可解放的怪兽，并检查是否存在满足条件的子组。
function c10000.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家的可释放卡片组，并使用c10000.rfilter进行过滤。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c10000.rfilter,nil,tp)
	return rg:CheckSubGroup(c10000.fselect,1,rg:GetCount(),tp)
end
-- 定义特殊召唤目标选择函数，获取玩家的可释放卡片组，提示玩家选择要解放的卡片，并保存选定的子组。
function c10000.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家的可释放卡片组，并使用c10000.rfilter进行过滤。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c10000.rfilter,nil,tp)
	-- 向玩家发送提示信息，要求其选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,c10000.fselect,true,1,rg:GetCount(),tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 定义特殊召唤执行函数，释放选定的卡片组，创建单体效果将攻击力和守备力设置为10000，并删除卡片组。
function c10000.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以REASON_SPSUMMON原因释放卡片组g。
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
