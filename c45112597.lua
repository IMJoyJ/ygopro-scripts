--世海龍ジーランティス
-- 效果：
-- 效果怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：「世海龙 西兰提斯」在自己场上只能有1张表侧表示存在。
-- ②：自己主要阶段才能发动。场上的怪兽全部除外。那之后，这个效果除外的怪兽尽可能在原本持有者的场上表侧表示或里侧守备表示特殊召唤。
-- ③：自己·对方的战斗阶段才能发动。把最多有场上的互相连接状态的怪兽数量的场上的卡破坏。
function c45112597.initial_effect(c)
	c:SetUniqueOnField(1,0,45112597)
	-- 为这张卡登记连接召唤手续：素材为1只以上的效果怪兽（对应召唤条件‘效果怪兽1只以上’）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),1)
	c:EnableReviveLimit()
	-- ②：自己主要阶段才能发动。场上的怪兽全部除外。那之后，这个效果除外的怪兽尽可能在原本持有者的场上表侧表示或里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45112597,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,45112597)
	e1:SetTarget(c45112597.rmtg)
	e1:SetOperation(c45112597.rmop)
	c:RegisterEffect(e1)
	-- ③：自己·对方的战斗阶段才能发动。把最多有场上的互相连接状态的怪兽数量的场上的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45112597,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCountLimit(1,45112598)
	e2:SetCondition(c45112597.descon)
	e2:SetTarget(c45112597.destg)
	e2:SetOperation(c45112597.desop)
	c:RegisterEffect(e2)
end
-- ②效果的目标处理（发动时的合法性检查与连锁信息登记）：获取场上所有可除外的怪兽作为潜在除外对象；只要存在至少1只即可发动；随后登记本次连锁将除外这些怪兽，并登记后续可能从除外区进行特殊召唤的信息。
function c45112597.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得双方怪兽区域中所有能够被除外的怪兽（不取对象，而是把全部可除外怪兽作为处理对象）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 登记除外效果的操作信息：将场上所有可除外的怪兽作为本次连锁的除外对象，数量为g的数量，供其他效果检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	-- 登记特殊召唤效果的操作信息：由于特殊召唤的对象和数量在效果处理时才确定，targets为nil，数量记为1，target_player为双方，位置为除外区。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_REMOVED)
end
-- 特殊召唤筛选函数：要求被除外的怪兽不是衍生物、表侧除外、不是因改变去向（如大宇宙）而进入除外区，且能够被该效果以表侧表示或里侧守备表示特殊召唤到其原本持有者的场上。
function c45112597.spfilter(c,e,tp)
	return not c:IsType(TYPE_TOKEN) and c:IsFaceup() and c:IsLocation(LOCATION_REMOVED) and not c:IsReason(REASON_REDIRECT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP+POS_FACEDOWN_DEFENSE,c:GetControler())
