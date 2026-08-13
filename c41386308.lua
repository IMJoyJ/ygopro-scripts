--マスマティシャン
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把1只4星以下的怪兽送去墓地。
-- ②：这张卡被战斗破坏送去墓地时才能发动。自己从卡组抽1张。
function c41386308.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从卡组把1只4星以下的怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41386308,0))  --"送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c41386308.target)
	e1:SetOperation(c41386308.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏送去墓地时才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41386308,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c41386308.drcon)
	e2:SetTarget(c41386308.drtg)
	e2:SetOperation(c41386308.drop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为4星以下且可以被送去墓地，用于①效果选择卡组送墓对象。
function c41386308.tgfilter(c)
	return c:IsLevelBelow(4) and c:IsAbleToGrave()
end
-- ①效果的发动条件与效果信息设定：召唤成功时若卡组存在符合条件的怪兽则可发动，并设定将1张卡送去墓地的处理信息。
function c41386308.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认卡组中是否存在至少1只4星以下且可送去墓地的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c41386308.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：将1张卡从卡组送去墓地（不取对象，处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1只4星以下且可送去墓地的怪兽，将其送去墓地。
function c41386308.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己的卡组选择1张满足条件的4星以下怪兽（必须且只能选择1张）。
	local g=Duel.SelectMatchingCard(tp,c41386308.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡因战斗破坏被送去墓地（位于墓地且破坏原因为战斗）。
function c41386308.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
end
-- ②效果的发动检查与操作信息：若能抽1张卡则可发动，并将抽卡玩家设为自己、数量设为1，登记抽卡操作。
function c41386308.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己是否可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将连锁的目标玩家设定为当前玩家（执行抽卡的玩家）。
	Duel.SetTargetPlayer(tp)
	-- 将连锁的目标参数设定为1（抽卡数量）。
	Duel.SetTargetParam(1)
	-- 设置效果处理信息：当前玩家从卡组抽1张卡，用于效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：从连锁信息取得抽卡玩家和数量，执行抽卡。
function c41386308.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的目标玩家（p）和抽卡数量（d）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
