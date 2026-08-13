--モンタージュ・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。把手卡3张怪兽卡送去墓地的场合才能特殊召唤。这张卡的攻击力变成这张卡的特殊召唤时送去墓地的怪兽的等级合计×300的数值。
function c23303072.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把手卡3张怪兽卡送去墓地的场合才能特殊召唤。
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
-- 筛选可作为特殊召唤代价送去墓地的手卡怪兽：需为怪兽卡且可以作为代价送去墓地。
function c23303072.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤手续的发动条件：c为nil时表示系统查询返回true；c为具体卡时，要求其控制者场上有可用的主要怪兽区空格，且手卡中至少存在3张满足filter条件的怪兽卡（不含合成龙自身）。
function c23303072.spcon(e,c)
	if c==nil then return true end
	-- 检查该卡控制者的主要怪兽区是否有空位。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少3张满足filter条件的怪兽卡（排除合成龙自身），用于作为特殊召唤的COST。
		and Duel.IsExistingMatchingCard(c23303072.filter,c:GetControler(),LOCATION_HAND,0,3,e:GetHandler())
end
-- 特殊召唤手续的目标选择：从手卡获取所有可作为COST的怪兽，提示玩家选择3张（可取消）；选择成功则保存为效果标签对象并返回true，否则返回false。
function c23303072.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家手卡中满足filter条件且不是合成龙自身的所有怪兽卡，构成候选卡片组。
	local g=Duel.GetMatchingGroup(c23303072.filter,tp,LOCATION_HAND,0,c)
	-- 向玩家显示选择提示，提示内容为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:CancelableSelect(tp,3,3,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤处理：取出保存的3张怪兽卡全部送去墓地，遍历累加这些怪兽的等级，为合成龙注册攻击力变成等级合计×300的效果（离场时重置），最后删除临时卡片组。
function c23303072.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的3张手卡怪兽作为特殊召唤的代价送去墓地，送墓原因为特殊召唤（REASON_SPSUMMON）。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	local sum=0
	local tc=g:GetFirst()
	while tc do
		local lv=tc:GetLevel()
		sum=sum+lv
		tc=g:GetNext()
	end
	-- 这张卡的攻击力变成这张卡的特殊召唤时送去墓地的怪兽的等级合计×300的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(sum*300)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	g:DeleteGroup()
end
