--ヴァンパイア・アウェイク
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只「吸血鬼」怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
function c31189536.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张；①：从卡组把1只「吸血鬼」怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31189536+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c31189536.target)
	e1:SetOperation(c31189536.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：选择持有「吸血鬼」字段且能被当前效果特殊召唤的怪兽。
function c31189536.filter(c,e,tp)
	return c:IsSetCard(0x8e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的合法判定：己方主要怪兽区有空位，且卡组中存在至少1只符合条件的「吸血鬼」怪兽。
function c31189536.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若处于发动合法性检查阶段，返回己方主要怪兽区是否有空位这一条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认卡组中存在至少1只满足筛选条件的「吸血鬼」怪兽，若两项均满足则允许发动。
		and Duel.IsExistingMatchingCard(c31189536.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次效果处理将执行从卡组特殊召唤1只怪兽的操作信息，供其他卡牌效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的「吸血鬼」怪兽特殊召唤；若特殊召唤成功，则给该怪兽设置结束阶段破坏的标记，并注册在结束阶段将其破坏的延迟效果。
function c31189536.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若己方场上没有可用的主要怪兽区域，则直接终止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选出1只符合条件的「吸血鬼」怪兽（只能选1只）。
	local g=Duel.SelectMatchingCard(tp,c31189536.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选到怪兽并特殊召唤成功（返回非0），则进入后续结束阶段破坏的标记处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(31189536,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c31189536.descon)
		e1:SetOperation(c31189536.desop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将结束阶段破坏怪兽的延迟效果注册到当前玩家，使其在结束阶段满足条件时执行。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义延迟效果的触发条件：被标记的怪兽仍在场上，且其记录的编号与本次效果保存的编号一致，避免误破坏其他同名怪兽。
function c31189536.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(31189536)==e:GetLabel()
end
-- 定义延迟效果的执行操作：破坏被特殊召唤的那只怪兽。
function c31189536.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏被特殊召唤的怪兽，将其送去墓地。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
