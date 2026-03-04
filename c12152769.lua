--おねだりゴブリン
-- 效果：
-- ①：这张卡给与对方战斗伤害的场合发动。对方可以把1张手卡交给这张卡的控制者让这个效果无效。没交的场合，自己从卡组把1张「哥布林」卡加入手卡。
function c12152769.initial_effect(c)
	-- 效果原文内容：①：这张卡给与对方战斗伤害的场合发动。对方可以把1张手卡交给这张卡的控制者让这个效果无效。没交的场合，自己从卡组把1张「哥布林」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12152769,0))  --"手卡转移"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c12152769.condition)
	e1:SetTarget(c12152769.target)
	e1:SetOperation(c12152769.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断是否为对方造成战斗伤害
function c12152769.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 规则层面作用：过滤满足条件的「哥布林」卡
function c12152769.filter(c)
	return c:IsSetCard(0xac) and c:IsAbleToHand()
end
-- 规则层面作用：设置效果处理时的目标信息
function c12152769.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置连锁处理时将要检索的卡组中的「哥布林」卡数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面作用：处理效果的发动与连锁
function c12152769.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取对方手牌组
	local hg=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	-- 规则层面作用：检查当前连锁是否可以被无效且对方手牌不为空
	if Duel.IsChainDisablable(0) and hg:GetCount()>0
		-- 规则层面作用：询问对方是否将手卡交给效果持有者
		and Duel.SelectYesNo(1-tp,aux.Stringid(12152769,1)) then  --"是否将手卡交给对方？"
		-- 规则层面作用：提示对方选择要交给效果持有者的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(12152769,2))  --"请选择交给对方的手卡"
		local sg=hg:Select(1-tp,1,1,nil)
		-- 规则层面作用：将选定的卡移至效果持有者手牌
		Duel.SendtoHand(sg,tp,REASON_EFFECT)
		-- 规则层面作用：使当前连锁效果无效
		Duel.NegateEffect(0)
		return
	end
	-- 规则层面作用：提示己方选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 规则层面作用：从卡组中检索满足条件的「哥布林」卡
	local g=Duel.SelectMatchingCard(tp,c12152769.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面作用：将检索到的卡加入己方手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面作用：向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
