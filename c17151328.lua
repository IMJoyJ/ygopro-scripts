--渦巻く海炎
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●从手卡把1只水属性怪兽丢弃去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
-- ●手卡1只炎属性怪兽破坏。那之后，自己可以抽1张。
-- ②：只有对方场上才有怪兽存在的场合，把墓地的这张卡除外，以自己墓地1只7·8星的水·炎属性怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果：为这张卡注册两个效果——①为发动时的效果，可在两个选项中选择1个处理（丢弃手卡水属性破坏对方表侧怪兽，或破坏手卡炎属性后可能抽卡）；②为墓地起动效果，除外自身并特殊召唤1只7·8星水·炎属性怪兽；两个效果均设定为1回合各能使用1次。
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。●从手卡把1只水属性怪兽丢弃去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。●手卡1只炎属性怪兽破坏。那之后，自己可以抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：只有对方场上才有怪兽存在的场合，把墓地的这张卡除外，以自己墓地1只7·8星的水·炎属性怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	-- 设置②效果的发动代价为把墓地中的这张卡除外（aux.bfgcost实现将这张卡除外作为cost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的cost函数：此处仅设置标记e:SetLabel(100)并返回true，不实际支付代价；真正的代价（丢弃水属性怪兽）在目标选择阶段按所选分支支付。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 筛选可作为①选项1丢弃代价的手卡怪兽：水属性、可以被丢弃且能作为代价送去墓地。
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 筛选手卡中的炎属性怪兽，用于①选项2的破坏对象。
function s.desfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end
-- ①效果的目标选择函数：先判断两个选项是否可行，让玩家选择其中一个；若选选项1，则（若需要）丢弃1只水属性怪兽作为代价，再选择对方场上1只表侧表示怪兽为对象并设置破坏信息；若选选项2，则设置破坏我方手卡1只炎属性怪兽的信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	local nocost=e:GetLabel()~=100
	-- 判断①选项1是否可行：手卡中存在可丢弃的水属性怪兽（或已满足不需要该代价的条件），并且对方场上有表侧表示怪兽可成为对象。
	local b1=(Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) or nocost) and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	-- 判断①选项2是否可行：手卡中存在炎属性怪兽。
	local b2=Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND,0,1,nil)
	if chk==0 then return b1 or b2 end
	-- 调用选项选择辅助函数，让玩家在①效果的两个选项中选择1个（返回1或2）。
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2)},  --"破坏对方场上表侧表示怪兽"
			{b2,aux.Stringid(id,3)})  --"手卡1只炎属性怪兽破坏"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		if not nocost then
			-- 提示玩家选择要送去墓地的卡，用于选择丢弃的水属性怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 执行①选项1的发动代价：从手卡丢弃1只满足costfilter的水属性怪兽去墓地，丢弃原因为代价。
			Duel.DiscardHand(tp,s.costfilter,1,1,REASON_DISCARD+REASON_COST)
		end
		-- 提示玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上1只表侧表示怪兽作为效果对象，并登记为当前连锁的对象。
		local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置操作信息：本次效果将破坏对象g，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		e:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY)
		-- 设置操作信息：本次效果将破坏我方手卡中的1只炎属性怪兽（不取对象，targets为nil）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
	end
end
-- ①效果的处理：若之前选择选项1，则破坏对象怪兽；若选择选项2，则从手卡选1只炎属性怪兽破坏，若破坏成功且我方可以抽卡，则询问是否抽1张，并用BreakEffect使抽卡作为后续处理。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取此效果的对象怪兽（第一个目标）。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
			-- 将对象怪兽以效果破坏。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	else
		-- 提示玩家选择要破坏的卡（用于选择手卡中的炎属性怪兽）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从手卡选择1只炎属性怪兽（处理时选择，不取对象）。
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND,0,1,1,nil)
		-- 如果该炎属性怪兽被效果破坏成功，并且我方可以抽卡，则继续后续的抽卡判定。
		if Duel.Destroy(g,REASON_EFFECT)>0 and Duel.IsPlayerCanDraw(tp,1)
			-- 让玩家选择是否抽1张卡。
			and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否抽卡？"
			-- 中断当前效果处理，使后续抽卡效果作为另一次处理（制造时点，避免同时处理）。
			Duel.BreakEffect()
			-- 我方抽1张卡，原因为效果。
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：自己场上没有怪兽，且对方场上有怪兽存在（即只有对方场上有怪兽）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 自己场上的怪兽区域没有怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 对方场上有怪兽存在。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- ②效果的特殊召唤对象筛选：墓地中的水属性或炎属性、等级7或8、且可以被当前效果特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER+ATTRIBUTE_FIRE) and c:IsLevel(7,8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标选择函数：确认自己场上有可用空格，且墓地存在符合条件的对象；若存在则选择对象并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 发动条件检查：自己主要怪兽区有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且墓地中存在1只满足条件的怪兽可作为效果对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择1只符合条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将特殊召唤对象g。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的处理：若对象怪兽仍与效果关联且不受王家长眠之谷影响，则将其以表侧表示特殊召唤到我方场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取特殊召唤的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象是否仍与效果关联，并通过王家长眠之谷的过滤（若对象适用墓地效果无效则不能特殊召唤）。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧表示特殊召唤到我方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
