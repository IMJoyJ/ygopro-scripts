--スターダストン
-- 效果：
-- 这张卡不能通常召唤。把自己场上表侧表示存在的名字带有「尘妖」的怪兽任意数量送去墓地的场合才能特殊召唤。这张卡的攻击力·守备力变成送去墓地的那些怪兽数量×1000的数值。只要这张卡在场上表侧表示存在，对方不能把场上盖放的魔法·陷阱卡发动，对方不能把怪兽反转召唤·特殊召唤。自己场上的怪兽数量比对方场上的怪兽数量多的场合，这张卡破坏。
function c95403418.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上表侧表示存在的名字带有「尘妖」的怪兽任意数量送去墓地的场合才能特殊召唤。这张卡的攻击力·守备力变成送去墓地的那些怪兽数量×1000的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c95403418.spcon)
	e2:SetTarget(c95403418.sptg)
	e2:SetOperation(c95403418.spop)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，对方不能把场上盖放的魔法·陷阱卡发动
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c95403418.aclimit)
	c:RegisterEffect(e3)
	-- 对方不能把怪兽反转召唤·特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e5)
	-- 自己场上的怪兽数量比对方场上的怪兽数量多的场合，这张卡破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_SELF_DESTROY)
	e6:SetCondition(c95403418.descon)
	c:RegisterEffect(e6)
end
-- 判断发动的卡是否为场上盖放的魔法·陷阱卡
function c95403418.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:IsLocation(LOCATION_SZONE) and rc:IsFacedown()
end
-- 过滤场上表侧表示、可以送去墓地的「尘妖」怪兽
function c95403418.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x80) and c:IsAbleToGraveAsCost()
end
-- 过滤主要怪兽区域（0-4号格）的怪兽
function c95403418.mzfilter(c)
	return c:GetSequence()<5
end
-- 特殊召唤规则的条件：检查场上是否有可作为代阶的「尘妖」怪兽，并确保有足够的怪兽区域空位
function c95403418.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有表侧表示且可以送去墓地的「尘妖」怪兽
	local mg=Duel.GetMatchingGroup(c95403418.filter,tp,LOCATION_MZONE,0,nil)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=-ft+1
	return mg:GetCount()>0 and (ft>0 or mg:IsExists(c95403418.mzfilter,ct,nil))
end
-- 特殊召唤规则的准备：让玩家选择任意数量的「尘妖」怪兽送去墓地，并确保特殊召唤后有足够的怪兽区域空位
function c95403418.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有表侧表示且可以送去墓地的「尘妖」怪兽
	local g=Duel.GetMatchingGroup(c95403418.filter,tp,LOCATION_MZONE,0,nil)
	-- 在客户端显示提示信息，要求玩家选择送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择至少1只「尘妖」怪兽，并使用aux.mzctcheck检查是否能腾出足够的怪兽区域空位
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,1,#g,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行：将选中的怪兽送去墓地，并根据送去墓地的怪兽数量设置此卡的攻击力和守备力
function c95403418.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽送去墓地，并返回实际送去墓地的怪兽数量
	local ct=Duel.SendtoGrave(g,REASON_SPSUMMON)
	-- 这张卡的攻击力·守备力变成送去墓地的那些怪兽数量×1000的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(ct*1000)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
	g:DeleteGroup()
end
-- 自我破坏效果的条件：自己场上的怪兽数量比对方场上的怪兽数量多
function c95403418.descon(e)
	local tp=e:GetHandlerPlayer()
	-- 比较双方场上的怪兽数量，若自己场上的怪兽数量多于对方则返回true
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)<Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
