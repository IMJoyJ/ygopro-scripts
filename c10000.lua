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
-- 过滤满足“由自己控制”或“在场上表侧表示”的卡片，用于后续解放
function c10000.rfilter(c,tp)
	return c:IsControler(tp) or c:IsFaceup()
end
-- 获取并返回目标怪兽的当前攻击力与守备力的合计值
function c10000.sumfilter(c)
	return c:GetAttack()+c:GetDefense()
end
-- 检查选中的怪兽组是否满足“合计攻击力与守备力的总和在10000以上”以及“解放这些怪兽后主怪兽区是否有空位”的条件
function c10000.fselect(g,tp)
	-- 将已选择的怪兽卡片组作为后续求和检查的基准卡
	Duel.SetSelectedCard(g)
	-- 检查怪兽组的攻击力与守备力总计是否在10000以上，并且在释放这些怪兽后主怪兽区是否有空位
	return g:CheckWithSumGreater(c10000.sumfilter,10000) and aux.mzctcheckrel(g,tp,REASON_SPSUMMON)
end
-- 特殊召唤的条件函数：检查玩家可解放的卡片中是否存在能满足特殊召唤解放条件的卡片组
function c10000.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家场上可用于特殊召唤解放的怪兽，并过滤出由自己控制或表侧表示的怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c10000.rfilter,nil,tp)
	return rg:CheckSubGroup(c10000.fselect,1,rg:GetCount(),tp)
end
-- 特殊召唤的目标/步骤函数：提示玩家选择要解放的怪兽组，若成功选择则将其保存以便后续操作
function c10000.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上可用于特殊召唤解放的怪兽，并过滤出由自己控制或表侧表示的怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c10000.rfilter,nil,tp)
	-- 向特殊召唤的控制者提示“请选择要解放的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,c10000.fselect,true,1,rg:GetCount(),tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤的操作函数：解放选中的怪兽，并将此卡特殊召唤，同时使其攻击力·守备力变成10000
function c10000.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为原因，解放所选择的怪兽组
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
