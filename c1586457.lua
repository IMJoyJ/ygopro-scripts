--ディープ・スペース・クルーザー・ナイン
-- 效果：
-- 这张卡可以从手卡把这张卡以外的1只机械族怪兽送去墓地，从手卡特殊召唤。
function c1586457.initial_effect(c)
	-- 创建一个字段效果，用于处理特殊召唤的规则条件
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1586457.spcon)
	e1:SetTarget(c1586457.sptg)
	e1:SetOperation(c1586457.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选手牌中可以作为cost送去墓地的机械族怪兽
function c1586457.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToGraveAsCost()
end
-- 判断特殊召唤条件是否满足，包括场上是否有空位以及手牌中是否存在符合条件的怪兽
function c1586457.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前玩家的场上主怪兽区是否有可用空间
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查当前玩家手牌中是否存在至少1张符合条件的机械族怪兽
		and Duel.IsExistingMatchingCard(c1586457.filter,tp,LOCATION_HAND,0,1,c)
end
-- 设置特殊召唤的目标选择逻辑，提示玩家选择要送去墓地的怪兽
function c1586457.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家手牌中所有符合条件的机械族怪兽组成卡片组
	local g=Duel.GetMatchingGroup(c1586457.filter,tp,LOCATION_HAND,0,c)
	-- 向玩家发送提示信息，提示其选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 设置特殊召唤的效果执行逻辑，将选中的怪兽送去墓地
function c1586457.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤的理由送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
