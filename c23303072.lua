--モンタージュ・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。把手卡3张怪兽卡送去墓地的场合才能特殊召唤。这张卡的攻击力变成这张卡的特殊召唤时送去墓地的怪兽的等级合计×300的数值。
function c23303072.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置此卡的特殊召唤条件为必须满足特定条件才能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把手卡3张怪兽卡送去墓地的场合才能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23303072,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c23303072.spcon)
	e2:SetTarget(c23303072.sptg)
	e2:SetOperation(c23303072.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选手牌中可以作为召唤代价送去墓地的怪兽卡
function c23303072.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 判断是否满足特殊召唤条件，包括场上是否有空位以及手牌中是否有3张符合条件的怪兽卡
function c23303072.spcon(e,c)
	if c==nil then return true end
	-- 检查当前玩家场上主要怪兽区是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查当前玩家手牌中是否存在至少3张符合条件的怪兽卡
		and Duel.IsExistingMatchingCard(c23303072.filter,c:GetControler(),LOCATION_HAND,0,3,e:GetHandler())
end
-- 设置特殊召唤时的选择处理函数，用于选择3张怪兽卡送去墓地
function c23303072.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家手牌中所有符合条件的怪兽卡
	local g=Duel.GetMatchingGroup(c23303072.filter,tp,LOCATION_HAND,0,c)
	-- 向玩家发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:CancelableSelect(tp,3,3,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 设置特殊召唤时的处理函数，将选中的卡送去墓地并计算攻击力
function c23303072.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡组以特殊召唤理由送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	local sum=0
	local tc=g:GetFirst()
	while tc do
		local lv=tc:GetLevel()
		sum=sum+lv
		tc=g:GetNext()
	end
	-- 这张卡的攻击力变成这张卡的特殊召唤时送去墓地的怪兽的等级合计×300的数值
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(sum*300)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	g:DeleteGroup()
end
