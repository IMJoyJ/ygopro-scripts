--コズミック・クェーサー・ドラゴン
-- 效果：
-- 同调怪兽调整＋调整以外的同调怪兽2只以上
-- 这张卡用以上记的卡为同调素材的同调召唤才能从额外卡组特殊召唤。
-- ①：1回合1次，以最多有作为这张卡的同调素材的怪兽数量＋1张的场上的表侧表示卡为对象才能发动（这个效果的发动和效果不会被无效化）。那些卡的效果无效。
-- ②：自己·对方回合，把同调召唤的这张卡除外才能发动。以调整以外的同调怪兽2只以上为素材的1只龙族同调怪兽当作同调召唤从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤程序并启用复活限制
function s.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和至少2只调整以外的同调怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),2)
	c:EnableReviveLimit()
	-- 这张卡只能通过指定的同调素材同调召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(s.synlimit)
	c:RegisterEffect(e1)
	-- 1回合1次，以最多有作为这张卡的同调素材的怪兽数量＋1张的场上的表侧表示卡为对象才能发动（这个效果的发动和效果不会被无效化）。那些卡的效果无效。
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
	-- 检查同调素材数量并记录
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	c:RegisterEffect(e3)
	-- 自己·对方回合，把同调召唤的这张卡除外才能发动。以调整以外的同调怪兽2只以上为素材的1只龙族同调怪兽当作同调召唤从额外卡组特殊召唤。
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
-- 限制该卡只能通过同调召唤从额外卡组特殊召唤
function s.synlimit(e,se,sp,st)
	return st&SUMMON_TYPE_SYNCHRO==SUMMON_TYPE_SYNCHRO and not se
end
-- 设置效果目标，选择最多有作为这张卡的同调素材的怪兽数量＋1张的场上的表侧表示卡
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local ct=1
	if c:GetFlagEffectLabel(id) then ct=c:GetFlagEffectLabel(id) end
	-- 判断是否为效果目标
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 判断是否存在满足条件的目标
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择满足条件的目标卡
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置效果操作信息，将无效化的卡数量记录
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,ct,0,0)
end
-- 处理效果，使目标卡的效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与连锁相关的卡
	local dg=Duel.GetTargetsRelateToChain()
	local tc=dg:GetFirst()
	while tc do
		-- 使目标卡的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标卡的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标卡的效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 使陷阱怪兽的效果无效
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
-- 记录同调素材数量
function s.valcheck(e,c)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1,c:GetMaterialCount()+1)
end
-- 设置效果发动费用，检查是否为同调召唤且满足除外条件
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		-- 检查是否满足除外条件
		and aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) end
	-- 执行除外操作
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 设置特殊召唤过滤器，检查是否为龙族同调怪兽且可特殊召唤
function s.spfilter(c,e,tp,ec)
	return c.cosmic_quasar_dragon_summon and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查是否有足够的召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0
end
-- 设置特殊召唤目标，检查是否存在满足条件的卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足同调素材条件
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查是否存在满足条件的特殊召唤卡
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置操作信息，记录特殊召唤目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理特殊召唤效果，选择并特殊召唤满足条件的卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足同调素材条件
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的特殊召唤卡
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 执行特殊召唤操作
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
