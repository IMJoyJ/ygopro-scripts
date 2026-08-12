--魔鍵錠－施－
-- 效果：
-- ①：把衍生物以外的自己场上1只通常怪兽或者「魔键」怪兽解放，等级合计最多到8星以下为止以自己墓地最多2只通常怪兽或者「魔键」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。那之后，可以从以下效果选1个适用。
-- ●用自己场上的怪兽为同调素材把1只「魔键」同调怪兽同调召唤。
-- ●用自己场上的怪兽为超量素材把1只「魔键」超量怪兽超量召唤。
function c40493210.initial_effect(c)
	-- 创建效果，设置为发动时点，可选择对象，分类为特殊召唤，提示时机为结束阶段
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c40493210.cost)
	e1:SetTarget(c40493210.target)
	e1:SetOperation(c40493210.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上可解放的怪兽是否满足条件：不是衍生物、是通常怪兽或魔键怪兽、未被战斗破坏、且场上存在可用怪兽区
function c40493210.cfilter(c,tp)
	return not c:IsType(TYPE_TOKEN) and (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x165))
		-- 判断怪兽未被战斗破坏且场上存在可用怪兽区
		and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.GetMZoneCount(tp,c)>0
end
-- 成本函数，检查是否可以解放满足条件的场上怪兽，若可以则选择并解放
function c40493210.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放满足条件的场上怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c40493210.cfilter,1,nil,tp) end
	-- 选择满足条件的场上怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c40493210.cfilter,1,1,nil,tp)
	-- 实际执行解放操作，原因设为代价
	Duel.Release(g,REASON_COST)
end
-- 过滤函数，用于判断墓地怪兽是否满足特殊召唤条件：是通常怪兽或魔键怪兽、等级不超过8、可成为效果对象、可特殊召唤
function c40493210.spfilter(c,e,tp)
	return (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x165)) and c:IsLevelBelow(8)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 检查函数，用于判断所选墓地怪兽等级总和是否不超过8
function c40493210.gcheck(g)
	return g:GetSum(Card.GetLevel)<=8
end
-- 目标函数，检查是否有满足条件的墓地怪兽，选择满足等级总和不超过8的怪兽组，设置为特殊召唤对象
function c40493210.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否有满足条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c40493210.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 获取满足条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(c40493210.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取玩家场上可用怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft>2 then ft=2 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c40493210.gcheck,false,1,ft)
	-- 设置当前效果的目标卡组
	Duel.SetTargetCard(sg)
	-- 设置操作信息，指定特殊召唤的卡组和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,#sg,0,0)
end
-- 过滤函数，用于判断额外卡组中是否存在可同调召唤的魔键怪兽
function c40493210.syncsumfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x165) and c:IsSynchroSummonable(nil)
end
-- 过滤函数，用于判断额外卡组中是否存在可超量召唤的魔键怪兽
function c40493210.xyzsumfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x165) and c:IsXyzSummonable(nil)
end
-- 发动函数，检查场上是否有可用怪兽区，获取目标卡组，判断是否满足特殊召唤条件，执行特殊召唤，根据结果选择是否进行同调或超量召唤
function c40493210.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取当前连锁的目标卡组，并筛选与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 执行特殊召唤操作，将目标卡以守备表示特殊召唤到场上
	local res=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	-- 刷新所有场上的信息
	Duel.AdjustAll()
	-- 检查是否存在可同调召唤的魔键怪兽
	local b1=Duel.IsExistingMatchingCard(c40493210.syncsumfilter,tp,LOCATION_EXTRA,0,1,nil)
	-- 检查是否存在可超量召唤的魔键怪兽
	local b2=Duel.IsExistingMatchingCard(c40493210.xyzsumfilter,tp,LOCATION_EXTRA,0,1,nil)
	if res~=0 and (b1 or b2) then
		local off=1
		local ops,opval={},{}
		if b1 then
			ops[off]=aux.Stringid(40493210,0)  --"同调召唤"
			opval[off]=0
			off=off+1
		end
		if b2 then
			ops[off]=aux.Stringid(40493210,1)  --"超量召唤"
			opval[off]=1
			off=off+1
		end
		ops[off]=aux.Stringid(40493210,2)  --"什么都不做"
		opval[off]=2
		-- 选择玩家选项，决定进行同调召唤、超量召唤或什么都不做
		local op=Duel.SelectOption(tp,table.unpack(ops))+1
		local sel=opval[op]
		if sel==0 then
			-- 中断当前效果，使后续效果处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择满足条件的同调怪兽进行同调召唤
			local sg1=Duel.SelectMatchingCard(tp,c40493210.syncsumfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			-- 执行同调召唤手续
			Duel.SynchroSummon(tp,sg1:GetFirst(),nil)
		elseif sel==1 then
			-- 中断当前效果，使后续效果处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择满足条件的超量怪兽进行超量召唤
			local sg2=Duel.SelectMatchingCard(tp,c40493210.xyzsumfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			-- 执行超量召唤手续
			Duel.XyzSummon(tp,sg2:GetFirst(),nil)
		end
	end
end
