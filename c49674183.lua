--魔天使ローズ・ソーサラー
-- 效果：
-- 这张卡可以让「魔天使 蔷薇之巫师」以外的自己场上表侧表示存在的1只植物族怪兽回到手卡，从手卡特殊召唤。这个方法特殊召唤的这张卡从场上离开的场合从游戏中除外。
function c49674183.initial_effect(c)
	-- 创建一个字段效果，用于处理特殊召唤的条件、目标和操作
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c49674183.spcon)
	e1:SetTarget(c49674183.sptg)
	e1:SetOperation(c49674183.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的植物族怪兽（表侧表示、可送入手卡、且场上存在可用怪兽区）
function c49674183.spfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and not c:IsCode(49674183) and c:IsAbleToHandAsCost()
		-- 检查目标怪兽所在玩家场上是否存在可用怪兽区
		and Duel.GetMZoneCount(tp,c)>0
end
-- 判断特殊召唤条件是否满足：场上有符合条件的植物族怪兽
function c49674183.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检测场上是否存在至少一张满足过滤条件的怪兽
	return Duel.IsExistingMatchingCard(c49674183.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 选择要送入手卡的怪兽作为特殊召唤的代价
function c49674183.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有满足条件的植物族怪兽作为可选目标
	local g=Duel.GetMatchingGroup(c49674183.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 提示玩家选择要返回手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤后的处理：将选定怪兽送回手卡并设置离场时除外的效果
function c49674183.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定怪兽送回手卡，作为特殊召唤的代价
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
	-- 这个方法特殊召唤的这张卡从场上离开的场合从游戏中除外
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1,true)
end
