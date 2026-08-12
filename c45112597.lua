--世海龍ジーランティス
-- 效果：
-- 效果怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：「世海龙 西兰提斯」在自己场上只能有1张表侧表示存在。
-- ②：自己主要阶段才能发动。场上的怪兽全部除外。那之后，这个效果除外的怪兽尽可能在原本持有者的场上表侧表示或里侧守备表示特殊召唤。
-- ③：自己·对方的战斗阶段才能发动。把最多有场上的互相连接状态的怪兽数量的场上的卡破坏。
function c45112597.initial_effect(c)
	c:SetUniqueOnField(1,0,45112597)
	-- 为卡片添加连接召唤手续，要求使用至少1张类型为效果怪兽的卡片作为连接素材
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
-- 设置效果的发动条件，检查场上是否存在可以除外的怪兽
function c45112597.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索满足条件的场上怪兽组，这些怪兽可以被除外
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 设置操作信息，表示将要除外场上所有满足条件的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	-- 设置操作信息，表示将要特殊召唤被除外的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_REMOVED)
end
-- 定义特殊召唤的过滤条件，确保被除外的怪兽满足特殊召唤的条件
function c45112597.spfilter(c,e,tp)
	return not c:IsType(TYPE_TOKEN) and c:IsFaceup() and c:IsLocation(LOCATION_REMOVED) and not c:IsReason(REASON_REDIRECT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP+POS_FACEDOWN_DEFENSE,c:GetControler())
end
-- 处理效果的发动，将场上怪兽除外并尝试特殊召唤
function c45112597.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的场上怪兽组，这些怪兽可以被除外
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 判断是否成功除外怪兽，若成功则继续处理特殊召唤
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 刷新场地信息，确保效果处理的正确性
		Duel.AdjustAll()
		-- 获取实际被除外的怪兽组，并筛选出可以特殊召唤的怪兽
		local og=Duel.GetOperatedGroup():Filter(c45112597.spfilter,nil,e,tp)
		if #og<=0 then return end
		-- 获取当前玩家的怪兽区可用位置数量
		local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 获取对方玩家的怪兽区可用位置数量
		local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
		if ft1<=0 and ft2<=0 then return end
		local spg=Group.CreateGroup()
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then
			if ft1>0 and ft2>0 then
				-- 提示玩家选择要特殊召唤的怪兽
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
				-- 提示玩家选择要特殊召唤的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				spg=og:FilterSelect(tp,Card.IsControler,1,1,nil,p)
			end
		else
			local p=tp
			for i=1,2 do
				local sg=og:Filter(Card.IsControler,nil,p)
				-- 获取指定玩家的怪兽区可用位置数量
				local ft=Duel.GetLocationCount(p,LOCATION_MZONE,tp)
				if #sg>ft then
					-- 提示玩家选择要特殊召唤的怪兽
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					sg=sg:Select(tp,ft,ft,nil)
				end
				spg:Merge(sg)
				p=1-tp
			end
		end
		if #spg>0 then
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			local tc=spg:GetFirst()
			while tc do
				-- 特殊召唤一张怪兽，设置其位置为表侧表示或里侧守备表示
				Duel.SpecialSummonStep(tc,0,tp,tc:GetControler(),false,false,POS_FACEUP+POS_FACEDOWN_DEFENSE)
				tc=spg:GetNext()
			end
			-- 完成所有特殊召唤步骤，确保效果处理完成
			Duel.SpecialSummonComplete()
			local cg=spg:Filter(Card.IsFacedown,nil)
			if #cg>0 then
				-- 确认对方玩家看到被特殊召唤的怪兽
				Duel.ConfirmCards(1-tp,cg)
			end
		end
	end
end
-- 设置效果发动条件，判断是否处于战斗阶段
function c45112597.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 定义过滤条件，检查怪兽是否处于互相连接状态
function c45112597.filter(c)
	return c:GetMutualLinkedGroupCount()>0
end
-- 设置效果的发动条件，检查场上是否存在互相连接状态的怪兽
function c45112597.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在互相连接状态的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c45112597.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 检索满足条件的场上卡组
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息，表示将要破坏场上卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理效果的发动，计算可破坏卡的数量并选择破坏对象
function c45112597.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算场上互相连接状态的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c45112597.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if ct>0 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择满足条件的场上卡进行破坏
		local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
		-- 显示被选为破坏对象的卡
		Duel.HintSelection(dg)
		-- 破坏指定的卡
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
