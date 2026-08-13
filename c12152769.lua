--おねだりゴブリン
-- 效果：
-- ①：这张卡给与对方战斗伤害的场合发动。对方可以把1张手卡交给这张卡的控制者让这个效果无效。没交的场合，自己从卡组把1张「哥布林」卡加入手卡。
function c12152769.initial_effect(c)
	-- ①：这张卡给与对方战斗伤害的场合发动。对方可以把1张手卡交给这张卡的控制者让这个效果无效。没交的场合，自己从卡组把1张「哥布林」卡加入手卡。
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
-- 战斗伤害发生时，判定受到伤害的玩家不是本卡控制者，即只有给与对方战斗伤害时才满足发动条件。
function c12152769.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 检索的过滤条件：必须是卡名含有「哥布林」字段的卡，并且该卡能够被加入手卡。
function c12152769.filter(c)
	return c:IsSetCard(0xac) and c:IsAbleToHand()
end
-- 效果发动时的目标选择处理：chk==0（发动确认）时直接允许发动，并预设置效果可能从卡组将1张卡加入手卡的操作信息。
function c12152769.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本效果处理时可能从持有者的卡组将1张卡加入手卡（不取对象，预计数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的操作：先判断对方是否愿意交1张手卡来无效本效果；若交卡则无效并中止，若不交则自己从卡组检索「哥布林」卡。
function c12152769.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方（1-tp）手牌区域的卡组，用于判断和选择交给控制者的手卡。
	local hg=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	-- 检查当前连锁的效果能否被无效，以及对方是否有手卡可以交出，两者都满足时才进入对方交卡无效的流程。
	if Duel.IsChainDisablable(0) and hg:GetCount()>0
		-- 询问对方玩家是否选择将1张手卡交给这张卡的控制者来使这个效果无效。
		and Duel.SelectYesNo(1-tp,aux.Stringid(12152769,1)) then  --"是否将手卡交给对方？"
		-- 给出选择提示，让对方玩家从手卡中选择1张要交给控制者的卡。
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(12152769,2))  --"请选择交给对方的手卡"
		local sg=hg:Select(1-tp,1,1,nil)
		-- 将对方选出的那张手卡因这个效果交给控制者（tp），即移动到控制者的手卡。
		Duel.SendtoHand(sg,tp,REASON_EFFECT)
		-- 使当前连锁（本效果）无效化，实现对方交卡后效果被无效的效果。
		Duel.NegateEffect(0)
		return
	end
	-- 对方没有交卡时，提示自己从卡组选择要加入手卡的「哥布林」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组中选择1张满足「哥布林」且能加入手卡的卡，作为检索对象。
	local g=Duel.SelectMatchingCard(tp,c12152769.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将检索到的卡加入其持有者的手卡（nil表示回到持有者手卡），完成检索。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认刚刚加入手卡的那张卡，符合公开检索信息的规则。
		Duel.ConfirmCards(1-tp,g)
	end
end
