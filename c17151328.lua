--渦巻く海炎
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●从手卡把1只水属性怪兽丢弃去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
-- ●手卡1只炎属性怪兽破坏。那之后，自己可以抽1张。
-- ②：只有对方场上才有怪兽存在的场合，把墓地的这张卡除外，以自己墓地1只7·8星的水·炎属性怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册两个效果：①发动效果和②特殊召唤效果
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。
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
	-- 效果②的发动需要将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动费用设置为100（表示无费用）
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 过滤函数：水属性且可丢弃且可送入墓地的怪兽
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 过滤函数：炎属性怪兽
function s.desfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 效果①的发动选择处理：选择破坏对方怪兽或破坏手卡炎属性怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	local nocost=e:GetLabel()~=100
	-- 条件1：手卡有水属性怪兽可丢弃或已跳过费用，且对方场上存在表侧表示怪兽
	local b1=(Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) or nocost) and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	-- 条件2：手卡有炎属性怪兽可破坏
	local b2=Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND,0,1,nil)
	if chk==0 then return b1 or b2 end
	-- 玩家选择发动选项
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2)},  --"破坏对方场上表侧表示怪兽"
			{b2,aux.Stringid(id,3)})  --"手卡1只炎属性怪兽破坏"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		if not nocost then
			-- 提示玩家选择要送入墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 玩家丢弃1张符合条件的水属性怪兽到墓地
			Duel.DiscardHand(tp,s.costfilter,1,1,REASON_DISCARD+REASON_COST)
		end
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上1只表侧表示怪兽作为目标
		local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置操作信息：破坏目标怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		e:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY)
		-- 设置操作信息：破坏手卡1张炎属性怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
	end
end
-- 效果①的发动处理：根据选择的选项执行破坏或抽卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取效果的目标怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
			-- 破坏目标怪兽
			Duel.Destroy(tc,REASON_EFFECT)
		end
	else
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择手卡1张炎属性怪兽
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND,0,1,1,nil)
		-- 破坏炎属性怪兽并判断是否可以抽卡
		if Duel.Destroy(g,REASON_EFFECT)>0 and Duel.IsPlayerCanDraw(tp,1)
			-- 询问玩家是否抽卡
			and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否抽卡？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 玩家抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 效果②的发动条件：对方场上存在怪兽，己方场上不存在怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 己方场上不存在怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 对方场上存在怪兽
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 过滤函数：7或8星且同时具有水和炎属性的怪兽，且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER+ATTRIBUTE_FIRE) and c:IsLevel(7,8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动选择处理：选择墓地符合条件的怪兽特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 判断己方场上是否有特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断己方墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的发动处理：将目标怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且未受王家长眠之谷影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽特殊召唤到己方场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
