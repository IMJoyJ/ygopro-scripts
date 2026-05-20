--死霊の巣
-- 效果：
-- 除外自己的墓地存在的任意数目的怪兽，破坏1只场上的和这个数目相同等级的表侧表示的怪兽。
function c6733059.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
	-- 除外自己的墓地存在的任意数目的怪兽，破坏1只场上的和这个数目相同等级的表侧表示的怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6733059,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCost(c6733059.cost)
	e2:SetOperation(c6733059.operation)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可以作为代价除外的怪兽卡
function c6733059.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 过滤场上等级小于等于墓地可除外怪兽最大数量的表侧表示怪兽
function c6733059.tfilter(c,lv)
	return c:IsFaceup() and c:IsLevelBelow(lv)
end
-- 效果发动的代价处理函数，用于计算并执行除外墓地怪兽的操作
function c6733059.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己墓地中所有可作为代价除外的怪兽
		local cg=Duel.GetMatchingGroup(c6733059.cfilter,tp,LOCATION_GRAVE,0,nil)
		-- 获取场上所有等级小于等于墓地可除外怪兽总数的表侧表示怪兽
		local tg=Duel.GetMatchingGroup(c6733059.tfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg:GetCount())
		return tg:GetCount()>0
	end
	e:SetLabel(0)
	-- 获取自己墓地中所有可作为代价除外的怪兽
	local cg=Duel.GetMatchingGroup(c6733059.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 获取场上所有等级小于等于墓地可除外怪兽总数的表侧表示怪兽
	local tg=Duel.GetMatchingGroup(c6733059.tfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg:GetCount())
	local lvt={}
	local tc=tg:GetFirst()
	while tc do
		local tlv=tc:GetLevel()
		lvt[tlv]=tlv
		tc=tg:GetNext()
	end
	local pc=1
	local _,lvmax=tg:GetMaxGroup(Card.GetLevel)
	local max=math.min(lvmax,255)
	for i=1,max do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	-- 提示玩家选择要除外的怪兽数量
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(6733059,2))  --"请选择要除外的怪兽的数量"
	-- 让玩家宣言要除外的怪兽数量（即要破坏的怪兽等级）
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=cg:Select(tp,lv,lv,nil)
	-- 将选中的怪兽作为发动代价表侧表示除外
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	-- 设置效果处理的操作信息为破坏1张怪兽卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
	-- 将宣言的数值（等级）保存为效果参数
	Duel.SetTargetParam(lv)
end
-- 过滤场上表侧表示且等级等于宣言数值的怪兽
function c6733059.dfilter(c,lv)
	return c:IsFaceup() and c:IsLevel(lv)
end
-- 效果处理函数，用于破坏1只场上等级等于除外数量的表侧表示怪兽
function c6733059.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动代价阶段保存的等级参数
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if lv==0 then return end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1只场上等级等于宣言数值的表侧表示怪兽
	local g=Duel.SelectMatchingCard(tp,c6733059.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,lv)
	-- 破坏选中的怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
