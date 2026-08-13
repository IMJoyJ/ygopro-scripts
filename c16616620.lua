--コンタクト
-- 效果：
-- 把自己场上名字带有「茧状体」的怪兽全部送去墓地，那些卡记述的1只怪兽从手卡·卡组特殊召唤。
function c16616620.initial_effect(c)
	-- 把自己场上名字带有「茧状体」的怪兽全部送去墓地，那些卡记述的1只怪兽从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c16616620.target)
	e1:SetOperation(c16616620.activate)
	c:RegisterEffect(e1)
end
-- filter1：判定场上的一张表侧表示「茧状体」怪兽能否作为效果的发动素材，即该卡必须表侧表示且属于「茧状体」字段，并且手卡·卡组中至少存在1只该卡记述的、可特殊召唤的「新空间侠」怪兽。
function c16616620.filter1(c,e,tp)
	-- 返回真当且仅当这张「茧状体」怪兽表侧表示、字段为「茧状体」，且手卡·卡组中存在至少1只满足filter2的（该卡记述的）「新空间侠」怪兽。
	return c:IsFaceup() and c:IsSetCard(0x1e) and Duel.IsExistingMatchingCard(c16616620.filter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,c,e,tp)
end
-- filter2：判定手卡·卡组中的一张「新空间侠」怪兽能否因某张「茧状体」怪兽被送入墓地而特殊召唤；要求它属于「新空间侠」字段、其卡号被该「茧状体」的效果文本记载，并且能够被这次效果特殊召唤。
function c16616620.filter2(c,mc,e,tp)
	-- 返回真当且仅当候选怪兽属于「新空间侠」字段、其卡号记载于被检索依据的「茧状体」怪兽的效果文本中，且能够被特殊召唤。
	return c:IsSetCard(0x1f) and aux.IsCodeListed(mc,c:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- target（发动条件判定）：仅在效果发动时检查是否场上存在至少1张表侧表示且属于「茧状体」字段的怪兽，并且手卡·卡组中存在其记述的可特殊召唤怪兽；不要求发动时已有空位，因为送墓后会腾出怪兽区。
function c16616620.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件的第一步：允许当前怪兽区没有空位（可用区域数>-1表示至少为0即可），因为之后把「茧状体」全部送墓会空出区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 发动条件的第二步：场上存在至少1张表侧表示且属于「茧状体」字段的怪兽，且手卡·卡组中存在该卡记述的、可以特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c16616620.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向系统登记本次连锁的操作信息：类别为特殊召唤，将从手卡·卡组特殊召唤1只怪兽；因特殊召唤对象在处理时才确定，故targets设为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- filter3：效果处理时筛选场上的表侧表示且属于「茧状体」字段的怪兽，用于全部送入墓地。
function c16616620.filter3(c)
	return c:IsFaceup() and c:IsSetCard(0x1e)
end
-- activate（效果处理）：获取场上所有表侧表示的「茧状体」怪兽；若无则结束；全部送入墓地；然后遍历这些卡，收集各自记述的、可特殊召唤的「新空间侠」怪兽；若存在候选，则选择其中1只表侧表示特殊召唤到自己场上。
function c16616620.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有表侧表示且属于「茧状体」字段的怪兽，作为本效果要送去墓地的对象。
	local g=Duel.GetMatchingGroup(c16616620.filter3,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()==0 then return end
	-- 以效果原因把获取到的「茧状体」怪兽全部送入墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
	local sg=Group.CreateGroup()
	local tc=g:GetFirst()
	while tc do
		-- 针对当前这张被送去墓地的「茧状体」怪兽tc，从手卡·卡组中检索所有满足filter2（即属于「新空间侠」、被tc记载且可特殊召唤）的怪兽，并合并到候选集合sg中。
		local tg=Duel.GetMatchingGroup(c16616620.filter2,tp,LOCATION_HAND+LOCATION_DECK,0,nil,tc,e,tp)
		sg:Merge(tg)
		tc=g:GetNext()
	end
	if sg:GetCount()>0 then
		-- 显示提示消息，要求玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local spg=sg:Select(tp,1,1,nil)
		-- 将玩家选择的那1只怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
	end
end
