--ナチュル・ホワイトオーク
-- 效果：
-- 这张卡成为对方的卡的效果的对象时才能发动。把自己场上表侧表示存在的这张卡送去墓地，从自己卡组把2只4星以下的名字带有「自然」的怪兽特殊召唤。这个效果特殊召唤的怪兽不能攻击宣言，自己的结束阶段时破坏。
function c24644634.initial_effect(c)
	-- 这张卡成为对方的卡的效果的对象时才能发动。把自己场上表侧表示存在的这张卡送去墓地，从自己卡组把2只4星以下的名字带有「自然」的怪兽特殊召唤。这个效果特殊召唤的怪兽不能攻击宣言，自己的结束阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24644634,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c24644634.spcon)
	e1:SetCost(c24644634.spcost)
	e1:SetTarget(c24644634.sptg)
	e1:SetOperation(c24644634.spop)
	c:RegisterEffect(e1)
end
-- 发动条件判定：仅在对方玩家发动的取对象效果以这张卡为对象时才能发动；若发动者为自己或效果不取对象则不满足。
function c24644634.spcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 从当前连锁信息中取得对方那个效果所选择的全部对象卡组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsContains(e:GetHandler())
end
-- 代价判定与支付：把自身从场上表侧表示送去墓地作为发动代价；先检查此卡能否作为代价送墓，若不能则无法发动。
function c24644634.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身以“代价”原因送去墓地，完成COST支付。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选条件：等级4以下、持有「自然」字段、且能被玩家tp以效果形式特殊召唤（满足苏生限制等）的怪兽，用于从卡组检索可特召的目标。
function c24644634.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x2a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时点检查：确认此效果可发动——不存在青眼精灵龙等禁止同时特殊召唤2只以上怪兽的限制、自己主要怪兽区有可用空格、卡组中存在至少2只符合条件的自然怪兽。
function c24644634.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认自己场上拥有至少1个可用的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组中是否存在至少2只符合筛选条件的「自然」怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(c24644634.filter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 设置操作信息：本次效果将要进行2只怪兽的特殊召唤，来源为卡组，具体卡片在效果处理时确定（不取对象），供相关卡（如星尘龙）的发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：若青眼精灵龙的限制不存在且自己怪兽区至少有两个空格，从卡组选出2只符合条件的「自然」怪兽特殊召唤，并给它们附加不能攻击宣言的效果，同时注册结束阶段破坏的领域效果。
function c24644634.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次确认自己场上至少有2个可用的怪兽区域，否则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取卡组中所有符合特殊召唤条件的「自然」怪兽集合，作为本次选择的候选组。
	local g=Duel.GetMatchingGroup(c24644634.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		local fid=e:GetHandler():GetFieldID()
		-- 弹出选择提示“请选择要特殊召唤的卡”，并写入选择消息缓存供玩家选择。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选中的2只怪兽以表侧表示特殊召唤到自己的主要怪兽区域（召唤条件与苏生限制已在筛选中确认）。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		local tc=sg:GetFirst()
		tc:RegisterFlagEffect(24644634,RESET_EVENT+RESETS_STANDARD,0,0,fid)
		-- 这个效果特殊召唤的怪兽不能攻击宣言。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=sg:GetNext()
		tc:RegisterFlagEffect(24644634,RESET_EVENT+RESETS_STANDARD,0,0,fid)
		local e2=e1:Clone()
		tc:RegisterEffect(e2)
		sg:KeepAlive()
		-- 自己的结束阶段时，将因此效果特殊召唤的怪兽破坏。
		local de=Effect.CreateEffect(e:GetHandler())
		de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		de:SetCode(EVENT_PHASE+PHASE_END)
		de:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		de:SetCountLimit(1)
		de:SetLabel(fid)
		de:SetLabelObject(sg)
		de:SetCondition(c24644634.descon)
		de:SetOperation(c24644634.desop)
		-- 将结束阶段破坏的领域效果注册给当前玩家tp，使该效果开始持续生效。
		Duel.RegisterEffect(de,tp)
	end
end
-- 判定某只怪兽是否为本次效果特殊召唤的怪兽：通过身上登记的标记值（fid）与保存的标记值一致来识别。
function c24644634.desfilter(c,fid)
	return c:GetFlagEffectLabel(25935625)==fid
end
-- 结束阶段破坏效果的发动条件：仅在tp自己的结束阶段，且存在仍未离场的、由本效果特殊召唤的怪兽时满足；若相关怪兽均已离场则清除该效果并停止结算。
function c24644634.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 仅在tp自己的结束阶段才可能触发，否则不执行后续破坏。
	if Duel.GetTurnPlayer()~=tp then return end
	local g=e:GetLabelObject()
	if not g:IsExists(c24644634.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 破坏效果处理：将本效果特殊召唤且仍在场上的一只或多只怪兽破坏。
function c24644634.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c24644634.desfilter,nil,e:GetLabel())
	-- 以“效果”为原因将那些符合标记的特召怪兽破坏。
	Duel.Destroy(tg,REASON_EFFECT)
end
