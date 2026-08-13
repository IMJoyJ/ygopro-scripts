--コズミック・クェーサー・ドラゴン
-- 效果：
-- 同调怪兽调整＋调整以外的同调怪兽2只以上
-- 这张卡用以上记的卡为同调素材的同调召唤才能从额外卡组特殊召唤。
-- ①：1回合1次，以最多有作为这张卡的同调素材的怪兽数量＋1张的场上的表侧表示卡为对象才能发动（这个效果的发动和效果不会被无效化）。那些卡的效果无效。
-- ②：自己·对方回合，把同调召唤的这张卡除外才能发动。以调整以外的同调怪兽2只以上为素材的1只龙族同调怪兽当作同调召唤从额外卡组特殊召唤。
local s,id,o=GetID()
-- 定义宇宙类星龙在游戏中的初始效果：注册同调召唤手续、苏生限制、①的无效效果、素材计数、②的特殊召唤效果。
function s.initial_effect(c)
	-- 设置同调召唤手续：以1只同调怪兽调整为调整＋调整以外的同调怪兽2只以上为素材。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),2)
	c:EnableReviveLimit()
	-- 这张卡用以上记的卡为同调素材的同调召唤才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(s.synlimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以最多有作为这张卡的同调素材的怪兽数量＋1张的场上的表侧表示卡为对象才能发动（这个效果的发动和效果不会被无效化）。那些卡的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"场上的卡效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- 作为这张卡的同调素材的怪兽数量＋1张
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	c:RegisterEffect(e3)
	-- ②：自己·对方回合，把同调召唤的这张卡除外才能发动。以调整以外的同调怪兽2只以上为素材的1只龙族同调怪兽当作同调召唤从额外卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetDescription(aux.Stringid(id,1))  --"这张卡除外并同调召唤"
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.material_type=TYPE_SYNCHRO
-- 特殊召唤限制条件：只允许以指定素材进行同调召唤而特殊召唤，且不能通过其他卡的效果特殊召唤。
function s.synlimit(e,se,sp,st)
	return st&SUMMON_TYPE_SYNCHRO==SUMMON_TYPE_SYNCHRO and not se
end
-- ①效果的发动时处理：选择场上1到（素材数+1）张表侧表示卡作为对象，这些卡需能被无效化。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local ct=1
	if c:GetFlagEffectLabel(id) then ct=c:GetFlagEffectLabel(id) end
	-- 验证对象卡是否合法：必须位于场上且属于可被无效化的表侧表示卡。
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 发动时确认场上是否存在至少1张可被无效化的表侧表示卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家从符合条件的表侧表示卡中选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家选择1到ct张符合条件的表侧表示卡，并将它们登记为效果对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 登记操作信息：本次效果将无效这些对象卡，数量为ct。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,ct,0,0)
end
-- ①效果处理时：对每个对象卡，使其卡片效果无效、效果适用无效，并无效与其相关的连锁；若对象为陷阱怪兽则额外将其无效化。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与本连锁相关的对象卡组（仍与效果保持联系的对象），用于后续逐个无效。
	local dg=Duel.GetTargetsRelateToChain()
	local tc=dg:GetFirst()
	while tc do
		-- 使与该对象卡相关的连锁无效化，并持续到回合结束。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那些卡的效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那些卡的效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那些卡的效果无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		tc=dg:GetNext()
	end
end
-- 记录同调召唤成功时的素材数量+1，作为①效果选择对象的数量上限。
function s.valcheck(e,c)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1,c:GetMaterialCount()+1)
end
-- ②发动条件检查：这张卡必须是以同调召唤方式出场，且可以除外作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		-- 检查这张卡是否满足作为除外cost的条件（可被除外）。若满足则cost检查通过。
		and aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) end
	-- 实际支付cost：将这张卡除外。
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 筛选可作为②特殊召唤对象的额外卡组怪兽：需为龙族同调怪兽、满足‘以调整以外的同调怪兽2只以上为素材’的同调召唤条件、能够特殊召唤且场上有可用额外区。
function s.spfilter(c,e,tp,ec)
	return c.cosmic_quasar_dragon_summon and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 确认以该龙族同调怪兽为对象时，额外卡组怪兽可以特殊召唤到的区域是否有空位。
		and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0
end
-- ②发动目标判定：确认没有‘必须作为同调素材’的限制影响，且额外卡组存在符合条件的龙族同调怪兽可以特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在使某卡必须作为同调素材的效果；若有，则②不能发动。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组中是否存在至少1只符合spfilter条件的龙族同调怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 登记操作信息：本次效果将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：从额外卡组选择1只符合条件的龙族同调怪兽，视为同调召唤特殊召唤，并执行后续的召唤完成处理。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查是否受‘必须作为同调素材’效果影响，若存在则本次特殊召唤不处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 提示玩家从额外卡组选择要特殊召唤的龙族同调怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择1张满足条件的龙族同调怪兽；若没有则选择失败。
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 以同调召唤方式将选择的怪兽特殊召唤到场上；成功时调用CompleteProcedure完成同调召唤手续。
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
