--No.63 おしゃもじソルジャー
-- 效果：
-- 1星怪兽×2
-- 这个卡名的效果1回合只能使用1次。
-- ①：可以把这张卡1个超量素材取除，从以下效果选择1个发动。
-- ●下次的对方准备阶段开始时，双方玩家从卡组抽1张。
-- ●双方玩家回复1000基本分。
function c89642993.initial_effect(c)
	-- 设置XYZ召唤的手续：1星怪兽×2
	aux.AddXyzProcedure(c,nil,1,2)
	c:EnableReviveLimit()
	-- ①：可以把这张卡1个超量素材取除，从以下效果选择1个发动。●下次的对方准备阶段开始时，双方玩家从卡组抽1张。●双方玩家回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89642993,0))  --"选择效果发动"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,89642993)
	e1:SetCost(c89642993.efcost)
	e1:SetTarget(c89642993.eftg)
	e1:SetOperation(c89642993.efop)
	c:RegisterEffect(e1)
end
-- 设置该怪兽的“No.”数值为63
aux.xyz_number[89642993]=63
-- 效果发动的代价：取除这张卡的1个超量素材
function c89642993.efcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动的目标：由玩家选择其中一个效果发动，并根据选择设置对应的效果分类
function c89642993.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 让玩家选择“双方抽卡”或“双方回复LP”中的一个选项
	local op=Duel.SelectOption(tp,aux.Stringid(89642993,1),aux.Stringid(89642993,2))  --"双方玩家从卡组抽卡/双方玩家回复1000基本分"
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_DRAW)
	else
		e:SetCategory(CATEGORY_RECOVER)
	end
end
-- 效果发动的处理：若选择抽卡则注册一个在下次对方准备阶段开始时触发的效果，若选择回复则双方玩家回复1000LP
function c89642993.efop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- ●下次的对方准备阶段开始时，双方玩家从卡组抽1张。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE_START+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetCondition(c89642993.drcon)
		e1:SetOperation(c89642993.drop)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		-- 将延迟抽卡的效果注册给发动效果的玩家
		Duel.RegisterEffect(e1,tp)
	else
		-- 使发动效果的玩家回复1000基本分
		Duel.Recover(tp,1000,REASON_EFFECT)
		-- 使对方玩家回复1000基本分
		Duel.Recover(1-tp,1000,REASON_EFFECT)
	end
end
-- 延迟抽卡效果的发动条件：当前回合玩家是对方
function c89642993.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
end
-- 延迟抽卡效果的具体处理：展示卡片并让双方玩家各抽1张卡
function c89642993.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示，显示“No.63 饭勺战士”的效果发动动画
	Duel.Hint(HINT_CARD,0,89642993)
	-- 使发动效果的玩家从卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
	-- 使对方玩家从卡组抽1张卡
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
