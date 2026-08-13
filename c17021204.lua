--マザー・スパイダー
-- 效果：
-- 自己墓地存在的怪兽只有昆虫族的场合，这张卡可以把对方场上表侧守备表示存在的2只怪兽送去墓地，从手卡特殊召唤。
function c17021204.initial_effect(c)
	-- 自己墓地存在的怪兽只有昆虫族的场合，这张卡可以把对方场上表侧守备表示存在的2只怪兽送去墓地，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c17021204.spcon)
	e1:SetTarget(c17021204.sptg)
	e1:SetOperation(c17021204.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：怪兽为表侧守备表示，且能够作为代价（cost）被送去墓地。
function c17021204.spfilter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsAbleToGraveAsCost()
end
-- 过滤条件：检测怪兽种族是否不是昆虫族；用于判断墓地是否存在非昆虫族怪兽。
function c17021204.cfilter(c)
	return c:GetRace()~=RACE_INSECT
end
-- 检查玩家tp的墓地是否存在怪兽且所有怪兽均为昆虫族（即墓地怪兽只有昆虫族），作为特殊召唤条件之一。
function c17021204.check(tp)
	-- 获取玩家tp墓地的所有怪兽卡，存入组g，用于后续判断墓地怪兽是否全为昆虫族。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:GetCount()~=0 and not g:IsExists(c17021204.cfilter,1,nil)
end
-- 特殊召唤规则效果的条件判断：c为nil时表示该规则召唤手续本身成立；实际召唤时需检查自己主要怪兽区有空位、对方场上有2只可送墓的表侧守备怪兽，且自己墓地怪兽只有昆虫族。
function c17021204.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的控制者（自己）的主要怪兽区域是否有空位，以确保能够特殊召唤。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查这张卡控制者的对方场上是否存在至少2只满足spfilter的怪兽（表侧守备表示且可作为代价送去墓地），用于作为特殊召唤的代价。
		and Duel.IsExistingMatchingCard(c17021204.spfilter,c:GetControler(),0,LOCATION_MZONE,2,nil)
		and c17021204.check(c:GetControler())
end
-- 特殊召唤规则效果的目标/代价选择处理：从对方场上选择2只符合条件的表侧守备怪兽作为送去墓地的代价；若选择成功则保存该组并返回true，取消则返回false。
function c17021204.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取对方场上满足spfilter条件的所有怪兽（表侧守备且可作cost送墓），供玩家选择。
	local g=Duel.GetMatchingGroup(c17021204.spfilter,tp,0,LOCATION_MZONE,nil)
	-- 显示选择提示，提示玩家选择要送去墓地的卡（HINTMSG_TOGRAVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则效果的实际处理：取出之前选择的怪兽组，将它们作为特殊召唤代价送去墓地，然后清理该组。
function c17021204.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽组送去墓地，理由为特殊召唤（REASON_SPSUMMON），作为该规则特殊召唤的手续代价。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
