--クイック・リボルブ
-- 效果：
-- ①：从卡组把1只「弹丸」怪兽特殊召唤。这个效果特殊召唤的怪兽不能攻击，结束阶段破坏。
function c31443476.initial_effect(c)
	-- ①：从卡组把1只「弹丸」怪兽特殊召唤。这个效果特殊召唤的怪兽不能攻击，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c31443476.target)
	e1:SetOperation(c31443476.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判定卡组中的怪兽是否为「弹丸」字段，且能否被当前效果特殊召唤。
function c31443476.filter(c,e,tp)
	return c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标判定：确认己方主要怪兽区有空位，且卡组中存在符合条件的「弹丸」怪兽。
function c31443476.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检查己方主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在至少1只满足「弹丸」字段和特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(c31443476.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次效果的操作信息为从卡组特殊召唤1只怪兽，供系统和其他卡的效果联动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若己方主要怪兽区无空位则直接结束；提示选择卡组中的「弹丸」怪兽，特殊召唤成功时附加不能攻击和结束阶段破坏的制约。
function c31443476.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若己方主要怪兽区没有空位，则终止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家弹出“请选择要特殊召唤的卡”的卡片选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让己方玩家从卡组选择1只满足「弹丸」字段且可被特殊召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,c31443476.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 选中卡片后，将其以表侧攻击表示作为特殊召唤流程的一步进行特殊召唤；成功后继续给该怪兽附加限制与破坏效果。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽不能攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		tc:RegisterFlagEffect(31443476,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 结束阶段破坏。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetLabelObject(tc)
		e2:SetCondition(c31443476.descon)
		e2:SetOperation(c31443476.desop)
		e2:SetCountLimit(1)
		-- 将结束阶段破坏的诱发效果注册给当前玩家tp，使效果在结束阶段时判定并执行破坏。
		Duel.RegisterEffect(e2,tp)
	end
	-- 结束特殊召唤的流程，完成所有SpecialSummonStep步骤。
	Duel.SpecialSummonComplete()
end
-- 破坏效果的发动条件：若被特殊召唤的怪兽仍持有标记（未离场/未重置），则允许在结束阶段发动破坏；否则重置该效果并不发动。
function c31443476.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(31443476)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 破坏效果的执行：破坏由LabelObject记录的怪兽。
function c31443476.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏被记录的那只被特殊召唤的怪兽。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
