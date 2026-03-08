--強烈なはたき落とし
-- 效果：
-- ①：对方从卡组把卡加入手卡时才能发动。对方把加入手卡的那1张卡丢弃。
function c4440873.initial_effect(c)
	-- 效果原文内容：①：对方从卡组把卡加入手卡时才能发动。对方把加入手卡的那1张卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_HANDES)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(c4440873.condition)
	e1:SetTarget(c4440873.target)
	e1:SetOperation(c4440873.activate)
	c:RegisterEffect(e1)
end
-- 规则层面操作：筛选满足条件的卡，检查其控制者是否为指定玩家且之前位置为卡组
function c4440873.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- 规则层面操作：检查连锁中是否存在至少1张满足cfilter条件的卡，用于判断是否满足发动条件
function c4440873.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c4440873.cfilter,1,nil,1-tp)
end
-- 规则层面操作：设置当前效果的目标卡组为eg，并设置操作信息为对方丢弃手牌
function c4440873.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：将当前连锁的目标设置为eg，即对方加入手牌的卡
	Duel.SetTargetCard(eg)
	-- 规则层面操作：设置操作信息为对方丢弃手牌，数量为1
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
-- 规则层面操作：筛选满足条件的卡，检查其是否与当前效果相关且控制者为指定玩家且之前位置为卡组
function c4440873.filter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- 规则层面操作：根据满足条件的卡数量决定处理方式，若为0则不处理，若为1则直接送去墓地，否则提示选择丢弃一张
function c4440873.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=eg:Filter(c4440873.filter,nil,e,1-tp)
	if sg:GetCount()==0 then
	elseif sg:GetCount()==1 then
		-- 规则层面操作：将满足条件的卡组送去墓地，原因包括效果和丢弃
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
	else
		-- 规则层面操作：向对方提示选择丢弃手牌的提示信息
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		local dg=sg:Select(1-tp,1,1,nil)
		-- 规则层面操作：将选择的卡送去墓地，原因包括效果和丢弃
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end
