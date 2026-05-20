--D・バリア
-- 效果：
-- 把要让自己场上表侧表示存在的名字带有「变形斗士」的怪兽破坏的魔法·陷阱卡的发动无效并破坏。再从自己卡组把1张名字带有「变形斗士」的卡加入手卡。
function c77229910.initial_effect(c)
	-- 把要让自己场上表侧表示存在的名字带有「变形斗士」的怪兽破坏的魔法·陷阱卡的发动无效并破坏。再从自己卡组把1张名字带有「变形斗士」的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(c77229910.condition)
	e1:SetTarget(c77229910.target)
	e1:SetOperation(c77229910.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的名字带有「变形斗士」的怪兽
function c77229910.dfilter(c,p)
	return c:GetControler()==p and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsSetCard(0x26)
end
-- 发动条件：被连锁的效果是会破坏自己场上表侧表示「变形斗士」怪兽的魔法·陷阱卡的发动
function c77229910.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查被连锁的效果是否可以被无效，且该效果必须是魔法·陷阱卡的发动
	if not Duel.IsChainNegatable(ev) or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取被连锁效果中涉及破坏的操作信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(c77229910.dfilter,nil,tp)-tg:GetCount()>0
end
-- 过滤条件：卡组中名字带有「变形斗士」且能加入手牌的卡
function c77229910.filter(c)
	return c:IsSetCard(0x26) and c:IsAbleToHand()
end
-- 效果的目标处理：检查卡组中是否存在可检索的「变形斗士」卡，并设置无效、破坏和加入手牌的操作信息
function c77229910.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检查自身卡组是否存在至少1张名字带有「变形斗士」的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c77229910.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：使该魔法·陷阱卡的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该魔法·陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果的运行处理：使发动无效并破坏，之后从卡组将1张「变形斗士」卡加入手牌
function c77229910.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该魔法·陷阱卡的发动无效，且该卡在场上存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该魔法·陷阱卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张名字带有「变形斗士」的卡
	local g=Duel.SelectMatchingCard(tp,c77229910.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 中断当前效果，使后续的加入手牌处理与之前的破坏处理不视为同时进行
		Duel.BreakEffect()
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
