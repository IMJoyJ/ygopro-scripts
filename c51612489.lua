--騒動
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以场上1只里侧守备表示怪兽为对象才能发动。那只怪兽回到手卡。那之后，这个效果让卡加入手卡的玩家可以从自身手卡把1只怪兽里侧守备表示特殊召唤。
-- ②：对方怪兽的攻击宣言时，把墓地的这张卡除外才能发动。场上1只里侧守备表示怪兽变成表侧攻击表示。
local s,id,o=GetID()
-- s.initial_effect 创建并注册该卡的两个效果：e1为①效果的发动（取对象回手并可能特召），e2为②效果的墓地诱发（攻击宣言时除外自身并翻转怪兽），分别设定类型、范围、条件、代价、目标与处理函数。
function s.initial_effect(c)
	-- ①：以场上1只里侧守备表示怪兽为对象才能发动。那只怪兽回到手卡。那之后，这个效果让卡加入手卡的玩家可以从自身手卡把1只怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的攻击宣言时，把墓地的这张卡除外才能发动。场上1只里侧守备表示怪兽变成表侧攻击表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.poscon)
	-- 设置②效果的发动COST：将墓地的这张卡除外（aux.bfgcost 为除外自身的通用代价函数）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为里侧守备表示且能加入手卡，用于①效果取对象时选择对象。
function s.rthfilter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsAbleToHand()
end
-- ①效果的发动处理：先确认存在合法对象（里侧守备且能回手），再选择1只对象并登记为取对象，同时设置返回手卡的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rthfilter(chkc) end
	-- 发动时点检查：场上是否存在至少1只满足 rthfilter 条件的里侧守备表示怪兽，以决定能否发动①效果。
	if chk==0 then return Duel.IsExistingTarget(s.rthfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家显示选择提示，要求其选择要返回手卡的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 由发动玩家从双方场上选择1只里侧守备且能回手的怪兽作为对象，并自动将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.rthfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理信息：本次效果将把1张卡返回手卡，用于响应‘回手’相关的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤函数：判断手卡中的怪兽是否可以被当前效果以里侧守备表示特殊召唤（检查召唤条件与苏生限制）。
function s.spfilter(c,e,tp,sp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,sp)
end
-- ①效果处理：将对象怪兽返回持有者手卡；若成功回手，则由回到手卡的玩家选择是否从自身手卡选1只怪兽里侧守备表示特殊召唤（由发动者执行特召）。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联、仍在场上，并执行将其返回手卡；返回成功且怪兽确实在手卡时，才继续后续特殊召唤分支。
	if tc:IsRelateToChain() and tc:IsLocation(LOCATION_MZONE) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		local sp=tc:GetControler()
		-- 从回手玩家（sp）的手卡中筛选出所有满足特殊召唤条件的怪兽，作为可特召候选。
		local g=Duel.GetMatchingGroup(s.spfilter,sp,LOCATION_HAND,0,nil,e,tp,sp)
		-- 若存在可特召的怪兽、发动者场上有空位，且该玩家选择“是”，则执行后续特殊召唤；否则不处理。
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(sp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 中断当前效果的处理，使后续特殊召唤作为新的一段处理进行，避免时点被错过（制造错时点）。
			Duel.BreakEffect()
			-- 提示回手玩家选择要特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,sp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(sp,1,1,nil)
			-- 因为从手卡选择并准备特殊召唤，洗切该玩家的手卡以保持随机性。
			Duel.ShuffleHand(sp)
			-- 将选择的怪兽以里侧守备表示特殊召唤到该手卡持有者（sp）的场上，由效果发动者（tp）执行这次特殊召唤。
			Duel.SpecialSummon(sg,0,tp,sp,false,false,POS_FACEDOWN_DEFENSE)
		end
	end
end
-- ②效果的发动条件函数：仅在对方怪兽进行攻击宣言时，本效果才能发动。
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击宣言的怪兽的控制者不是本卡持有者/发动者（即对方怪兽），满足②效果的条件。
	return Duel.GetAttacker():GetControler()~=tp
end
-- ②效果的发动条件与处理信息：确认场上存在至少1只里侧守备表示且能变更表示形式的怪兽，并设置变更表示形式的处理信息（不取对象）。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：场上是否存在至少1只里侧守备表示且可以变更表示形式的怪兽，以决定能否发动②效果。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsFacedown,Card.IsCanChangePosition),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置连锁处理信息：本次效果将进行1只怪兽的表示形式变更，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
-- ②效果处理：选择场上1只里侧守备表示怪兽，将其变更为表侧攻击表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动玩家选择要改变表示形式的里侧守备怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择场上1只里侧守备表示且可以变更表示形式的怪兽（效果处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFacedown,Card.IsCanChangePosition),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 为选中的怪兽播放被选择动画，并将其记录为效果处理的对象，以便正确触发相关判定。
		Duel.HintSelection(g)
		-- 将选择的怪兽的表示形式改为表侧攻击表示。
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	end
end
