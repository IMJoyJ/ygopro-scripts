--大紅蓮魔闘士
-- 效果：
-- 这张卡不能通常召唤。「大红莲魔斗士」1回合1次在让效果怪兽以外的自己墓地最多3只怪兽回到卡组·额外卡组的场合才能从手卡·墓地特殊召唤。
-- ①：这个方法特殊召唤的这张卡的攻击力上升因为那次特殊召唤而回到卡组的通常怪兽数量×800。
-- ②：1回合1次，以场上1只怪兽和效果怪兽以外的自己墓地1只怪兽为对象才能发动。作为对象的场上的怪兽破坏，作为对象的墓地的怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：特殊召唤条件、特殊召唤程序、起动效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置该卡不能通常召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- 设置该卡从手牌或墓地特殊召唤的条件为：将1~3只非效果怪兽送入卡组/额外卡组，且只能发动一次
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spscon)
	e2:SetTarget(s.spstg)
	e2:SetOperation(s.spsop)
	c:RegisterEffect(e2)
	-- 设置该卡的起动效果：破坏场上一只怪兽并特殊召唤墓地一只怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏并特殊召唤"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 过滤器函数，用于筛选可送入卡组或额外卡组的怪兽（非效果怪兽）
function s.cfilter(c)
	return not c:IsType(TYPE_EFFECT) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
-- 检查是否满足特殊召唤条件：是否有1~3只符合条件的怪兽可送入卡组，且场上是否有空位
function s.spscon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家墓地所有符合条件的怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,c)
	-- 若场上没有空位则不能特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	-- 检查是否存在1~3只符合条件的怪兽组合
	local res=g:CheckSubGroup(aux.TRUE,1,3)
	return res
end
-- 设置特殊召唤的目标选择函数：选择1~3只怪兽送入卡组
function s.spstg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家墓地所有符合条件的怪兽
	local mg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,c)
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从符合条件的怪兽中选择1~3只作为目标
	local sg=mg:SelectSubGroup(tp,aux.TRUE,true,1,3)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 设置特殊召唤的操作函数：将选中的怪兽送入卡组并计算攻击力提升值
function s.spsop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	local gg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #gg>0 then
		-- 显示被选为对象的怪兽动画效果
		Duel.HintSelection(gg)
	end
	-- 将选中的怪兽送入卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_SPSUMMON)
	local ag=g:Filter(Card.IsLocation,nil,LOCATION_DECK):Filter(Card.IsType,nil,TYPE_NORMAL)
	-- 设置攻击力提升效果，提升值等于送回卡组的通常怪兽数量×800
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetValue(ag:GetCount()*800)
	c:RegisterEffect(e1)
	g:DeleteGroup()
end
-- 过滤器函数，用于筛选场上可放置怪兽的位置
function s.desfilter(c,tp)
	-- 检查目标怪兽是否能被放置到场上
	return Duel.GetMZoneCount(tp,c)>0
end
-- 过滤器函数，用于筛选可特殊召唤的怪兽（非效果怪兽）
function s.spfilter(c,e,tp)
	return not c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置破坏并特殊召唤的效果目标选择函数：选择场上的一个怪兽和墓地的一个怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	-- 检查是否能选择场上的一个怪兽作为破坏对象
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
		-- 检查是否能选择墓地的一个怪兽作为特殊召唤对象
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一只怪兽作为破坏对象
	local g1=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地一只怪兽作为特殊召唤对象
	local g2=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：破坏一个怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 设置操作信息：特殊召唤一个怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
	e:SetLabelObject(g1:GetFirst())
end
-- 设置破坏并特殊召唤的效果操作函数：破坏选中的怪兽并特殊召唤选中的怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的两个目标怪兽
	local tc1,tc2=Duel.GetFirstTarget()
	if tc1~=e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	-- 判断第一个目标怪兽是否有效且为怪兽并被破坏
	if tc1:IsRelateToEffect(e) and tc1:IsType(TYPE_MONSTER) and Duel.Destroy(tc1,REASON_EFFECT)>0
		-- 判断第二个目标怪兽是否有效且未受王家长眠之谷影响
		and tc2:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc2) then
		-- 将第二个目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
	end
end
