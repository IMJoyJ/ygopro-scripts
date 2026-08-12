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
-- 条件过滤函数：检查加入手卡的卡是否为对方从卡组用非抽卡方式加入且为怪兽卡
function c3167573.cfilter(c,tp)
	return c:IsControler(1-tp) and c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
		and c:IsType(TYPE_MONSTER) and not c:IsStatus(STATUS_TO_HAND_WITHOUT_CONFIRM)
end
-- 效果①的发动条件：确认是否有满足条件的卡加入手牌
function c3167573.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c3167573.cfilter,1,nil,tp)
end
-- 效果①的发动时的处理目标设置：判断是否能特殊召唤此卡
function c3167573.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将此卡加入特殊召唤的处理列表
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理：将此卡特殊召唤到场上，并设置效果②的触发条件
function c3167573.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作：将此卡特殊召唤到场上
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e2=e:GetLabelObject()
		-- 判断当前回合是否为召唤者回合
		if Duel.GetTurnPlayer()==tp then
			c:RegisterFlagEffect(3167573,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,2)
			-- 设置效果②的触发回合数：若为召唤者回合，则在两回合后触发
			e2:SetLabel(Duel.GetTurnCount()+2)
		else
			c:RegisterFlagEffect(3167573,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
			-- 设置效果②的触发回合数：若不为召唤者回合，则在下一回合后触发
			e2:SetLabel(Duel.GetTurnCount()+1)
		end
	end
end
-- 效果②的发动条件：判断是否已注册flag且当前回合数等于设定的触发回合数
function c3167573.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否已注册flag且当前回合数等于设定的触发回合数
	return e:GetHandler():GetFlagEffect(3167573)>0 and Duel.GetTurnCount()==e:GetLabel()
end
-- 效果②的发动处理：将此卡破坏
function c3167573.desop(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(0)
	-- 执行破坏操作：将此卡以效果原因破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
