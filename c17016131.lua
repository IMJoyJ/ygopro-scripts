--海造賊－誇示
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的「海造贼」怪兽战斗破坏对方怪兽的场合发动。自己从卡组抽1张。
-- ②：自己场上有「海造贼」怪兽存在的场合，可以把魔法与陷阱区域的表侧表示的这张卡送去墓地，从以下效果选择1个发动。
-- ●对方从卡组抽1张。那之后，自己把对方手卡确认，选那之内的1只怪兽送去墓地。
-- ●把对方的额外卡组确认，选那之内的1张送去墓地。
function c17016131.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己的「海造贼」怪兽战斗破坏对方怪兽的场合发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17016131,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,17016131)
	e1:SetCondition(c17016131.drcon)
	e1:SetTarget(c17016131.drtg)
	e1:SetOperation(c17016131.drop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「海造贼」怪兽存在的场合，可以把魔法与陷阱区域的表侧表示的这张卡送去墓地，从以下效果选择1个发动。●对方从卡组抽1张。那之后，自己把对方手卡确认，选那之内的1只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17016131,1))  --"手卡送去墓地"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,17016132)
	e2:SetCondition(c17016131.tgcond)
	e2:SetCost(c17016131.tgcost)
	e2:SetTarget(c17016131.tgtg)
	e2:SetOperation(c17016131.tgop)
	c:RegisterEffect(e2)
	-- ②：自己场上有「海造贼」怪兽存在的场合，可以把魔法与陷阱区域的表侧表示的这张卡送去墓地，从以下效果选择1个发动。●把对方的额外卡组确认，选那之内的1张送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17016131,2))  --"额外卡组送去墓地"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,17016132)
	e3:SetCondition(c17016131.tgcond)
	e3:SetCost(c17016131.tgcost)
	e3:SetTarget(c17016131.tgtg2)
	e3:SetOperation(c17016131.tgop2)
	c:RegisterEffect(e3)
end
-- 判断是否满足①效果的发动条件：己方「海造贼」怪兽在战斗中破坏对方怪兽
function c17016131.drcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then return end
	return rc:IsRelateToBattle() and rc:IsStatus(STATUS_OPPO_BATTLE)
		and rc:IsFaceup() and rc:IsSetCard(0x13f) and rc:IsControler(tp)
end
-- 设置①效果的目标玩家和参数：自己
function c17016131.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置①效果的目标玩家为当前处理效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置①效果的目标参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置①效果的操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行①效果：自己从卡组抽1张
function c17016131.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤函数：判断是否为表侧表示的「海造贼」怪兽
function c17016131.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13f)
end
-- 判断是否满足②效果的发动条件：己方场上有「海造贼」怪兽存在
function c17016131.tgcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
		-- 检查己方场上是否存在至少1只「海造贼」怪兽
		and Duel.IsExistingMatchingCard(c17016131.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置②效果的费用：将此卡送去墓地
function c17016131.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为②效果的费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置②效果（手卡送去墓地）的目标玩家和参数
function c17016131.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以对对方抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1) end
	-- 提示对方选择了②效果（手卡送去墓地）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置②效果（手卡送去墓地）的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置②效果（手卡送去墓地）的目标参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置②效果（手卡送去墓地）的操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
	-- 设置②效果（手卡送去墓地）的操作信息为弃手卡效果
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
-- 过滤函数：判断是否为怪兽且可以送去墓地
function c17016131.tgfilter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 执行②效果（手卡送去墓地）：对方抽1张卡，然后己方确认对方手卡并选择1只怪兽送去墓地
function c17016131.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行对方抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
	-- 中断当前效果，使后续处理视为不同时处理
	Duel.BreakEffect()
	-- 获取对方手卡组
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if g:GetCount()>0 then
		-- 确认对方手卡
		Duel.ConfirmCards(1-p,g)
		local sg=g:Filter(c17016131.tgfilter1,nil)
		-- 提示选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,1-p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local tg=sg:Select(1-p,1,1,nil)
		if tg:GetCount()>0 then
			-- 将选择的卡送去墓地
			Duel.SendtoGrave(tg,REASON_EFFECT)
		end
		-- 洗切对方手卡
		Duel.ShuffleHand(p)
	end
end
-- 设置②效果（额外卡组送去墓地）的目标玩家和参数
function c17016131.tgtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方额外卡组是否存在至少1张可送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,1-tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示对方选择了②效果（额外卡组送去墓地）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置②效果（额外卡组送去墓地）的操作信息为送去墓地效果
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_EXTRA)
end
-- 执行②效果（额外卡组送去墓地）：对方确认额外卡组并选择1张卡送去墓地
function c17016131.tgop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	-- 确认对方额外卡组
	Duel.ConfirmCards(tp,g,true)
	local tg=g:Filter(Card.IsAbleToGrave,nil)
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=tg:Select(tp,1,1,nil):GetFirst()
	if tc then
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
	-- 洗切对方额外卡组
	Duel.ShuffleExtra(1-tp)
end
