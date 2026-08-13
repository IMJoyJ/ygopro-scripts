--魔弾の射手 ザ・キッド
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
-- ②：和这张卡相同纵列有魔法·陷阱卡发动的场合，从手卡丢弃1张「魔弹」卡才能发动。自己抽2张。
function c5230799.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5230799,1))  --"适用「魔弹射手 小子」的效果来发动"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e1:SetRange(LOCATION_MZONE)
	-- 设置该效果仅对持有「魔弹」字段的卡生效，即只有「魔弹」魔法·陷阱卡才能利用此效果从手卡发动。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108))
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetValue(32841045)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：和这张卡相同纵列有魔法·陷阱卡发动的场合，从手卡丢弃1张「魔弹」卡才能发动。自己抽2张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(5230799,0))  --"抽滤"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,5230799)
	e3:SetCondition(c5230799.drcon)
	e3:SetCost(c5230799.drcost)
	e3:SetTarget(c5230799.drtg)
	e3:SetOperation(c5230799.drop)
	c:RegisterEffect(e3)
end
-- ②效果的发动条件：当处于同一纵列的魔法·陷阱卡发动时，该效果可发动。
function c5230799.drcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():GetColumnGroup():IsContains(re:GetHandler())
end
-- 定义丢弃筛选条件：手卡中的「魔弹」卡且可以作为代价丢弃。
function c5230799.cfilter(c)
	return c:IsSetCard(0x108) and c:IsDiscardable()
end
-- ②效果的代价：确认有可丢弃的「魔弹」卡后，从手卡丢弃1张作为发动代价。
function c5230799.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己手卡中是否存在满足条件的「魔弹」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c5230799.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：从手卡丢弃1张「魔弹」卡（原因记为代价和丢弃）。
	Duel.DiscardHand(tp,c5230799.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- ②效果的发动目标设定：检查可以抽2张，并将抽卡对象和抽卡数写入连锁。
function c5230799.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查自己是否能够抽2张卡（防止受到不能抽卡效果限制时发动）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将抽卡对象玩家设为自己，表示由自己抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将抽卡数量参数设为2。
	Duel.SetTargetParam(2)
	-- 向连锁登记本次效果为抽2张卡的效果信息，以此让其他卡可以对应/检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- ②效果的处理：从连锁中取出记录的对象玩家和抽卡数，执行抽卡。
function c5230799.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁信息中保存的对象玩家（谁抽卡）和参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家以效果原因抽对应数量的卡，最终完成“自己抽2张”。
	Duel.Draw(p,d,REASON_EFFECT)
end
