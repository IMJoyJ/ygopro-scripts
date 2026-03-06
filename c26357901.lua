--死償不知
-- 效果：
-- ①：自己基本分比对方少的场合，可以从以下效果选择1个发动。
-- ●选持有那个相差数值以下的攻击力的对方场上1只怪兽破坏。
-- ●从自己墓地选持有那个相差数值以下的攻击力的1只怪兽特殊召唤。
function c26357901.initial_effect(c)
	-- 创建效果，设置为发动时点，条件为己方LP低于对方，目标函数为c26357901.target，处理函数为c26357901.operation
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c26357901.condition)
	e1:SetTarget(c26357901.target)
	e1:SetOperation(c26357901.operation)
	c:RegisterEffect(e1)
end
-- 效果条件：己方基本分比对方少
function c26357901.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方LP是否小于对方LP
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 破坏效果的过滤函数，筛选攻击力不超过指定值且正面表示的怪兽
function c26357901.desfilter(c,dif)
	return c:IsAttackBelow(dif) and c:IsFaceup()
end
-- 特殊召唤效果的过滤函数，筛选攻击力不超过指定值且可特殊召唤的怪兽
function c26357901.spfilter(c,dif,e,tp)
	return c:IsAttackBelow(dif) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，计算LP差值，检查是否满足破坏或特殊召唤条件，并根据条件选择发动效果
function c26357901.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算己方与对方LP的差值
	local dif=Duel.GetLP(1-tp)-Duel.GetLP(tp)
	local c=e:GetHandler()
	-- 检查对方场上是否存在攻击力不超过差值的怪兽
	local b1=Duel.IsExistingMatchingCard(c26357901.desfilter,tp,0,LOCATION_MZONE,1,nil,dif)
	-- 检查己方场上是否有空位
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方墓地是否存在攻击力不超过差值的怪兽
		and Duel.IsExistingMatchingCard(c26357901.spfilter,tp,LOCATION_GRAVE,0,1,nil,dif,e,tp)
	if chk==0 then return b1 or b2 end
	local s=0
	if b1 and not b2 then
		-- 选择发动破坏效果
		s=Duel.SelectOption(tp,aux.Stringid(26357901,0))  --"怪兽破坏"
	end
	if not b1 and b2 then
		-- 选择发动特殊召唤效果
		s=Duel.SelectOption(tp,aux.Stringid(26357901,1))+1  --"特殊召唤"
	end
	if b1 and b2 then
		-- 选择发动破坏或特殊召唤效果
		s=Duel.SelectOption(tp,aux.Stringid(26357901,0),aux.Stringid(26357901,1))  --"怪兽破坏/特殊召唤"
	end
	e:SetLabel(s)
	if s==0 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 获取满足破坏条件的怪兽数组
		local g=Duel.GetMatchingGroup(c26357901.desfilter,tp,0,LOCATION_MZONE,nil,dif)
		-- 设置破坏效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
	if s==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置特殊召唤效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
end
-- 处理效果发动，根据选择的效果类型执行破坏或特殊召唤
function c26357901.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 计算己方与对方LP的差值
	local dif=Duel.GetLP(1-tp)-Duel.GetLP(tp)
	if dif<=0 then return end
	if e:GetLabel()==0 then
		-- 提示玩家选择要破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择满足破坏条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c26357901.desfilter,tp,0,LOCATION_MZONE,1,1,nil,dif)
		if g:GetCount()>0 then
			-- 显示选中怪兽的动画效果
			Duel.HintSelection(g)
			-- 将选中的怪兽破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
	-- 判断是否选择特殊召唤效果且己方场上存在空位
	if e:GetLabel()==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足特殊召唤条件的怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c26357901.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,dif,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到己方场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
