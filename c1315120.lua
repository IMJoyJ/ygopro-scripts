--TG ストライカー
-- 效果：
-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。从卡组把「科技属 突击兵」以外的1只「科技属」怪兽加入手卡。
function c1315120.initial_effect(c)
	-- 效果原文内容：①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1315120.spcon)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。从卡组把「科技属 突击兵」以外的1只「科技属」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c1315120.regop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断特殊召唤条件是否满足
function c1315120.spcon(e,c)
	if c==nil then return true end
	-- 规则层面作用：检查自己场上是否有怪兽
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 规则层面作用：检查对方场上是否有怪兽
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 规则层面作用：检查自己场上是否有足够的召唤区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 规则层面作用：设置破坏时的触发效果
function c1315120.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) then
		-- 规则层面作用：创建结束阶段发动的效果，用于检索满足条件的「科技属」怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(1315120,0))  --"检索"
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c1315120.thtg)
		e1:SetOperation(c1315120.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 规则层面作用：定义检索怪兽的过滤条件
function c1315120.filter(c)
	return c:IsSetCard(0x27) and not c:IsCode(1315120) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 规则层面作用：设置检索效果的发动条件
function c1315120.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c1315120.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面作用：设置操作信息，表示将要从卡组检索一张怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面作用：执行检索效果的操作
function c1315120.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：提示玩家选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 规则层面作用：选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c1315120.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面作用：向对方确认加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
