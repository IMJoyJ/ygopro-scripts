--魔鍵錠－施－
-- 效果：
-- ①：把衍生物以外的自己场上1只通常怪兽或者「魔键」怪兽解放，等级合计最多到8星以下为止以自己墓地最多2只通常怪兽或者「魔键」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。那之后，可以从以下效果选1个适用。
-- ●用自己场上的怪兽为同调素材把1只「魔键」同调怪兽同调召唤。
-- ●用自己场上的怪兽为超量素材把1只「魔键」超量怪兽超量召唤。
function c40493210.initial_effect(c)
	-- ①：把衍生物以外的自己场上1只通常怪兽或者「魔键」怪兽解放，等级合计最多到8星以下为止以自己墓地最多2只通常怪兽或者「魔键」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。那之后，可以从以下效果选1个适用。●用自己场上的怪兽为同调素材把1只「魔键」同调怪兽同调召唤。●用自己场上的怪兽为超量素材把1只「魔键」超量怪兽超量召唤。
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
-- 定义解放用怪兽的筛选条件：不能是衍生物，必须是通常怪兽或「魔键」字段怪兽，且不能是战斗破坏确定状态的怪兽，并且解放后自己场上仍有可用的怪兽区空格。
function c40493210.cfilter(c,tp)
	return not c:IsType(TYPE_TOKEN) and (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x165))
		-- 追加条件：不能是战斗破坏确定状态的怪兽，且解放它后自己场上仍有可用的怪兽区空格。
		and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.GetMZoneCount(tp,c)>0
end
-- 定义发动代价的完整流程：先确认存在符合条件的可解放怪兽，然后选择1只进行解放作为COST。
function c40493210.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己场上是否存在至少1只衍生物以外的通常怪兽或「魔键」怪兽可以解放。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c40493210.cfilter,1,nil,tp) end
	-- 选择1只满足解放条件的通常怪兽或「魔键」怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c40493210.cfilter,1,1,nil,tp)
	-- 将选择的怪兽解放，作为效果的发动代价。
	Duel.Release(g,REASON_COST)
end
-- 定义墓地中特殊召唤对象的筛选条件：是通常怪兽或「魔键」怪兽、等级8以下、能成为效果对象、且可以被效果守备表示特殊召唤。
function c40493210.spfilter(c,e,tp)
	return (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x165)) and c:IsLevelBelow(8)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 定义选择组检查条件：选中的所有墓地怪兽的等级合计不超过8。
function c40493210.gcheck(g)
	return g:GetSum(Card.GetLevel)<=8
end
-- 定义效果发动时的对象选择流程：确认存在对象、生成候选集合、根据可用怪兽区和青眼精灵龙限制决定最多可选数量、让玩家选择等级合计≤8的卡、设为对象并设置特殊召唤操作信息。
function c40493210.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动时确认自己墓地存在至少1只满足条件的通常怪兽或「魔键」怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c40493210.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 获取墓地中所有满足特殊召唤条件的通常怪兽或「魔键」怪兽作为候选集合。
	local g=Duel.GetMatchingGroup(c40493210.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 计算自己主要怪兽区当前可用的空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft>2 then ft=2 end
	-- 弹出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c40493210.gcheck,false,1,ft)
	-- 把选中的一组墓地怪兽设置为当前连锁的效果对象。
	Duel.SetTargetCard(sg)
	-- 设置本次效果处理将进行特殊召唤的操作信息，对象为选中的卡，数量为选中数量。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,#sg,0,0)
end
-- 定义额外卡组同调召唤的筛选条件：是「魔键」同调怪兽，且当前能用自己场上的怪兽作为素材进行同调召唤。
function c40493210.syncsumfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x165) and c:IsSynchroSummonable(nil)
end
-- 定义额外卡组超量召唤的筛选条件：是「魔键」超量怪兽，且当前能用自己场上的怪兽作为素材进行超量召唤。
function c40493210.xyzsumfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x165) and c:IsXyzSummonable(nil)
end
-- 效果处理流程：取出并确认效果对象仍存在；根据可用格子和青眼精灵龙限制调整可特殊召唤数量；守备表示特殊召唤；若成功且额外卡组有可用同调/超量「魔键」怪兽，则让玩家选择进行同调召唤、超量召唤或什么都不做并执行。
function c40493210.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次计算自己主要怪兽区空格数，若没有空格则直接终止效果处理。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 从当前连锁获取发动时选择的墓地对象，并过滤出仍然与效果关联的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()>ft then
		-- 弹出“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 将选中的对象怪兽以表侧守备表示特殊召唤到自己场上，并返回特殊召唤成功的数量。
	local res=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	-- 立即刷新场地信息，使后续检查基于最新状态。
	Duel.AdjustAll()
	-- 检查额外卡组是否存在1只当前可以进行同调召唤的「魔键」同调怪兽。
	local b1=Duel.IsExistingMatchingCard(c40493210.syncsumfilter,tp,LOCATION_EXTRA,0,1,nil)
	-- 检查额外卡组是否存在1只当前可以进行超量召唤的「魔键」超量怪兽。
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
		-- 让玩家从“同调召唤”“超量召唤”“什么都不做”中选择一项，并返回对应选项序号。
		local op=Duel.SelectOption(tp,table.unpack(ops))+1
		local sel=opval[op]
		if sel==0 then
			-- 中断当前效果处理，使后续同调召唤被视为新的处理，避免时点错误。
			Duel.BreakEffect()
			-- 弹出“请选择要特殊召唤的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从额外卡组选择1只当前可以进行同调召唤的「魔键」同调怪兽。
			local sg1=Duel.SelectMatchingCard(tp,c40493210.syncsumfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			-- 使用自己场上的怪兽作为素材，将选择的「魔键」同调怪兽进行同调召唤。
			Duel.SynchroSummon(tp,sg1:GetFirst(),nil)
		elseif sel==1 then
			-- 中断当前效果处理，使后续超量召唤被视为新的处理，避免时点错误。
			Duel.BreakEffect()
			-- 弹出“请选择要特殊召唤的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从额外卡组选择1只当前可以进行超量召唤的「魔键」超量怪兽。
			local sg2=Duel.SelectMatchingCard(tp,c40493210.xyzsumfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			-- 使用自己场上的怪兽作为素材，将选择的「魔键」超量怪兽进行超量召唤。
			Duel.XyzSummon(tp,sg2:GetFirst(),nil)
		end
	end
end
