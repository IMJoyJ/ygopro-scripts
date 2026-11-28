--ピースの輪
-- 效果：
-- ①：对方场上有怪兽3只以上存在，自己场上没有卡存在的场合，自己抽卡阶段通过把通常抽卡的这张卡持续公开，那个回合的主要阶段1才能发动。自己从卡组选1张卡，给双方确认加入手卡。
function c2295831.initial_effect(c)
	-- ①：对方场上有怪兽3只以上存在，自己场上没有卡存在的场合，自己抽卡阶段通过把通常抽卡的这张卡持续公开
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c2295831.regcon)
	e1:SetOperation(c2295831.regop)
	c:RegisterEffect(e1)
	-- 那个回合的主要阶段1才能发动。自己从卡组选1张卡，给双方确认加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c2295831.condition)
	e2:SetCost(c2295831.cost)
	e2:SetTarget(c2295831.target)
	e2:SetOperation(c2295831.activate)
	c:RegisterEffect(e2)
end
-- 公开条件检查：确认自己场上无卡、对方场上有3只以上怪兽，且处于抽卡阶段并因规则通常抽到这张卡
function c2295831.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上没有卡且对方怪兽区有3只以上怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=3
		-- 检查当前处于抽卡阶段且本次抽卡为规则通常抽卡
		and Duel.GetCurrentPhase()==PHASE_DRAW and c:IsReason(REASON_RULE)
end
-- 公开处理：询问玩家是否持续公开这张卡，选择是则赋予持续公开效果并打上发动资格标记
function c2295831.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 询问玩家是否持续公开抽到的「拼图之圈」
	if Duel.SelectYesNo(tp,aux.Stringid(2295831,0)) then  --"是否要持续公开「拼图之圈」？"
		-- 通过把通常抽卡的这张卡持续公开
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(2295831,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1,EFFECT_FLAG_CLIENT_HINT,1,0,66)
	end
end
-- 发动条件检查：确认当前处于主要阶段1
function c2295831.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 发动前置检查：确认这张卡带有在抽卡阶段持续公开的标识效果
function c2295831.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(2295831)~=0 end
end
-- 效果目标设定：检查卡组是否存在可加入手卡的卡并登记检索操作信息
function c2295831.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张可加入手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
	-- 声明本次效果会从自己卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张卡加入手卡并向对方确认
function c2295831.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要从卡组加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1张可加入手卡的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果原因将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
