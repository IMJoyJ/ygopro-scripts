--ミラー ソードナイト
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡解放才能发动。把「镜剑骑士」以外的有「合成兽融合」的卡名记述的1只怪兽从卡组特殊召唤。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ③：自己场上有「有翼幻兽 奇美拉」存在，对方场上的怪兽把效果发动时，把场上·墓地的这张卡除外才能发动。那个效果无效。
local s,id,o=GetID()
-- 初始化镜剑骑士的效果注册：先登记‘合成兽融合’卡名；随后注册②的永续战斗破坏耐性、①的解放自身从卡组特召、③的除外自身无效对方怪兽效果。
function s.initial_effect(c)
	-- 将‘合成兽融合’（卡号63136489）登记到镜剑骑士的记载卡名列表中，使后续‘有“合成兽融合”卡名记述’的检索条件可以成立。
	aux.AddCodeList(c,63136489)
	-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这个卡名的①③的效果1回合各能使用1次。①：自己·对方回合，把这张卡解放才能发动。把「镜剑骑士」以外的有「合成兽融合」的卡名记述的1只怪兽从卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：自己场上有「有翼幻兽 奇美拉」存在，对方场上的怪兽把效果发动时，把场上·墓地的这张卡除外才能发动。那个效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"对方效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_GRAVE+LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.discon)
	-- 设置③效果的发动代价为将这张卡除外；通过aux.bfgcost实现‘把场上·墓地的这张卡除外才能发动’的cost。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 定义②效果的保护对象：当某张卡为此卡自身或与此卡进行战斗的怪兽时，该卡不会被战斗破坏。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 定义①效果的cost：解放此卡，且需要确保解放后自己场上留有可用的怪兽区；随后执行解放。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检查阶段：确认此卡可以解放，且解放后自己场上仍有可用的怪兽区（因为后续要特殊召唤怪兽）。
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 实际执行代价：将此卡解放，送入墓地。
	Duel.Release(c,REASON_COST)
end
-- 定义①效果要特殊召唤的卡的筛选条件：效果文本记载有‘合成兽融合’、可被当前效果特殊召唤、卡名不能是‘镜剑骑士’。
function s.filter(c,e,tp)
	-- 判定一张卡是否满足检索条件：记载了卡号63136489（合成兽融合）、可以特殊召唤、不是镜剑骑士。
	return aux.IsCodeListed(c,63136489) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
-- 定义①效果的Target：先检查卡组中是否存在可特殊召唤的符合条件的卡，并设置操作信息；以便发动后从卡组特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：自己的卡组中存在至少1张满足s.filter筛选条件的怪兽，否则不能发动①。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向对方玩家提示镜剑骑士发动了①效果，并展示效果描述文字。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本次连锁将进行特殊召唤，预计从卡组特殊召唤1只怪兽；因具体卡牌在处理时选择，目标暂为空。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义①效果处理时的操作：检查空位、提示选卡、选择符合条件的卡并特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查自己怪兽区是否有空位；若没有空位则本次特殊召唤不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示发动玩家选择要特殊召唤的卡，提示消息为‘请选择要特殊召唤的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张满足s.filter条件的卡，并返回选择结果g（作为本次特殊召唤的对象）。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义‘有翼幻兽 奇美拉’的判定条件：表侧表示且卡号为4796100。
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(4796100)
end
-- 定义③效果的发动条件：对方场上的怪兽效果发动、该效果可被无效，且自己场上有表侧表示的‘有翼幻兽 奇美拉’。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁（ev）中效果的发动者所属玩家和发动位置，用于判断是否为对方场上怪兽的效果。
	local tgp,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	-- 确认该效果由对方玩家发动、发动位置在怪兽区，且该效果能够被无效。
	return tgp==1-tp and loc==LOCATION_MZONE and Duel.IsChainDisablable(ev)
		-- 追加条件：自己场上存在表侧表示的‘有翼幻兽 奇美拉’。满足上述全部条件时③效果可发动。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义③效果的Target：不需要指定某个对象，仅将‘无效对象’设定为正在发动的效果；然后登记操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示镜剑骑士发动了③效果，并展示效果描述文字。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本次连锁将无效效果，对象为正在发动的效果（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 定义③效果处理时的操作：执行无效处理，使对方发动的效果无效。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.NegateEffect使连锁ev的效果无效化，即‘那个效果无效’。
	Duel.NegateEffect(ev)
end
