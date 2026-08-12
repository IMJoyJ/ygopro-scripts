--光神テテュス
-- 效果：
-- ①：自己抽卡时，那卡是天使族怪兽的场合，把那张卡给对方观看才能发动。这张卡在场上表侧表示存在的场合，自己从卡组抽1张。
function c87148330.initial_effect(c)
	-- ①：自己抽卡时，那卡是天使族怪兽的场合，把那张卡给对方观看才能发动。这张卡在场上表侧表示存在的场合，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87148330,0))  --"抽卡"
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DRAW)
	e1:SetCost(c87148330.drcost)
	e1:SetTarget(c87148330.drtg)
	e1:SetOperation(c87148330.drop)
	c:RegisterEffect(e1)
end
-- 过滤出未公开的天使族怪兽
function c87148330.filter(c)
	return c:IsRace(RACE_FAIRY) and not c:IsPublic()
end
-- 发动代价：确认自己抽到的卡中是否存在天使族怪兽，并将其给对方观看
function c87148330.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return ep==tp and eg:IsExists(c87148330.filter,1,nil) end
	local g=eg:Filter(c87148330.filter,nil)
	if g:GetCount()==1 then
		-- 向对方玩家确认抽到的那张天使族怪兽
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自身手卡
		Duel.ShuffleHand(tp)
	else
		-- 提示玩家选择要给对方确认的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 向对方玩家确认选中的天使族怪兽
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切自身手卡
		Duel.ShuffleHand(tp)
	end
end
-- 效果的目标处理：验证是否可以抽卡，并设置抽卡相关的连锁信息
function c87148330.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自身是否具有抽1张卡的效果可行性
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将效果的对象玩家设定为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 将效果的对象参数（抽卡数量）设定为1
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果的实际处理：若此卡在场上表侧表示存在，则让目标玩家抽取对应数量的卡
function c87148330.drop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsFacedown() or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 获取当前连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
