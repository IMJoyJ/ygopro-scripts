--忍法 分身の術
-- 效果：
-- ①：把自己场上1只「忍者」怪兽解放才能把这张卡发动。等级合计最多到解放的怪兽的等级以下为止，从卡组选「忍者」怪兽任意数量各以表侧攻击表示或者里侧守备表示特殊召唤。这张卡从场上离开时那些怪兽全部破坏。
function c50766506.initial_effect(c)
	-- ①：把自己场上1只「忍者」怪兽解放才能把这张卡发动。等级合计最多到解放的怪兽的等级以下为止，从卡组选「忍者」怪兽任意数量各以表侧攻击表示或者里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c50766506.target)
	e1:SetOperation(c50766506.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那些怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c50766506.desop)
	c:RegisterEffect(e2)
end
-- 作为解放候选的筛选函数：该怪兽必须是等级大于0的「忍者」怪兽，且解放后场上能空出至少1个可用怪兽区域（要么当前有空位，要么解放的怪兽位于己方主要怪兽区可以腾出格子），并且卡组中存在至少1只等级不超过该怪兽等级的「忍者」怪兽可作为特殊召唤目标。
function c50766506.cfilter(c,e,tp,ft)
	local lv=c:GetLevel()
	return lv>0 and c:IsSetCard(0x2b)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
		-- 检查卡组中是否存在满足等级限制且可以特殊召唤的「忍者」怪兽，确保解放该只怪兽后至少能从卡组特殊召唤1只符合条件的怪兽。
		and Duel.IsExistingMatchingCard(c50766506.spfilter,tp,LOCATION_DECK,0,1,nil,lv,e,tp)
end
-- 筛选特殊召唤候选：等级不超过解放怪兽等级、是「忍者」怪兽，并且可以以表侧攻击表示或里侧守备表示特殊召唤。
function c50766506.spfilter(c,lv,e,tp)
	return c:IsLevelBelow(lv) and c:IsSetCard(0x2b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- 发动时点目标处理：执行发动合法性判定、选择并解放1只「忍者」怪兽作为代价，同时记录其等级作为后续选择特召怪兽的数量与等级合计上限，并向系统登记特殊召唤的操作信息。
function c50766506.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方主要怪兽区可用空格数，用于判断能否特殊召唤以及可特殊召唤的数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 效果发动前的合法性检查：必须有至少1个可用怪兽区域（或可通过解放腾出），并且场上存在可以作为代价解放的「忍者」怪兽；否则不能发动。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c50766506.cfilter,1,nil,e,tp,ft) end
	-- 从己方场上选择1只满足条件的「忍者」怪兽作为解放代价。
	local rg=Duel.SelectReleaseGroup(tp,c50766506.cfilter,1,1,nil,e,tp,ft)
	e:SetLabel(rg:GetFirst():GetLevel())
	-- 将选中的「忍者」怪兽解放，作为效果发动的COST。
	Duel.Release(rg,REASON_COST)
	-- 设置本次效果的操作信息：登记从卡组进行特殊召唤，供系统判断相关效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 选择子组时的等级合计判定：所选「忍者」怪兽的等级合计不得超过解放怪兽的等级（slv）。
function c50766506.gselect(g,slv)
	return g:GetSum(Card.GetLevel)<=slv
end
-- 效果处理：根据解放怪兽的等级，从卡组筛选符合条件的「忍者」怪兽，由玩家选择任意数量（等级合计不超过上限且数量不超过可用怪兽区空格），以表侧攻击表示或里侧守备表示进行特殊召唤；同时让本卡与特召怪兽建立关联，以便离场时全部破坏，并让对方确认里侧守备表示特召的怪兽。
function c50766506.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次获取己方主要怪兽区可用格数，作为本次可特殊召唤数量的上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local c=e:GetHandler()
	local slv=e:GetLabel()
	-- 从卡组筛选出所有等级不超过解放怪兽等级、且可以特殊召唤的「忍者」怪兽，作为候选集合。
	local sg=Duel.GetMatchingGroup(c50766506.spfilter,tp,LOCATION_DECK,0,nil,slv,e,tp)
	if sg:GetCount()==0 then return end
	-- 弹出选择提示，要求玩家从候选的「忍者」怪兽中选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tg=sg:SelectSubGroup(tp,c50766506.gselect,false,1,ft,slv)
	local cg=Group.CreateGroup()
	-- 遍历玩家选择的所有将要特殊召唤的「忍者」怪兽。
	for tc in aux.Next(tg) do
		-- 以表侧攻击表示或里侧守备表示，将当前怪兽特殊召唤上场（使用分步特殊召唤，便于同时处理多只怪兽）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
		if tc:IsFacedown() then cg:AddCard(tc) end
		c:SetCardTarget(tc)
	end
	-- 完成分步特殊召唤流程，触发特殊召唤成功的相关时点。
	Duel.SpecialSummonComplete()
	-- 向对方玩家确认以里侧守备表示特殊召唤的怪兽，满足里侧表示怪兽的特殊召唤确认规则。
	Duel.ConfirmCards(1-tp,cg)
end
-- 离场破坏效果的处理函数：取得这张卡通过效果关联的特殊召唤怪兽，并破坏其中仍存在于怪兽区域的那些。
function c50766506.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget():Filter(Card.IsLocation,nil,LOCATION_MZONE)
	-- 以效果为原因，将关联的特殊召唤「忍者」怪兽全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
