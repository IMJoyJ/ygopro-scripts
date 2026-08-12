--ウィッチクラフト・ドレーピング
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以最多有自己场上的「魔女术」怪兽数量的对方场上的魔法·陷阱卡为对象才能发动。那些卡回到持有者手卡。
-- ②：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡加入手卡。
function c56894757.initial_effect(c)
	-- ①：以最多有自己场上的「魔女术」怪兽数量的对方场上的魔法·陷阱卡为对象才能发动。那些卡回到持有者手卡。这个卡名的①②的效果1回合只能有1次使用其中任意1个。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,56894757)
	e1:SetTarget(c56894757.target)
	e1:SetOperation(c56894757.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡加入手卡。这个卡名的①②的效果1回合只能有1次使用其中任意1个。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56894757,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1,56894757)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c56894757.thcon)
	e2:SetTarget(c56894757.thtg)
	e2:SetOperation(c56894757.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：魔法卡或陷阱卡
function c56894757.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤条件：自己场上表侧表示的「魔女术」怪兽
function c56894757.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 效果①的发动准备：检测是否符合发动条件，计算自己场上「魔女术」怪兽数量以确定可选取的最大对象数量，选择相应数量的对方场上的魔法·陷阱卡作为效果的对象，并设置回手牌的操作信息
function c56894757.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc,exc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() and c56894757.filter(chkc) end
	-- 发动检查的第一部分：检查自己场上是否存在至少1只表侧表示的「魔女术」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c56894757.cfilter,tp,LOCATION_MZONE,0,1,exc)
		-- 发动检查的第二部分：检查对方魔陷区是否存在至少1张可以回到手牌的卡
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_SZONE,1,nil) end
	-- 获取自己场上表侧表示的「魔女术」怪兽数量，作为可选择对象卡片数量的最大上限值
	local ct=Duel.GetMatchingGroupCount(c56894757.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 向玩家发送选择提示信息：“请选择要返回手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择最多有自己场上「魔女术」怪兽数量的对方场上的魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_SZONE,1,ct,nil)
	-- 设置当前效果处理的操作信息为将选中的卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果①的效果处理：获取所有与当前效果相关的对象卡片，并将它们送回持有者手牌
function c56894757.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象卡中仍与当前效果相关的卡片集合
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将过滤后的对象卡片送回持有者的手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 过滤条件：自己场上表侧表示的「魔女术」怪兽
function c56894757.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 效果②的发动条件：当前回合是自己回合的结束阶段，且自己场上存在表侧表示的「魔女术」怪兽
function c56894757.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为玩家自身
	return Duel.GetTurnPlayer()==tp
		-- 检查自己场上是否存在至少1只表侧表示的「魔女术」怪兽
		and Duel.IsExistingMatchingCard(c56894757.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的发动准备：检查这张卡自身是否可以加入手牌，并设置回收自身的操作信息
function c56894757.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置当前效果处理的操作信息为将自身加入手牌，数量为1
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：如果这张卡仍与效果相关，则将其从墓地加入玩家手牌
function c56894757.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡自身加入到玩家的手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
