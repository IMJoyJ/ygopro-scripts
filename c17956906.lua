--終幕の光
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：支付1000的倍数的基本分，以支付的基本分每1000为1只的自己墓地的「女武神」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。那之后，对方可以从自身墓地选最多有这个效果特殊召唤的怪兽数量的攻击力2000以下的怪兽特殊召唤。
function c17956906.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：支付1000的倍数的基本分，以支付的基本分每1000为1只的自己墓地的「女武神」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。那之后，对方可以从自身墓地选最多有这个效果特殊召唤的怪兽数量的攻击力2000以下的怪兽特殊召唤。
	local e1 = Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,17956906+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c17956906.cost)
	e1:SetTarget(c17956906.target)
	e1:SetOperation(c17956906.operation)
	c:RegisterEffect(e1)
end
-- 定义可作为对象的墓地「女武神」怪兽的筛选条件：属于「女武神」系列、能被当前效果特殊召唤且能成为效果对象。
function c17956906.spfilter(c,e,tp)
	return c:IsSetCard(0x122) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(e)
end
-- 效果发动时先给效果标记标签100，用于确认已进入发动流程；实际LP支付延迟到选择对象时处理。
function c17956906.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetLabel(100)
		return true
	end
end
-- 目标选择流程：获取符合条件的墓地「女武神」怪兽和可用怪兽区；根据可支付LP倍数及青眼精灵龙限制计算可特殊召唤数量上限；选择支付LP倍数，选择对应数量且卡名互不相同的「女武神」怪兽作为对象，并设置特殊召唤信息。
function c17956906.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己墓地中满足特殊召唤条件且可成为效果对象的「女武神」怪兽组。
	local g=Duel.GetMatchingGroup(c17956906.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取自己场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return false end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查发动条件：有可用怪兽区、墓地有符合条件的「女武神」怪兽、且至少能支付1000LP。
		return ft>0 and g:GetCount()>0 and Duel.CheckLPCost(tp,1000,true)
	end
	e:SetLabel(0)
	local ct=math.min(g:GetClassCount(Card.GetCode),ft)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		ct=1
	end
	local pay_list = {}
	for p=1,ct do
		-- 对每个可能的倍数p，检查能否支付1000*p的LP，若可以则将该倍数加入可选支付列表。
		if Duel.CheckLPCost(tp,1000*p,true) then table.insert(pay_list,p) end
	end
	-- 提示玩家选择要特殊召唤的怪兽数量（显示“请选择要特殊召唤的怪兽数量”）。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(17956906,0))  --"请选择要特殊召唤的怪兽数量"
	-- 让玩家从可选LP倍数中宣言一个数值，作为支付的LP倍数（即特殊召唤数量）。
	local pay=Duel.AnnounceNumber(tp,table.unpack(pay_list))
	-- 支付宣言倍数对应的基本分（支付pay*1000 LP）。
	Duel.PayLPCost(tp,pay*1000,true)
	-- 提示玩家选择要特殊召唤的卡（显示“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 设置额外选择条件为“卡名互不相同”，确保选择的「女武神」怪兽同名最多1张。
	aux.GCheckAdditional=aux.dncheck
	-- 让玩家从候选组中选择恰好pay张卡（卡名互不相同的「女武神」怪兽），作为效果对象。
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,pay,pay)
	-- 清除额外选择条件，避免影响后续。
	aux.GCheckAdditional=nil
	-- 将选择的卡组设为当前连锁的对象。
	Duel.SetTargetCard(sg)
	-- 设置特殊召唤的操作信息，供后续处理及环境影响检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,sg:GetCount(),0,0)
end
-- 定义对方墓地中可被对方选择并特殊召唤的怪兽的筛选条件：攻击力2000以下且能被特殊召唤。
function c17956906.spfilter2(c,e,tp)
	return c:IsAttackBelow(2000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理流程：确认对象仍有效；若有青眼精灵龙限制则不能同时特殊召唤2只以上怪兽；若对象数量超过怪兽区空格则选择；特殊召唤对象；然后对方可选择从自身墓地特殊召唤最多同数量的攻击力2000以下怪兽（若青眼精灵龙在场则最多1只），并使用BreakEffect分段处理。
function c17956906.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用怪兽区域数量（用于特殊召唤「女武神」怪兽）。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 取得当前连锁处理中的对象卡组（即之前选择的「女武神」怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡（当怪兽区数量不足时需要选择）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 将选择的「女武神」怪兽以表侧表示特殊召唤到己方场上，ct为成功数量。
	local ct=Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	if ct<=0 then return end
	-- 获取对方墓地中满足条件（攻击力2000以下且可特殊召唤）的怪兽组，以便对方选择特殊召唤。
	local g2=Duel.GetMatchingGroup(c17956906.spfilter2,tp,0,LOCATION_GRAVE,nil,e,1-tp)
	-- 计算对方可特殊召唤数量：对方可用怪兽区空格与本次特殊召唤数量ct的较小值。
	local ct2=math.min(Duel.GetLocationCount(1-tp,LOCATION_MZONE),ct)
	if g2:GetCount()>0 and ct2>0
		-- 询问对方玩家是否要特殊召唤（提示“是否特殊召唤？”），只有选择“是”才继续处理。
		and Duel.SelectYesNo(1-tp,aux.Stringid(17956906,1)) then  --"是否特殊召唤？"
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(1-tp,59822133) then ct2=1 end
		-- 中断当前效果处理，使后续操作视为另一段连锁处理（避免错失时点等）。
		Duel.BreakEffect()
		-- 提示对方玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=g2:Select(1-tp,1,ct2,nil)
		-- 将对方选择的怪兽以表侧表示特殊召唤到对方场上。
		Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP)
	end
end
