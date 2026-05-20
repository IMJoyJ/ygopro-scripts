--簡素融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：支付1000基本分才能发动。除效果怪兽外的1只6星以下的融合怪兽当作融合召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽不能攻击，结束阶段破坏。
function c63854005.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：支付1000基本分才能发动。除效果怪兽外的1只6星以下的融合怪兽当作融合召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽不能攻击，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,63854005+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c63854005.cost)
	e1:SetTarget(c63854005.target)
	e1:SetOperation(c63854005.activate)
	c:RegisterEffect(e1)
end
-- 检查并支付1000基本分的发动成本（Cost）
function c63854005.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除玩家1000基本分作为发动成本
	Duel.PayLPCost(tp,1000)
end
-- 过滤额外卡组中满足条件的怪兽：除效果怪兽外的6星以下的融合怪兽，且能进行融合召唤
function c63854005.filter(c,e,tp)
	return c:IsType(TYPE_FUSION) and not c:IsType(TYPE_EFFECT) and c:IsLevelBelow(6) and c:CheckFusionMaterial()
		-- 检查该怪兽是否能以融合召唤的方式特殊召唤，且额外卡组怪兽出场所需的怪兽区域有空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动的靶向处理（检查是否有合法的特殊召唤对象，并声明特殊召唤的操作信息）
function c63854005.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查是否存在必须作为融合素材的卡片限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检查额外卡组是否存在至少1只满足条件的融合怪兽
		and Duel.IsExistingMatchingCard(c63854005.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的核心逻辑（特殊召唤怪兽并施加不能攻击和结束阶段破坏的限制）
function c63854005.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次检查必须作为融合素材的卡片限制
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c63854005.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	-- 将选择的怪兽当作融合召唤以表侧表示特殊召唤，若特殊召唤成功则执行后续处理
	if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽不能攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		tc:RegisterFlagEffect(63854005,RESET_EVENT+RESETS_STANDARD,0,1)
		tc:CompleteProcedure()
		-- 结束阶段破坏。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetLabelObject(tc)
		e2:SetCondition(c63854005.descon)
		e2:SetOperation(c63854005.desop)
		-- 注册在结束阶段触发的全局效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 结束阶段破坏效果的触发条件（检查被特殊召唤的怪兽是否仍带有标记，若无则重置该效果）
function c63854005.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(63854005)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 结束阶段破坏效果的具体操作
function c63854005.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 因效果将目标怪兽破坏
	Duel.Destroy(tc,REASON_EFFECT)
end
