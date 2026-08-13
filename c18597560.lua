--サイバネティック・レボリューション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只「电子龙」解放才能发动。以「电子龙」怪兽为融合素材的1只融合怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽不能直接攻击，下个回合的结束阶段破坏。
function c18597560.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只「电子龙」解放才能发动。以「电子龙」怪兽为融合素材的1只融合怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽不能直接攻击，下个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,18597560+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c18597560.cost)
	e1:SetTarget(c18597560.target)
	e1:SetOperation(c18597560.activate)
	c:RegisterEffect(e1)
end
-- 定义代价筛选函数：判断候选解放怪兽是否为「电子龙」（70095154），且额外卡组中存在至少1只满足后续特殊召唤条件的融合怪兽。
function c18597560.cfilter(c,e,tp)
	-- 判断该怪兽卡名是「电子龙」（卡号70095154），同时额外卡组存在满足c18597560.filter条件的融合怪兽可作为特殊召唤对象。
	return c:IsCode(70095154) and Duel.IsExistingMatchingCard(c18597560.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 定义发动代价：将自己场上1只「电子龙」解放；用标签记录已支付代价，以保证在效果发动时合法。
function c18597560.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 在代价合法性检查阶段，确认自己场上存在至少1只「电子龙」且额外卡组存在符合条件的融合怪兽可供解放并特殊召唤。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c18597560.cfilter,1,nil,e,tp) end
	-- 从自己场上选择1只满足条件的「电子龙」作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c18597560.cfilter,1,1,nil,e,tp)
	-- 将选择的「电子龙」解放，作为发动效果的代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 定义特殊召唤对象筛选条件：必须是融合怪兽、以「电子龙」为融合素材、可被此次效果特殊召唤，且额外怪兽区域有空位。
function c18597560.filter(c,e,tp,rc)
	-- 筛选对象必须是融合怪兽，并且其融合素材包含「电子龙」字段（setcode 0x1093）。
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListSetCard(c,0x1093)
		-- 该融合怪兽能够被此效果特殊召唤（不检查召唤条件/苏生限制），且解放「电子龙」后额外怪兽区域有空位可供特殊召唤。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,rc,c)>0
end
-- 定义发动目标判定：若代价已支付（通过标签判断）或额外卡组存在符合条件的融合怪兽则可发动；发动时将操作信息设置为从额外卡组特殊召唤1只怪兽。
function c18597560.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==100
		e:SetLabel(0)
		-- 确认代价已支付（标签为100），或者额外卡组中存在至少1只满足特殊召唤条件的融合怪兽，二者有一即可发动。
		return res or Duel.IsExistingMatchingCard(c18597560.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)
	end
	e:SetLabel(0)
	-- 设置本次连锁的操作信息：处理内容为特殊召唤，从额外卡组特殊召唤1只怪兽（具体对象在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从额外卡组选择1只符合条件的融合怪兽特殊召唤，并对其附加“不能直接攻击”和“下个回合结束阶段破坏”的效果。
function c18597560.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向操作者显示选择要特殊召唤的怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足c18597560.filter的融合怪兽，并取得这张卡。
	local tc=Duel.SelectMatchingCard(tp,c18597560.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	-- 若成功选择了怪兽且能特殊召唤，则将其以表侧攻击表示特殊召唤（作为连锁处理的一步）。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		tc:RegisterFlagEffect(18597560,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
		-- 这个效果特殊召唤的怪兽不能直接攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 下个回合的结束阶段破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCondition(c18597560.descon)
		e2:SetOperation(c18597560.desop)
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		e2:SetCountLimit(1)
		-- 记录当前回合数，作为破坏效果在下个回合结束阶段触发的判断基准。
		e2:SetLabel(Duel.GetTurnCount())
		e2:SetLabelObject(tc)
		-- 将结束阶段破坏的效果注册到场上，使它在“下个回合的结束阶段”触发。
		Duel.RegisterEffect(e2,tp)
	end
	-- 完成SpecialSummonStep开始的一系列特殊召唤处理，确认特殊召唤成功。
	Duel.SpecialSummonComplete()
end
-- 定义破坏效果的触发条件：已进入下个回合（当前回合数与记录的不同），且该怪兽仍带有本效果标记（未被重置/离场）。
function c18597560.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 判断当前回合数已变化（已到下一个回合），且特殊召唤的怪兽身上仍存在本卡标记，满足破坏条件。
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(18597560)~=0
end
-- 定义破坏效果的操作：将特殊召唤的那只怪兽破坏。
function c18597560.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因（REASON_EFFECT）将该怪兽破坏。
	Duel.Destroy(tc,REASON_EFFECT)
end
