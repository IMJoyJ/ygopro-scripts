--影光の聖選士
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己墓地1只「影依」怪兽为对象才能发动。那只怪兽表侧守备表示或里侧守备表示特殊召唤。
-- ②：可以从自己墓地把这张卡和1张「影依」卡除外，从以下效果选择1个发动。
-- ●自己场上1只里侧表示怪兽变成表侧守备表示。
-- ●自己场上1只表侧表示怪兽变成里侧守备表示。
function c23912837.initial_effect(c)
	-- ①：以自己墓地1只「影依」怪兽为对象才能发动。那只怪兽表侧守备表示或里侧守备表示特殊召唤。
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
	-- ②：可以从自己墓地把这张卡和1张「影依」卡除外，从以下效果选择1个发动。●自己场上1只里侧表示怪兽变成表侧守备表示。●自己场上1只表侧表示怪兽变成里侧守备表示。
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
-- 过滤函数：判断候选卡是否为「影依」系列怪兽，并且能被当前效果以守备表示特殊召唤。
function c23912837.filter(c,e,tp)
	return c:IsSetCard(0x9d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- ①的取对象目标选择函数：先检查对象合法性（自己墓地的“影依”怪兽且可守备特殊召唤），再检查发动条件（有怪兽区空格且墓地存在合格对象）。
function c23912837.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c23912837.filter(chkc,e,tp) end
	-- 发动条件判断：自己主要怪兽区必须存在空位，以保证可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件判断：自己墓地存在至少1只满足特殊召唤条件的“影依”怪兽可供选择。
		and Duel.IsExistingTarget(c23912837.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，提示玩家接下来要选择特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的“影依”怪兽，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c23912837.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将进行1只怪兽的特殊召唤，供连锁判定等系统查询。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：取得所选对象，确认其仍与效果关联后，将其以守备表示特殊召唤；若特殊召唤成功且该怪兽是里侧表示，则向对方确认这张卡。
function c23912837.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时当前连锁所选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将目标怪兽以守备表示特殊召唤，若成功且目标最终为里侧表示，则进入确认处理。
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)~=0 and tc:IsFacedown() then
		-- 向对方玩家展示这只里侧守备表示特殊召唤的怪兽，使对方得知其卡牌信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- COST筛选函数：判断一张卡是否为“影依”卡且可以作为COST从墓地除外。
function c23912837.cfilter(c)
	return c:IsSetCard(0x9d) and c:IsAbleToRemoveAsCost()
end
-- ②的COST处理：先检查墓地存在可除外的“影依”卡且自身可除外；然后让玩家选择1张“影依”卡，与自身一起以表侧表示除外作为发动代价。
function c23912837.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- COST判定：自己墓地存在除自身以外的“影依”卡可作为COST除外，且自身也能作为COST除外。
	if chk==0 then return Duel.IsExistingMatchingCard(c23912837.cfilter,tp,LOCATION_GRAVE,0,1,c) and c:IsAbleToRemoveAsCost() end
	-- 弹出选择提示，提示玩家接下来要选择除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张“影依”卡（不含自身），作为除外的COST。
	local g=Duel.SelectMatchingCard(tp,c23912837.cfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	-- 将选择的“影依”卡与自身一起以表侧表示除外，支付发动②所需的COST。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②的发动目标选择：根据自己场上是否有里侧表示怪兽、是否有可变为里侧的正面怪兽来确定可选分支，若两分支都可选则让玩家选择；将分支存入Label，并设置相应的类别与操作信息。
function c23912837.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在里侧表示怪兽，以决定“里侧变表侧守备”选项是否可选。
	local b1=Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil)
	-- 检查自己场上是否存在表侧表示且可变为里侧守备表示的怪兽，以决定“表侧变里侧守备”选项是否可选。
	local b2=Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local s=0
	if b1 and not b2 then
		-- 当只有“里侧变表侧”可选时，让玩家选择该选项，当选后s为0，表示执行分支0。
		s=Duel.SelectOption(tp,aux.Stringid(23912837,2))  --"里侧表示怪兽变成表侧守备表示"
	end
	if not b1 and b2 then
		-- 当只有“表侧变里侧”可选时，让玩家选择该选项，返回值加1使s为1，表示执行分支1。
		s=Duel.SelectOption(tp,aux.Stringid(23912837,3))+1  --"表侧表示怪兽变成里侧守备表示"
	end
	if b1 and b2 then
		-- 当两个分支都可选时，让玩家从两个选项中选择一个，s为0选分支0，s为1选分支1。
		s=Duel.SelectOption(tp,aux.Stringid(23912837,2),aux.Stringid(23912837,3))  --"里侧表示怪兽变成表侧守备表示/表侧表示怪兽变成里侧守备表示"
	end
	e:SetLabel(s)
	if s==0 then
		e:SetCategory(CATEGORY_POSITION)
	else
		e:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	end
	-- 设置操作信息：本次效果将变更1只怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
-- ②的效果处理：根据之前选择的Label分支执行：0则将场上1只里侧表示怪兽变为表侧守备表示；1则将场上1只表侧表示怪兽变为里侧守备表示。
function c23912837.posop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 在分支0中，弹出选择提示，提示玩家选择要改变表示形式的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 在分支0中，让玩家选择自己场上1只里侧表示怪兽。
		local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 为选中的怪兽播放被选为对象的动画，并记录其成为对象。
			Duel.HintSelection(g)
			-- 将选中的怪兽的表示形式变为表侧守备表示。
			Duel.ChangePosition(g:GetFirst(),POS_FACEUP_DEFENSE)
		end
	else
		-- 在分支1中，弹出选择提示，提示玩家选择要改变表示形式的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 在分支1中，让玩家选择自己场上1只表侧表示且可以变为里侧守备表示的怪兽。
		local g=Duel.SelectMatchingCard(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 为选中的怪兽播放被选为对象的动画，并记录其成为对象。
			Duel.HintSelection(g)
			-- 将选中的怪兽的表示形式变为里侧守备表示。
			Duel.ChangePosition(g:GetFirst(),POS_FACEDOWN_DEFENSE)
		end
	end
end
