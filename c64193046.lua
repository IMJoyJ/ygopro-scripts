--超重天神マスラ－O
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名在规则上也当作「超重武者」卡使用。
-- ①：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
-- ②：自己场上的「超重武者」怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1张「超重武者」卡破坏。
-- ③：1回合1次，对方把魔法·陷阱卡的效果发动的场合才能发动。自己直到手卡变成3张为止从卡组抽卡。
function c64193046.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DEFENSE_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：自己场上的「超重武者」怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1张「超重武者」卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c64193046.reptg)
	e2:SetValue(c64193046.repval)
	e2:SetOperation(c64193046.repop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，对方把魔法·陷阱卡的效果发动的场合才能发动。自己直到手卡变成3张为止从卡组抽卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64193046,0))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c64193046.drcon)
	e3:SetTarget(c64193046.drtg)
	e3:SetOperation(c64193046.drop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上因战斗或效果破坏的「超重武者」怪兽
function c64193046.filter1(c,tp)
	return not c:IsReason(REASON_REPLACE) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and c:IsFaceup() and c:IsSetCard(0x9a) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
-- 过滤自己场上可以用于代替破坏的、未确定被破坏的「超重武者」卡
function c64193046.filter2(c,e)
	return c:IsSetCard(0x9a) and c:IsFaceup() and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 代替破坏效果的靶向与条件检查，询问玩家是否使用代替破坏效果，并选择代替破坏的卡
function c64193046.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(c64193046.filter1,nil,tp)
	-- 获取自己场上所有可用于代替破坏的「超重武者」卡
	local tg=Duel.GetMatchingGroup(c64193046.filter2,tp,LOCATION_ONFIELD,0,nil,e)
	if chk==0 then return #g>0 and #tg>0 end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 设置提示信息为选择要代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		local xg=tg:Select(tp,1,1,nil)
		-- 将选中的代替破坏卡设为效果处理的对象
		Duel.SetTargetCard(xg)
		xg:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 确定被破坏的卡是否符合代替破坏的条件（即自己场上的「超重武者」怪兽）
function c64193046.repval(e,c)
	return c64193046.filter1(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的具体执行，将选中的代替卡破坏
function c64193046.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动了此卡的效果
	Duel.Hint(HINT_CARD,0,64193046)
	-- 获取之前选定的代替破坏的对象卡
	local tc=Duel.GetFirstTarget()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 破坏选定的代替卡，作为代替破坏的处理
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
-- 抽卡效果的发动条件：对方发动了魔法·陷阱卡的效果
function c64193046.drcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 抽卡效果的靶向与条件检查，计算需要抽卡的数量并注册抽卡操作信息
function c64193046.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己当前的手卡数量
	local h=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 检查可行性：手卡少于3张，且玩家可以抽卡
	if chk==0 then return h<3 and Duel.IsPlayerCanDraw(tp,3-h) end
	-- 设置效果处理的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的参数为需要抽卡的数量（3减去当前手卡数）
	Duel.SetTargetParam(3-h)
	-- 设置连锁操作信息为：自己抽卡，数量为需要抽卡的数量
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3-h)
end
-- 抽卡效果的具体执行，让玩家抽卡直到手卡变成3张
function c64193046.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取目标玩家当前的手卡数量
	local h=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
	if h>=3 then return end
	-- 目标玩家因效果抽卡，数量为3减去当前手卡数
	Duel.Draw(p,3-h,REASON_EFFECT)
end
