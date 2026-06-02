--ウィッチクラフト・ドレーピング
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以最多有自己场上的「魔女术」怪兽数量的对方场上的魔法·陷阱卡为对象才能发动。那些卡回到持有者手卡。
-- ②：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡加入手卡。
function c56894757.initial_effect(c)
	-- ①：以最多有自己场上的「魔女术」怪兽数量的对方场上的魔法·陷阱卡为对象才能发动。那些卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,56894757)
	e1:SetTarget(c56894757.target)
	e1:SetOperation(c56894757.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡加入手卡。
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
-- 过滤函数：是否为魔法或陷阱卡
function c56894757.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤函数：是否为自己场上表侧表示的「魔女术」怪兽
function c56894757.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 效果①的发动准备与合法性检测（包括对象合法性检测和发动条件检测）
function c56894757.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc,exc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() and c56894757.filter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(c56894757.cfilter,tp,LOCATION_MZONE,0,1,exc)
		-- 检测对方魔陷区是否存在至少1张可以回到手牌的卡
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_SZONE,1,nil) end
	-- 获取自己场上表侧表示的「魔女术」怪兽数量，作为可选对象的最大数量
	local ct=Duel.GetMatchingGroupCount(c56894757.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 给玩家发送提示信息：请选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择最多有自己场上「魔女术」怪兽数量的对方场上的魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_SZONE,1,ct,nil)
	-- 设置效果处理信息：将选中的卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果①的效果处理（使选中的对象卡片回到持有者手牌）
function c56894757.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果相关的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将这些卡片因效果送回持有者手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 过滤函数：是否为自己场上表侧表示的「魔女术」怪兽（用于效果②）
function c56894757.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 效果②的发动条件检测（自己回合的结束阶段，且自己场上有「魔女术」怪兽存在）
function c56894757.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
		-- 检测自己场上是否存在表侧表示的「魔女术」怪兽
		and Duel.IsExistingMatchingCard(c56894757.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的发动准备与合法性检测（检测自身是否能加入手牌，并设置操作信息）
function c56894757.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息：将墓地的这张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理（将这张卡从墓地加入手牌）
function c56894757.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡因效果加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
