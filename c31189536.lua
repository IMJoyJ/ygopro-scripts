--ヴァンパイア・アウェイク
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只「吸血鬼」怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
function c31189536.initial_effect(c)
	-- ①：从卡组把1只「吸血鬼」怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31189536+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c31189536.target)
	e1:SetOperation(c31189536.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断卡是否为「吸血鬼」种族且可以被特殊召唤
function c31189536.filter(c,e,tp)
	return c:IsSetCard(0x8e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动条件判断，检查玩家场上是否有空位且卡组中是否存在满足条件的「吸血鬼」怪兽
function c31189536.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「吸血鬼」怪兽
		and Duel.IsExistingMatchingCard(c31189536.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果发动时的操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，执行特殊召唤操作并注册结束阶段破坏效果
function c31189536.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有空位，若无则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「吸血鬼」怪兽
	local g=Duel.SelectMatchingCard(tp,c31189536.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤操作，若成功则注册结束阶段破坏效果
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(31189536,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 创建一个在结束阶段触发的效果，用于破坏特殊召唤的怪兽
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
		-- 将创建的破坏效果注册到场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否为当前特殊召唤的怪兽，用于确定是否触发破坏效果
function c31189536.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(31189536)==e:GetLabel()
end
-- 执行破坏操作，将目标怪兽破坏
function c31189536.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽因效果而破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
