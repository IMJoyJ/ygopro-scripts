--マザー・スパイダー
-- 效果：
-- 自己墓地存在的怪兽只有昆虫族的场合，这张卡可以把对方场上表侧守备表示存在的2只怪兽送去墓地，从手卡特殊召唤。
function c17021204.initial_effect(c)
	-- 创建一个字段效果，用于处理特殊召唤的规则条件
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
-- 过滤函数，用于筛选表侧守备表示且可以作为cost送去墓地的怪兽
function c17021204.spfilter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsAbleToGraveAsCost()
end
-- 过滤函数，用于筛选非昆虫族的怪兽
function c17021204.cfilter(c)
	return c:GetRace()~=RACE_INSECT
end
-- 检查玩家墓地中的怪兽数量是否大于0且全部为昆虫族
function c17021204.check(tp)
	-- 获取玩家墓地中所有怪兽的卡片组
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:GetCount()~=0 and not g:IsExists(c17021204.cfilter,1,nil)
end
-- 判断特殊召唤条件是否满足：场上存在空位、对方场上存在至少2只表侧守备表示的怪兽、己方墓地怪兽全部为昆虫族
function c17021204.spcon(e,c)
	if c==nil then return true end
	-- 检查己方场上是否有足够的怪兽区域用于特殊召唤
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查对方场上是否存在至少2只表侧守备表示的怪兽
		and Duel.IsExistingMatchingCard(c17021204.spfilter,c:GetControler(),0,LOCATION_MZONE,2,nil)
		and c17021204.check(c:GetControler())
end
-- 设置特殊召唤的目标选择逻辑：从对方场上选择2只表侧守备表示的怪兽送去墓地
function c17021204.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取对方场上所有表侧守备表示的怪兽组
	local g=Duel.GetMatchingGroup(c17021204.spfilter,tp,0,LOCATION_MZONE,nil)
	-- 向玩家发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的操作：将之前选择的怪兽送去墓地并从手卡特殊召唤
function c17021204.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标怪兽以特殊召唤的理由送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
