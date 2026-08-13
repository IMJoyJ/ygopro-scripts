--ジャンク・シグナル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下选择1个发动。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ●把自己场上1只怪兽解放才能发动。除那只怪兽外的1只「废品战士」「星尘龙」或者有那其中任意种的卡名记述的怪兽从自己的手卡·卡组·墓地特殊召唤。
-- ●对方连锁自己的同调怪兽的效果的发动把效果发动时才能发动。那个对方的效果无效。
local s,id,o=GetID()
-- 注册「废品信号」的发动效果：设置其描述、效果分类（特殊召唤+无效）、类型为魔法发动、自由时点、同名卡1回合1次（誓约），并指定目标选择与效果处理函数。
function s.initial_effect(c)
	-- 记录本卡效果文本中记述的卡名：「废品战士」(60800381)和「星尘龙」(44508094)，供后续按卡名或记述卡名检索。
	aux.AddCodeList(c,60800381,44508094)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下选择1个发动。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_CHAIN_END)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 解放候选的筛选函数：判断解放该怪兽后，是否还存在可从手卡·卡组·墓地特殊召唤的合格怪兽，且自己场上仍有可用的怪兽区。
function s.resfilter(c,e,tp)
	-- 检查从手卡·卡组·墓地是否存在至少1只满足s.filter的怪兽（排除作为解放候选的这张卡）。
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,c,e,tp)
		-- 并且要确保解放该候选怪兽后，自己场上仍有至少1个可用的怪兽区。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤目标的筛选函数：卡名是「废品战士」或「星尘龙」，或效果文本中记述了其中任意种卡名的怪兽，且可以被特殊召唤；若传入fid，则排除被解放的那只怪兽（通过FieldID）。
function s.filter(c,e,tp,fid)
	-- 目标怪兽必须是「废品战士」「星尘龙」，或卡名记述了其中任意一种的怪兽。
	return (aux.IsCodeOrListed(c,60800381) or aux.IsCodeOrListed(c,44508094))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (fid==nil or c:GetFieldID()~=fid)
end
-- 发动的目标判定与分支选择：分别检查“解放特召”和“无效对方效果”两个选项是否可发动；发动时让玩家选择执行哪个分支，并支付相应代价、设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在1只满足s.resfilter的怪兽可以作为解放代价。
	local b1=Duel.CheckReleaseGroup(tp,s.resfilter,1,nil,e,tp)
	-- 取得当前连锁序号，用于定位对方连锁我方同调怪兽效果而发动的效果。
	local ch=Duel.GetCurrentChain()
	local b2=false
	if e:GetHandler():IsStatus(STATUS_CHAINING) then ch=ch-1 end
	local tse=nil
	if ch>1 then
		-- 取得当前连锁上一连锁的效果及其发动玩家，用于判断是否为“自己同调怪兽效果的发动”。
		local se,p=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		-- 取得当前连锁（即对方连锁发动的那次效果）的效果，作为要被无效的对象。
		tse=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT)
		-- 取得要被无效的那个对方效果的发动玩家，用于确认是对方发动的效果。
		local tep=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER)
		-- 组合判定第二个选项：上一连锁是自己同调怪兽效果且发动者是自己，当前连锁是对方发动的效果，且该效果可以被无效。
		b2=se and se:GetHandler():IsType(TYPE_SYNCHRO) and se:IsActiveType(TYPE_MONSTER) and p==tp and tep==1-tp and Duel.IsChainDisablable(ev)
	end
	if chk==0 then return b1 or b2 end
	-- 让玩家在两个选项中选择要发动的分支：选项1为解放特召（若b1真），选项2为无效效果（若b2真），返回选项编号。
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},  --"特殊召唤"
		{b2,aux.Stringid(id,2),2})  --"效果无效"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 选择并取得1只自己场上可解放的怪兽（满足resfilter）作为发动代价。
		local cost_card=Duel.SelectReleaseGroup(tp,s.resfilter,1,1,nil,e,tp):GetFirst()
		-- 将选择的怪兽解放，作为发动代价（REASON_COST）。
		Duel.Release(cost_card,REASON_COST)
		local fid=cost_card:GetFieldID()
		e:SetLabel(1,fid)
		-- 设置操作信息：本次处理将进行特殊召唤，预定从手卡·卡组·墓地特殊召唤1只怪兽（对象在处理时确定，故targets为nil）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
	elseif op==2 then
		e:SetCategory(CATEGORY_DISABLE)
		if tse then
			local og=Group.FromCards(tse:GetHandler())
			-- 设置操作信息：无效对象为对方发动的那张效果卡（tse的Handler），处理分类为无效效果。
			Duel.SetOperationInfo(0,CATEGORY_DISABLE,og,1,0,0)
		end
	end
end
-- 效果处理：先给己方附加“这个回合，自己不是同调怪兽不能从额外卡组特殊召唤”的自肃；若选择分支1，则从手卡·卡组·墓地特殊召唤符合条件的1只怪兽；若选择分支2，则无效对方那个效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。●把自己场上1只怪兽解放才能发动。除那只怪兽外的1只「废品战士」「星尘龙」或者有那其中任意种的卡名记述的怪兽从自己的手卡·卡组·墓地特殊召唤。●对方连锁自己的同调怪兽的效果的发动把效果发动时才能发动。那个对方的效果无效。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	e0:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上，影响的玩家为自己（tp），持续到回合结束。
	Duel.RegisterEffect(e0,tp)
	local op,fid=e:GetLabel()
	if op==1 then
		-- 选择特召分支时，若自己场上没有可用的怪兽区则无法特殊召唤，直接结束。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 给出选择要特殊召唤的怪兽的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的手卡·卡组·墓地中选择1只满足s.filter且不受王家长眠之谷影响的怪兽，并排除被解放的怪兽（fid）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,fid)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		-- 取得当前连锁序号，以定位要无效的对方效果（上一连锁）。
		local ch=Duel.GetCurrentChain()
		-- 无效连锁序号为ch-1的效果，即对方连锁我方同调怪兽效果而发动的那次效果。
		Duel.NegateEffect(ch-1)
	end
end
-- 自肃判定条件：不是同调怪兽且位于额外卡组的怪兽不能特殊召唤。
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
