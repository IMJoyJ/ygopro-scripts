--生存境界
-- 效果：
-- ①：场上的通常怪兽全部破坏，把最多有破坏数量的4星以下的恐龙族怪兽从卡组往自己场上特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
-- ②：把墓地的这张卡除外，以自己场上1只恐龙族怪兽和对方场上1张卡为对象才能发动。那些卡破坏。
function c44612603.initial_effect(c)
	-- ①：场上的通常怪兽全部破坏，把最多有破坏数量的4星以下的恐龙族怪兽从卡组往自己场上特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44612603,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c44612603.target)
	e1:SetOperation(c44612603.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只恐龙族怪兽和对方场上1张卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44612603,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 设置②效果的发动代价：把墓地的这张卡除外（aux.bfgcost实现除外自身作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44612603.destg)
	e2:SetOperation(c44612603.desop)
	c:RegisterEffect(e2)
end
-- 过滤场上的表侧表示通常怪兽（用于①效果要破坏的“通常怪兽”）。
function c44612603.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
-- 筛选可特殊召唤的恐龙族怪兽：4星以下、恐龙族且当前可被特殊召唤（用于①效果从卡组特召）。
function c44612603.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定：场上存在表侧通常怪兽，且手牌·卡组存在4星以下恐龙族可特殊召唤的怪兽。
function c44612603.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在表侧表示通常怪兽（双方怪兽区合计至少1张）。
	if chk==0 then return Duel.IsExistingMatchingCard(c44612603.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查手牌·卡组是否存在满足条件的恐龙族怪兽（4星以下且可特殊召唤）。
		and Duel.IsExistingMatchingCard(c44612603.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 获取场上所有表侧通常怪兽，作为①效果将要破坏的对象组。
	local g=Duel.GetMatchingGroup(c44612603.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 向系统登记破坏操作信息：对象为场上全部通常怪兽，数量为其数量，供星尘龙等效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 向系统登记特殊召唤操作信息：从卡组特殊召唤，对象未确定，数量暂记1，归属玩家tp。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理①效果：破坏场上所有表侧通常怪兽，再根据破坏数量在自己场上特殊召唤最多相同数量的4星以下恐龙族怪兽（可用区域受青眼精灵龙限制为1只），并给这些怪兽注册结束阶段破坏的效果。
function c44612603.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取场上的表侧通常怪兽（以实际处理时场上的状态为准）。
	local g=Duel.GetMatchingGroup(c44612603.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因破坏这些通常怪兽，并返回实际破坏数量n。
	local n=Duel.Destroy(g,REASON_EFFECT)
	if n~=0 then
		-- 从卡组筛选满足条件的恐龙族怪兽（4星以下且可特殊召唤）作为可特召候选组。
		local tg=Duel.GetMatchingGroup(c44612603.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 获取自己场上可用的主要怪兽区空格数，用于限制特殊召唤数量。
		local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ct<0 then return end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
		ct=math.min(ct,n)
		if ct>0 and tg:GetCount()>0 then
			-- 中断当前效果，将破坏处理与后续特殊召唤处理视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 提示己方玩家选择要特殊召唤的卡（显示“请选择要特殊召唤的卡”）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=tg:Select(tp,1,ct,nil)
			-- 将选择的恐龙族怪兽以表侧攻击表示特殊召唤到自己场上；若特召成功则继续为其注册结束阶段破坏效果。
			if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
				-- 获取本次特殊召唤实际成功的怪兽组，用于后续给它们逐一标记和注册破坏效果。
				local sg2=Duel.GetOperatedGroup()
				local fid=e:GetHandler():GetFieldID()
				local tc=sg2:GetFirst()
				while tc do
					tc:RegisterFlagEffect(44612603,RESET_EVENT+RESETS_STANDARD,0,0,fid)
					tc=sg2:GetNext()
				end
				sg2:KeepAlive()
				-- 这个效果特殊召唤的怪兽在结束阶段破坏。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetCountLimit(1)
				e1:SetLabel(fid)
				e1:SetLabelObject(sg2)
				e1:SetCondition(c44612603.descon2)
				e1:SetOperation(c44612603.desop2)
				-- 将结束阶段破坏效果注册到场上作为持续效果，用于处理①效果特召的怪兽在结束阶段被破坏。
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
-- 判明某只怪兽是否带有本次特殊召唤时分配的标记fid（即是否为①效果特殊召唤的怪兽）。
function c44612603.desfilter2(c,fid)
	return c:GetFlagEffectLabel(44612603)==fid
end
-- 结束阶段破坏效果的发动条件：若已不存在带对应标记的怪兽，则清理该效果并返回false；否则返回true。
function c44612603.descon2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c44612603.desfilter2,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段时，将仍存在且带对应标记的怪兽破坏（①效果的结束阶段破坏处理）。
function c44612603.desop2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c44612603.desfilter2,nil,e:GetLabel())
	-- 以效果原因破坏这些怪兽（①效果特召的怪兽在结束阶段被破坏，且该持续效果带EFFECT_FLAG_IGNORE_IMMUNE，可无视免疫破坏效果）。
	Duel.Destroy(tg,REASON_EFFECT)
end
-- 判明表侧表示的恐龙族怪兽（用于②效果选择自己场上的恐龙族对象）。
function c44612603.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
-- ②效果的发动判定：chk==0时检查自己场上是否有表侧恐龙族怪兽、对方场上是否有卡可作为对象；若在连锁处理中指定过对象（chkc）则返回false。
function c44612603.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在表侧表示的恐龙族怪兽（可作为②效果的对象）。
	if chk==0 then return Duel.IsExistingTarget(c44612603.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在卡（可作为②效果的对象）。
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示己方玩家选择要破坏的自己场上的恐龙族怪兽（显示“请选择要破坏的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只表侧恐龙族怪兽作为②效果的对象（同时登记为当前连锁对象）。
	local g1=Duel.SelectTarget(tp,c44612603.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示己方玩家选择要破坏的对方场上的卡（显示“请选择要破坏的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为②效果的对象（同时登记为当前连锁对象）。
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 向系统登记破坏操作信息：对象为选择的我方恐龙与对方卡，数量2，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- ②效果处理：取当前连锁的对象卡组，筛选仍与效果相关的卡，然后以效果原因全部破坏。
function c44612603.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理时记录的对象卡组（包括发动时选择的2张卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将仍与效果相关的对象卡全部以效果原因破坏。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
