--パペット・キング
-- 效果：
-- ①：对方用抽卡以外的方法从卡组把怪兽加入手卡时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的①的效果特殊召唤成功的场合，下次的自己回合的结束阶段发动。这张卡破坏。
function c3167573.initial_effect(c)
	-- ①：对方用抽卡以外的方法从卡组把怪兽加入手卡时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3167573,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(c3167573.spcon)
	e1:SetTarget(c3167573.sptg)
	e1:SetOperation(c3167573.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果特殊召唤成功的场合，下次的自己回合的结束阶段发动。这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c3167573.descon)
	e2:SetOperation(c3167573.desop)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
-- 筛选函数：判断加入手卡的卡是否为对方控制的怪兽、原所在位置为卡组、加入手卡的原因不是抽卡、不是以未确认状态加入手卡。
function c3167573.cfilter(c,tp)
	return c:IsControler(1-tp) and c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
		and c:IsType(TYPE_MONSTER) and not c:IsStatus(STATUS_TO_HAND_WITHOUT_CONFIRM)
end
-- 发动条件：存在至少1张满足筛选条件的卡片，即对方用抽卡以外的方法从卡组把怪兽加入手卡。
function c3167573.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c3167573.cfilter,1,nil,tp)
end
-- 发动目标判定：己方主要怪兽区有可用空格，且这张卡自身可以被特殊召唤。
function c3167573.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区的可用空格数量是否大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明本次效果将进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡从手卡特殊召唤，若特殊召唤成功，则根据当前回合归属设置自毁效果的触发时机。
function c3167573.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 以表侧表示特殊召唤这张卡，并判断是否特殊召唤成功。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e2=e:GetLabelObject()
		-- 判断当前回合玩家是否是自己，以决定自毁效果应推迟到哪个自己回合的结束阶段。
		if Duel.GetTurnPlayer()==tp then
			c:RegisterFlagEffect(3167573,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,2)
			-- 在自己回合特殊召唤成功时，将自毁效果设定为当前回合数+2的结束阶段触发。
			e2:SetLabel(Duel.GetTurnCount()+2)
		else
			c:RegisterFlagEffect(3167573,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
			-- 在对方回合特殊召唤成功时，将自毁效果设定为当前回合数+1的结束阶段触发。
			e2:SetLabel(Duel.GetTurnCount()+1)
		end
	end
end
-- 自毁效果的发动条件：这张卡拥有自毁标记，且当前回合数等于预设的触发回合数。
function c3167573.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认存在自毁标记且当前回合数已达到预设的结束阶段回合数。
	return e:GetHandler():GetFlagEffect(3167573)>0 and Duel.GetTurnCount()==e:GetLabel()
end
-- 自毁效果处理：清除预设标记，并破坏这张卡。
function c3167573.desop(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(0)
	-- 将这张卡以效果原因破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