end
-- ②效果的实际处理：将场上所有能除外的怪兽表侧除外；刷新后从被除外的怪兽中选出满足特殊召唤条件的怪兽；若双方场上均无空格则结束；若存在如青眼精灵龙等不允许同时特殊召唤2只以上怪兽的效果，则只选择1只；否则按双方各自可用空格尽量多地选出例外怪兽；最后以连续特殊召唤方式将选出的怪兽特殊召唤到对应控制者（原本持有者）的场上，并确认里侧守备召唤的卡。
function c45112597.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新取得当前场上所有可除外的怪兽（处理时以实际场上情况为准）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 若仍有可除外的怪兽，则将这些怪兽全部以表侧表示除外；只有实际除外成功数量不为0时才继续后续处理。
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 立即刷新场地状态信息，确保除外后可用怪兽区域、连接状态等数据正确更新。
		Duel.AdjustAll()
		-- 从本次实际被除外的怪兽中，筛选出能够被特殊召唤的怪兽，作为可特殊召唤组og。
		local og=Duel.GetOperatedGroup():Filter(c45112597.spfilter,nil,e,tp)
		if #og<=0 then return end
		-- 获取发动玩家tp自己场上主要怪兽区域的可用空格数，作为可以特殊召唤到tp场上的数量上限。
		local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 获取对方（1-tp）场上主要怪兽区域的可用空格数（以tp为使用方计算），作为可以特殊召唤到对方场上的数量上限。
		local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
		if ft1<=0 and ft2<=0 then return end
		local spg=Group.CreateGroup()
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then
			if ft1>0 and ft2>0 then
				-- 弹出选择提示‘请选择要特殊召唤的卡’，用于让玩家选择要特殊召唤的怪兽。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				spg=og:Select(tp,1,1,nil)
			else
				local p
				if ft1>0 and ft2<=0 then
					p=tp
				end
				if ft1<=0 and ft2>0 then
					p=1-tp
				end
				-- 弹出选择提示‘请选择要特殊召唤的卡’，用于让玩家选择要特殊召唤的怪兽。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				spg=og:FilterSelect(tp,Card.IsControler,1,1,nil,p)
			end
		else
			local p=tp
			for i=1,2 do
				local sg=og:Filter(Card.IsControler,nil,p)
				-- 计算当前处理方p的主要怪兽区域可用空格数（以tp为使用方，考虑格子限制），作为可特殊召唤到p场上的数量上限。
				local ft=Duel.GetLocationCount(p,LOCATION_MZONE,tp)
				if #sg>ft then
					-- 弹出选择提示‘请选择要特殊召唤的卡’，用于让玩家选择要特殊召唤的怪兽。
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					sg=sg:Select(tp,ft,ft,nil)
				end
				spg:Merge(sg)
				p=1-tp
			end
		end
		if #spg>0 then
			-- 中断当前效果处理，使之后的特殊召唤与前一步的除外处理视为不同时处理，以正确对应‘那之后’的时点。
			Duel.BreakEffect()
			local tc=spg:GetFirst()
			while tc do
				-- 将选中的一只除外怪兽以连续特殊召唤步骤追加特殊召唤：特殊召唤到该怪兽控制者（原本持有者）的场上，表示形式可选择表侧表示或里侧守备表示。
				Duel.SpecialSummonStep(tc,0,tp,tc:GetControler(),false,false,POS_FACEUP+POS_FACEDOWN_DEFENSE)
				tc=spg:GetNext()
			end
			-- 完成连续特殊召唤，统一处理这些特殊召唤成功时触发的时点与诱发效果。
			Duel.SpecialSummonComplete()
			local cg=spg:Filter(Card.IsFacedown,nil)
			if #cg>0 then
				-- 将里侧守备表示特殊召唤的怪兽向对方玩家确认，公开其卡牌信息。
				Duel.ConfirmCards(1-tp,cg)
			end
		end
	end
end
-- ③效果的发动条件：必须处于战斗阶段（从战斗阶段开始到战斗步骤之间），且自己或对方的战斗阶段均可发动。
function c45112597.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前所处的阶段，用于判断是否满足战斗阶段的发动条件。
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 怪兽筛选函数：若该怪兽处于互相连接状态（与其他怪兽存在互相连接），则返回true，用于统计场上互相连接状态的怪兽数量作为可破坏张数上限。
function c45112597.filter(c)
	return c:GetMutualLinkedGroupCount()>0
end
-- ③效果的目标处理（发动时检查与连锁信息登记）：检查场上是否存在至少1只互相连接状态的怪兽，若存在则满足发动条件；同时取得场上所有卡作为可能被破坏的对象，并登记破坏效果的信息。
function c45112597.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若场上不存在任何互相连接状态的怪兽，则可破坏数量为0，不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c45112597.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得双方场上所有卡片（怪兽·魔法·陷阱）作为可能被破坏的对象集合。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 登记破坏效果的操作信息：候选破坏对象为场上所有卡，数量暂记为1（实际最多数量在效果处理时按互相连接状态的怪兽数量确定）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③效果处理：计算当前场上互相连接状态的怪兽数量作为可破坏张数上限；若上限大于0，则让玩家从全场卡中选择1到该上限数量的卡，播放选中动画后将其破坏。
function c45112597.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算当前场上处于互相连接状态的怪兽数量，作为本次效果最多可破坏的卡片张数。
	local ct=Duel.GetMatchingGroupCount(c45112597.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if ct>0 then
		-- 弹出选择提示‘请选择要破坏的卡’，用于让玩家选择要破坏的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让发动玩家从双方场上选择1到ct张卡（ct为互相连接状态的怪兽数量），作为本次破坏的对象。
		local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
		-- 为选中的破坏对象播放选中动画，并记录这些卡与该连锁的联系（广义上的被选为对象）。
		Duel.HintSelection(dg)
		-- 将选中的卡片以‘效果’的原因破坏并送去墓地。
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
