--GP－スタート・エンジン
-- 效果：
-- ①：对方把怪兽召唤·特殊召唤的场合，以那1只怪兽为对象才能发动。从卡组把3只「黄金荣耀」怪兽给对方观看，对方从那之中随机选1只。那1只怪兽在自己场上特殊召唤，剩余回到卡组。那之后，作为对象的怪兽破坏。
local s,id,o=GetID()
-- 创建并注册效果：对方把怪兽通常召唤成功时，以那1只怪兽为对象才能发动；再克隆出同样效果用于特殊召唤成功时点。
function s.initial_effect(c)
	-- 对方把怪兽召唤·特殊召唤的场合，以那1只怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 筛选可作为对象的怪兽：由对方玩家召唤/特殊召唤、位于主要怪兽区且当前能成为效果对象的怪兽。
function s.dgfilter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation (LOCATION_MZONE) and c:IsCanBeEffectTarget(e)
end
-- 筛选卡组中满足条件的「黄金荣耀」怪兽，且可以被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x192) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与操作信息设定：选择对方召唤的1只怪兽作为对象，并登记破坏与特殊召唤的处理信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.dgfilter(chkc,e,tp) end
	-- 获取己方卡组中所有可特殊召唤的「黄金荣耀」怪兽。
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 发动条件检查：场上存在可选对象、卡组中至少3只「黄金荣耀」怪兽、己方怪兽区有空位。
	if chk==0 then return eg:IsExists(s.dgfilter,1,nil,e,tp) and #sg>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local dg=eg
	if #eg>1 then
		-- 当可选择的对方怪兽多于1只时，提示发动者选择其中1只作为要破坏的对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		dg=eg:FilterSelect(tp,s.dgfilter,1,1,nil,e,tp)
	end
	-- 将选定的对方怪兽设置为当前连锁的效果对象（即取对象）。
	Duel.SetTargetCard(dg)
	-- 登记破坏效果的操作信息：已知将破坏的对象为dg，数量1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	-- 登记特殊召唤效果的操作信息：特召卡在效果处理时确定，来源为卡组，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理流程：从卡组选3张「黄金荣耀」给对方确认，对方随机选1张由己方特殊召唤，成功后破坏对象怪兽。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新获取卡组中可特殊召唤的「黄金荣耀」怪兽。
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 若卡组不足3只或己方没有可用怪兽区，则整个效果不处理。
	if #g<3 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示发动者选择3张要展示给对方的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local sg=g:Select(tp,3,3,nil)
	-- 将选出的3张「黄金荣耀」怪兽展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,sg)
	-- 展示完成后洗切卡组，恢复卡组顺序随机性。
	Duel.ShuffleDeck(tp)
	local cg=sg:RandomSelect(1-tp,1)
	-- 对方从3张中随机选1张，由己方将其表侧表示特殊召唤到己方场上。
	if Duel.SpecialSummon(cg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取作为效果对象的对方怪兽。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 中断当前连锁的处理，使后续破坏作为独立时点处理，避免与特殊召唤同时诱发时点。
			Duel.BreakEffect()
			-- 将作为对象的对方怪兽破坏。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
