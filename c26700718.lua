--スネークアイ追走劇
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·卡组·墓地把1只「迪亚贝尔斯塔尔」怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
-- ②：自己·对方的结束阶段，把墓地的这张卡除外，以自己场上1张当作永续魔法卡使用的怪兽卡为对象才能发动。那张卡特殊召唤。
local s,id,o=GetID()
-- 注册两个效果，分别对应①和②效果
function s.initial_effect(c)
	-- ①：从自己的手卡·卡组·墓地把1只「迪亚贝尔斯塔尔」怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"当作永续魔法卡放置"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，把墓地的这张卡除外，以自己场上1张当作永续魔法卡使用的怪兽卡为对象才能发动。那张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	-- 效果②的发动需要把此卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.spstg)
	e2:SetOperation(s.spsop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选「迪亚贝尔斯塔尔」怪兽
function s.filter1(c)
	return c:IsSetCard(0x119b) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 效果①的发动条件判断，检查是否有满足条件的怪兽以及场上是否有空位
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家在魔法与陷阱区域的可用空位数
		local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
		-- 判断是否满足发动条件：存在「迪亚贝尔斯塔尔」怪兽且场上存在空位
		return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil) and ct>0
	end
end
-- 效果①的处理函数，将选中的怪兽当作永续魔法卡放置到场上
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断场上是否有空位，没有则不执行后续操作
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择满足条件的「迪亚贝尔斯塔尔」怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽移动到场上并设置为永续魔法卡
		Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true)
		-- 将选中的怪兽类型更改为永续魔法卡
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数，用于筛选可以特殊召唤的永续魔法卡
function s.sfilter(c,e,tp)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:GetType()&TYPE_CONTINUOUS+TYPE_SPELL==TYPE_CONTINUOUS+TYPE_SPELL
		and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动条件判断，检查场上是否有满足条件的永续魔法卡
function s.spstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.sfilter(chkc,e,tp) end
	-- 判断场上是否有怪兽区域可用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在满足条件的永续魔法卡
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的永续魔法卡作为特殊召唤对象
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，确定特殊召唤的目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理函数，将选中的永续魔法卡特殊召唤
function s.spsop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 若目标卡仍存在于场上则将其特殊召唤
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
