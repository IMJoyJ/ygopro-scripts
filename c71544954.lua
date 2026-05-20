--メガロック・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。把自己墓地存在的岩石族怪兽除外才能特殊召唤。这张卡的原本攻击力·守备力变成特殊召唤时所除外的岩石族怪兽数×700的数值。
function c71544954.initial_effect(c)
	c:EnableReviveLimit()
	-- 把自己墓地存在的岩石族怪兽除外才能特殊召唤。这张卡的原本攻击力·守备力变成特殊召唤时所除外的岩石族怪兽数×700的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71544954,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c71544954.spcon)
	e1:SetTarget(c71544954.sptg)
	e1:SetOperation(c71544954.spop)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可以作为特殊召唤Cost除外的岩石族怪兽
function c71544954.spfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件判定函数，检查怪兽区域空位和墓地是否有可除外的岩石族怪兽
function c71544954.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上的主要怪兽区域是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只可以除外的岩石族怪兽
		and Duel.IsExistingMatchingCard(c71544954.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤规则的选择目标函数，让玩家选择任意数量的岩石族怪兽并记录
function c71544954.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足条件的岩石族怪兽
	local g=Duel.GetMatchingGroup(c71544954.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 给玩家发送提示信息，提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,1,g:GetCount(),nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的操作函数，将选中的怪兽除外，并根据除外数量确定并设置该卡的原本攻击力和守备力
function c71544954.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤为原因表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	local val=g:GetCount()*700
	-- 这张卡的原本攻击力·守备力变成特殊召唤时所除外的岩石族怪兽数×700的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(val)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
	g:DeleteGroup()
end
