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
-- 过滤场上属于自己且表侧表示的怪兽
function c10000.rfilter(c,tp)
	return c:IsControler(tp) or c:IsFaceup()
end
-- 返回怪兽的当前攻击力与守备力的合计值
function c10000.sumfilter(c)
	return c:GetAttack()+c:GetDefense()
end
-- 判断选择的解放怪兽攻守总和是否达到10000以上且解放后有足够的区域完成特殊召唤
function c10000.fselect(g,tp)
	-- 设置已选取的卡片以供后续的求和及空位检查
	Duel.SetSelectedCard(g)
	-- 判断所选怪兽卡片组 of 攻守总计是否在10000以上，且在解放后主怪兽区是否有空位进行特殊召唤
	return g:CheckWithSumGreater(c10000.sumfilter,10000) and aux.mzctcheckrel(g,tp,REASON_SPSUMMON)
end
-- 特殊召唤条件的检查函数
function c10000.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上可用于特殊召唤解放的卡片并进行过滤
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c10000.rfilter,nil,tp)
	return rg:CheckSubGroup(c10000.fselect,1,rg:GetCount(),tp)
end
-- 特殊召唤的目标选择与处理函数
function c10000.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上可用于特殊召唤解放的卡片并进行过滤
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c10000.rfilter,nil,tp)
	-- 向玩家发送提示，要求选择用于解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,c10000.fselect,true,1,rg:GetCount(),tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤的具体操作函数
function c10000.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的怪兽以进行特殊召唤
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
