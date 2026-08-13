--死償不知
-- 效果：
-- ①：自己基本分比对方少的场合，可以从以下效果选择1个发动。
-- ●选持有那个相差数值以下的攻击力的对方场上1只怪兽破坏。
-- ●从自己墓地选持有那个相差数值以下的攻击力的1只怪兽特殊召唤。
function c26357901.initial_effect(c)
	-- ①：自己基本分比对方少的场合，可以从以下效果选择1个发动；●选持有那个相差数值以下的攻击力的对方场上1只怪兽破坏；●从自己墓地选持有那个相差数值以下的攻击力的1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c26357901.condition)
	e1:SetTarget(c26357901.target)
	e1:SetOperation(c26357901.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数：自己基本分比对方少的场合，效果才能发动。
function c26357901.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家LP是否小于对方LP，作为发动条件。
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 定义破坏分支的筛选函数：对方场上的表侧表示怪兽，且攻击力不高于LP差值。
function c26357901.desfilter(c,dif)
	return c:IsAttackBelow(dif) and c:IsFaceup()
end
-- 定义特殊召唤分支的筛选函数：自己墓地的怪兽，攻击力不高于LP差值，且能够被特殊召唤（满足苏生限制和召唤条件）。
function c26357901.spfilter(c,dif,e,tp)
	return c:IsAttackBelow(dif) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果的发动与处理前目标函数：确认可发动后，检查可选分支，让玩家选择破坏或特殊召唤，并设置对应的效果分类和操作信息。
function c26357901.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算对方LP与我方LP的差值（对方LP - 我方LP）。
	local dif=Duel.GetLP(1-tp)-Duel.GetLP(tp)
	local c=e:GetHandler()
	-- 检查对方场上是否存在1只以上攻击力在差值以下的表侧表示怪兽，判断破坏分支是否可选。
	local b1=Duel.IsExistingMatchingCard(c26357901.desfilter,tp,0,LOCATION_MZONE,1,nil,dif)
	-- 检查自己主要怪兽区是否有可用空格，作为特殊召唤分支可选的条件之一。
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查自己墓地是否存在1只以上攻击力在差值以下且可特殊召唤的怪兽，与空格条件共同决定特殊召唤分支是否可选。
		and Duel.IsExistingMatchingCard(c26357901.spfilter,tp,LOCATION_GRAVE,0,1,nil,dif,e,tp)
	if chk==0 then return b1 or b2 end
	local s=0
	if b1 and not b2 then
		-- 当只有破坏分支可选时，让玩家选择'怪兽破坏'选项，返回0存入标签，表示选择破坏。
		s=Duel.SelectOption(tp,aux.Stringid(26357901,0))  --"怪兽破坏"
	end
	if not b1 and b2 then
		-- 当只有特殊召唤分支可选时，让玩家选择'特殊召唤'选项，将返回值+1存入标签，表示选择特殊召唤。
		s=Duel.SelectOption(tp,aux.Stringid(26357901,1))+1  --"特殊召唤"
	end
	if b1 and b2 then
		-- 当两个分支都可选时，显示'怪兽破坏/特殊召唤'两个选项，玩家选择后返回的序号作为所选分支的标签。
		s=Duel.SelectOption(tp,aux.Stringid(26357901,0),aux.Stringid(26357901,1))  --"怪兽破坏/特殊召唤"
	end
	e:SetLabel(s)
	if s==0 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 获取所有满足破坏条件的对方怪兽（作为操作信息中可能破坏的对象集合）。
		local g=Duel.GetMatchingGroup(c26357901.desfilter,tp,0,LOCATION_MZONE,nil,dif)
		-- 设置本连锁的破坏操作信息：对象为上述可能被破坏的卡，数量为1，用于连锁检测（如星尘龙等）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
	if s==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置本连锁的特殊召唤操作信息：由于不取对象，对象为nil，数量为1，玩家为自己，位置为墓地。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
end
-- 定义效果处理函数：根据发动时选择并保存的分支标签，执行对应的破坏或特殊召唤处理。
function c26357901.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新计算对方LP与我方LP的差值。
	local dif=Duel.GetLP(1-tp)-Duel.GetLP(tp)
	if dif<=0 then return end
	if e:GetLabel()==0 then
		-- 给予玩家'请选择要破坏的卡'的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方场上选择1只满足条件（攻击力在差值以下且表侧表示）的怪兽。
		local g=Duel.SelectMatchingCard(tp,c26357901.desfilter,tp,0,LOCATION_MZONE,1,1,nil,dif)
		if g:GetCount()>0 then
			-- 显示所选怪兽被选中的动画，并将其记录为当前连锁的对象。
			Duel.HintSelection(g)
			-- 将选择的对方怪兽破坏，破坏原因视为效果。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
	-- 若发动时选择的是特殊召唤分支，且自己主要怪兽区仍有空格，则进入特殊召唤处理。
	if e:GetLabel()==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 给予玩家'请选择要特殊召唤的卡'的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 使用王家长眠之谷过滤器筛选，从自己墓地选择1只攻击力在差值以下且可特殊召唤的怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c26357901.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,dif,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
