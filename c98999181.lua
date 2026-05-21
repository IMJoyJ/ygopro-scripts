--ネフティスの祈り手
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。选1张手卡破坏，从卡组把「奈芙提斯之祈祷者」以外的1只「奈芙提斯」怪兽加入手卡。
-- ②：这张卡被效果破坏送去墓地的场合，下次的自己准备阶段才能发动。从卡组把1张「奈芙提斯」魔法·陷阱卡加入手卡。
function c98999181.initial_effect(c)
	-- ①：自己主要阶段才能发动。选1张手卡破坏，从卡组把「奈芙提斯之祈祷者」以外的1只「奈芙提斯」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98999181,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,98999181)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c98999181.thtg)
	e1:SetOperation(c98999181.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果破坏送去墓地的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c98999181.spr)
	c:RegisterEffect(e2)
	-- 下次的自己准备阶段才能发动。从卡组把1张「奈芙提斯」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(98999181,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,98999182)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c98999181.thcon2)
	e3:SetTarget(c98999181.thtg2)
	e3:SetOperation(c98999181.thop2)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 过滤卡组中「奈芙提斯之祈祷者」以外的「奈芙提斯」怪兽
function c98999181.filter(c,e,tp)
	return c:IsSetCard(0x11f) and c:IsType(TYPE_MONSTER) and not c:IsCode(98999181) and c:IsAbleToHand()
end
-- 效果①的发动准备与合法性检测
function c98999181.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「奈芙提斯」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c98999181.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 且手牌中存在可破坏的卡
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,nil) end
	-- 设置破坏手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
	-- 设置从卡组检索卡片加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：破坏1张手牌，并从卡组检索1只「奈芙提斯」怪兽
function c98999181.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择手牌中的1张卡
	local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	if dg:GetCount()==0 then return end
	-- 如果成功破坏选中的手牌
	if Duel.Destroy(dg,REASON_EFFECT)~=0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只符合过滤条件的「奈芙提斯」怪兽
		local g=Duel.SelectMatchingCard(tp,c98999181.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 记录这张卡被效果破坏送去墓地时的状态和回合数
function c98999181.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 then return end
	-- 如果是在自己的准备阶段被破坏
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 将当前回合数记录在效果的Label中，用于防止在当前回合的准备阶段直接发动
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(98999181,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(98999181,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- 过滤卡组中的「奈芙提斯」魔法·陷阱卡
function c98999181.thfilter(c,e,tp)
	return c:IsSetCard(0x11f) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的发动条件判断
function c98999181.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前回合不是被破坏的回合、当前是自己的回合，且卡片带有被破坏的标记
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and c:GetFlagEffect(98999181)>0
end
-- 效果②的发动准备与合法性检测
function c98999181.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查卡组中是否存在可检索的「奈芙提斯」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c98999181.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从卡组检索卡片加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	c:ResetFlagEffect(98999181)
end
-- 效果②的处理：从卡组检索1张「奈芙提斯」魔法·陷阱卡
function c98999181.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「奈芙提斯」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c98999181.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法·陷阱卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
