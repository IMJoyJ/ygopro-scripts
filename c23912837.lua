--影光の聖選士
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己墓地1只「影依」怪兽为对象才能发动。那只怪兽表侧守备表示或里侧守备表示特殊召唤。
-- ②：可以从自己墓地把这张卡和1张「影依」卡除外，从以下效果选择1个发动。
-- ●自己场上1只里侧表示怪兽变成表侧守备表示。
-- ●自己场上1只表侧表示怪兽变成里侧守备表示。
function c23912837.initial_effect(c)
	-- 效果原文：这个卡名的①②的效果1回合只能有1次使用其中任意1个。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23912837,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,23912837)
	e1:SetTarget(c23912837.target)
	e1:SetOperation(c23912837.operation)
	c:RegisterEffect(e1)
	-- 效果原文：①：以自己墓地1只「影依」怪兽为对象才能发动。那只怪兽表侧守备表示或里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23912837,1))  --"选择效果发动"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e2:SetCountLimit(1,23912837)
	e2:SetCost(c23912837.poscost)
	e2:SetTarget(c23912837.postg)
	e2:SetOperation(c23912837.posop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选满足「影依」卡组且可以特殊召唤的怪兽
function c23912837.filter(c,e,tp)
	return c:IsSetCard(0x9d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- 目标选择函数：判断是否满足特殊召唤条件
function c23912837.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c23912837.filter(chkc,e,tp) end
	-- 规则层面：判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面：判断玩家墓地是否存在满足条件的「影依」怪兽
		and Duel.IsExistingTarget(c23912837.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示信息：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标：从玩家墓地选择一只满足条件的「影依」怪兽
	local g=Duel.SelectTarget(tp,c23912837.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：确定特殊召唤的效果处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：执行特殊召唤操作
function c23912837.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标：获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 特殊召唤处理：将目标怪兽以守备表示特殊召唤到场上
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)~=0 and tc:IsFacedown() then
		-- 确认卡片：向对方玩家展示被特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 过滤函数：筛选满足「影依」卡组且可以作为除外费用的卡
function c23912837.cfilter(c)
	return c:IsSetCard(0x9d) and c:IsAbleToRemoveAsCost()
end
-- 效果成本函数：支付发动效果所需的除外费用
function c23912837.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 规则层面：判断是否满足支付除外费用的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c23912837.cfilter,tp,LOCATION_GRAVE,0,1,c) and c:IsAbleToRemoveAsCost() end
	-- 提示信息：提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择除外卡：从玩家墓地选择一只满足条件的「影依」卡
	local g=Duel.SelectMatchingCard(tp,c23912837.cfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	-- 执行除外：将所选卡除外作为发动效果的成本
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果目标函数：选择发动效果时要执行的改变表示形式操作
function c23912837.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：判断玩家场上是否存在里侧表示的怪兽
	local b1=Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil)
	-- 规则层面：判断玩家场上是否存在表侧表示的怪兽
	local b2=Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local s=0
	if b1 and not b2 then
		-- 效果原文：●自己场上1只里侧表示怪兽变成表侧守备表示。
		s=Duel.SelectOption(tp,aux.Stringid(23912837,2))  --"里侧表示怪兽变成表侧守备表示"
	end
	if not b1 and b2 then
		-- 效果原文：●自己场上1只表侧表示怪兽变成里侧守备表示。
		s=Duel.SelectOption(tp,aux.Stringid(23912837,3))+1  --"表侧表示怪兽变成里侧守备表示"
	end
	if b1 and b2 then
		-- 效果原文：●自己场上1只里侧表示怪兽变成表侧守备表示。/●自己场上1只表侧表示怪兽变成里侧守备表示。
		s=Duel.SelectOption(tp,aux.Stringid(23912837,2),aux.Stringid(23912837,3))  --"里侧表示怪兽变成表侧守备表示/表侧表示怪兽变成里侧守备表示"
	end
	e:SetLabel(s)
	if s==0 then
		e:SetCategory(CATEGORY_POSITION)
	else
		e:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	end
	-- 设置操作信息：确定改变表示形式的效果处理对象
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
-- 效果处理函数：执行改变表示形式的操作
function c23912837.posop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 提示信息：提示玩家选择要改变表示形式的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 选择目标：选择场上一只里侧表示的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 动画提示：显示被选为对象的怪兽
			Duel.HintSelection(g)
			-- 改变表示形式：将目标怪兽变为表侧守备表示
			Duel.ChangePosition(g:GetFirst(),POS_FACEUP_DEFENSE)
		end
	else
		-- 提示信息：提示玩家选择要改变表示形式的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 选择目标：选择场上一只表侧表示的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 动画提示：显示被选为对象的怪兽
			Duel.HintSelection(g)
			-- 改变表示形式：将目标怪兽变为里侧守备表示
			Duel.ChangePosition(g:GetFirst(),POS_FACEDOWN_DEFENSE)
		end
	end
end
