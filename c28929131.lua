--時械神ザフィオン
-- 效果：
-- 这张卡不能从卡组特殊召唤。
-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡不会被战斗·效果破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ③：这张卡进行战斗的战斗阶段结束时发动。对方场上的魔法·陷阱卡全部回到卡组。
-- ④：这张卡从场上送去墓地的场合才能发动。自己从卡组抽1张。
-- ⑤：自己准备阶段发动。这张卡回到持有者卡组。
function c28929131.initial_effect(c)
	-- 这张卡不能从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28929131,0))  --"不用解放作召唤"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c28929131.ntcon)
	c:RegisterEffect(e2)
	-- ②：这张卡不会被战斗·效果破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	c:RegisterEffect(e5)
	-- ③：这张卡进行战斗的战斗阶段结束时发动。对方场上的魔法·陷阱卡全部回到卡组。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(28929131,1))
	e6:SetCategory(CATEGORY_TODECK)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetCountLimit(1)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(c28929131.tdcon)
	e6:SetTarget(c28929131.tdtg)
	e6:SetOperation(c28929131.tdop)
	c:RegisterEffect(e6)
	-- ④：这张卡从场上送去墓地的场合才能发动。自己从卡组抽1张。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(28929131,2))
	e7:SetCategory(CATEGORY_DRAW)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCode(EVENT_TO_GRAVE)
	e7:SetCountLimit(1)
	e7:SetCondition(c28929131.drcon)
	e7:SetTarget(c28929131.drtg)
	e7:SetOperation(c28929131.drop)
	c:RegisterEffect(e7)
	-- ⑤：自己准备阶段发动。这张卡回到持有者卡组。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(28929131,3))
	e8:SetCategory(CATEGORY_TODECK)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e8:SetCountLimit(1)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCondition(c28929131.rtdcon)
	e8:SetTarget(c28929131.rtdtg)
	e8:SetOperation(c28929131.rtdop)
	c:RegisterEffect(e8)
end
-- 无解放召唤的条件判断：c为nil时表示规则询问返回true；否则要求本卡等级5以上、自己场上无怪兽且主怪兽区有空位，满足时可不解放作召唤。
function c28929131.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5)
		-- 检查这张卡的控制者场上没有怪兽，满足“自己场上没有怪兽”条件。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查这张卡的控制者主怪兽区有空位，确保可以通常召唤。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- ③的发动条件：这张卡进行过战斗（战斗过的怪兽组数量大于0）时，战斗阶段结束时发动。
function c28929131.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- ③的过滤函数：选择对方场上可以返回卡组的魔法·陷阱卡。
function c28929131.tdfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- ③的发动目标设置：无检查时返回true；获取对方场上所有符合条件的魔陷，并设置操作信息为回卡组。
function c28929131.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有满足条件的魔法·陷阱卡（不取对象）。
	local g=Duel.GetMatchingGroup(c28929131.tdfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：本次效果将把这些卡送回卡组，数量为获取到的卡数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ③的效果处理：重新获取对方场上符合条件的魔法·陷阱卡，若有则以效果原因全部送回持有者卡组并洗切。
function c28929131.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时获取对方场上所有满足条件的魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c28929131.tdfilter,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 以效果原因将g中的卡全部送回持有者卡组并洗切。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ④的发动条件：这张卡从场上区域被送去墓地。
function c28929131.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ④的发动目标设置：确认自己可以抽1张卡；设定对象玩家为自己、参数为1，并设置抽卡操作信息。
function c28929131.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己是否能抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设为自己（抽卡玩家）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息：本效果为抽卡效果，由自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ④的效果处理：从连锁信息中获取对象玩家和抽卡数，执行抽卡。
function c28929131.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家和对象参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 由对象玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- ⑤的发动条件：当前回合玩家为这张卡的控制者（即自己准备阶段）。
function c28929131.rtdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于tp（自己），确定处于自己的准备阶段。
	return Duel.GetTurnPlayer()==tp
end
-- ⑤的发动目标设置：无条件可用；设置操作信息将这张卡送回持有者卡组。
function c28929131.rtdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将这张卡返回持有者卡组，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- ⑤的效果处理：若这张卡仍与效果关联，则将其送回持有者卡组并洗切。
function c28929131.rtdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以效果原因将这张卡送回持有者卡组并洗切。
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
