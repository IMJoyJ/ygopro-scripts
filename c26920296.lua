--幻夢境
-- 效果：
-- 「幻梦境」在1回合只能发动1张。
-- ①：得到场上的怪兽种类的以下效果。
-- ●融合：1回合1次，自己的手卡·场上的怪兽被效果送去墓地的场合才能发动。自己从卡组抽1张。
-- ●同调：怪兽的召唤·特殊召唤成功时才能由自己把这个效果发动。那些怪兽的等级上升1星。
-- ●超量：自己结束阶段发动。场上的等级最高的怪兽破坏。
function c26920296.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,26920296+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	-- ●融合：1回合1次，自己的手卡·场上的怪兽被效果送去墓地的场合才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26920296,0))  --"自己从卡组抽1张卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c26920296.drcon)
	e2:SetTarget(c26920296.drtg)
	e2:SetOperation(c26920296.drop)
	c:RegisterEffect(e2)
	-- ●同调：怪兽的召唤·特殊召唤成功时才能由自己把这个效果发动。那些怪兽的等级上升1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(26920296,1))  --"召唤·特殊召唤成功的怪兽的等级上升1星"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(c26920296.lvtg)
	e3:SetOperation(c26920296.lvop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ●超量：自己结束阶段发动。场上的等级最高的怪兽破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(26920296,2))  --"场上的等级最高的怪兽破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetCountLimit(1)
	e5:SetCondition(c26920296.descon)
	e5:SetTarget(c26920296.destg)
	e5:SetOperation(c26920296.desop)
	c:RegisterEffect(e5)
end
-- 过滤函数：判定怪兽是否表侧表示且拥有指定的怪兽类型（融合/同调/超量），用于检查场上是否存在对应种类的怪兽。
function c26920296.cfilter(c,type)
	return c:IsFaceup() and c:IsType(type)
end
-- 过滤函数：判定一张卡是否满足融合抽卡效果中“自己的手牌·场上的怪兽被效果送去墓地”：曾位于手牌或场上、是怪兽、因效果离场、且原控制者为自己。
function c26920296.drcfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_HAND+LOCATION_MZONE) and c:IsType(TYPE_MONSTER) and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
end
-- 融合抽卡效果发动条件：这次被送去墓地的怪兽中至少存在一只满足drcfilter的卡，即自己的手牌·场上的怪兽被效果送去墓地。
function c26920296.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c26920296.drcfilter,1,nil,tp)
end
-- 抽卡效果的发动合法性检查：自己可以抽1张卡，且场上有表侧表示的融合怪兽，使融合种类效果得以适用。
function c26920296.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 并且场上（双方怪兽区域）存在表侧表示的融合怪兽，作为取得融合效果的判定条件。
		and Duel.IsExistingMatchingCard(c26920296.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,TYPE_FUSION) end
	-- 将当前连锁的对象玩家设为自己，指定抽卡玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1，指定抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息：告知系统本效果为抽卡（CATEGORY_DRAW），抽卡玩家为自己，预计抽1张；因不取对象，targets设为nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 向对方玩家发送HINT_OPSELECTED提示，显示自己发动了当前效果的效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 融合抽卡效果的处理函数：从连锁信息中取得对象玩家和抽卡张数，并执行抽卡。
function c26920296.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得对象玩家p和对象参数d（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p抽d张卡，完成“自己从卡组抽1张”。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤函数：判定怪兽是否表侧表示且等级大于0，用于同调效果中可上升等级的怪兽。
function c26920296.lvfilter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 同调效果发动合法性检查：本次召唤/特殊召唤成功的怪兽中有表侧表示且等级大于0的怪兽，且场上有表侧表示的同调怪兽，使同调种类效果得以适用。
function c26920296.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c26920296.lvfilter,1,nil)
		-- 并且场上（双方怪兽区域）存在表侧表示的同调怪兽，作为取得同调效果的判定条件。
		and Duel.IsExistingMatchingCard(c26920296.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,TYPE_SYNCHRO) end
	-- 将本次召唤/特殊召唤成功的怪兽组（eg）记录为当前连锁的关联对象，使处理时只对仍与效果关联的怪兽生效。
	Duel.SetTargetCard(eg)
	-- 向对方玩家发送HINT_OPSELECTED提示，显示自己发动了当前效果的效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 同调效果处理：从eg中筛选出满足lvfilter且仍与效果关联的怪兽，逐只赋予等级上升1星的效果（离场后重置）。
function c26920296.lvop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c26920296.lvfilter,nil):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 那些怪兽的等级上升1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 超量破坏效果的发动条件：只有自己的结束阶段才发动。
function c26920296.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己。
	return Duel.GetTurnPlayer()==tp
end
-- 超量破坏效果的发动合法性与操作信息设置：自己场上有表侧表示的超量怪兽才能发动；发动时获取场上所有表侧表示怪兽，找出等级最高的一组，并将其预定破坏写入操作信息。
function c26920296.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：场上存在表侧表示的超量怪兽，作为取得超量效果的判定条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c26920296.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,TYPE_XYZ) end
	-- 向对方玩家发送HINT_OPSELECTED提示，显示自己发动了当前效果的效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 获取场上所有表侧表示怪兽的集合，用于确定等级最高的怪兽组。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	local mg,lv=g:GetMaxGroup(Card.GetLevel)
	if lv==0 then return end
	-- 设置操作信息：预定破坏等级最高的怪兽组（mg），破坏数量为mg的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,mg,mg:GetCount(),0,0)
end
-- 超量破坏效果处理：效果处理时重新获取场上所有表侧表示怪兽，找出等级最高的一组，若存在则将其破坏。
function c26920296.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧表示怪兽的集合，用于在效果处理时确定等级最高的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	local mg,lv=g:GetMaxGroup(Card.GetLevel)
	if lv==0 then return end
	if mg:GetCount()>0 then
		-- 以效果原因破坏等级最高的怪兽组mg。
		Duel.Destroy(mg,REASON_EFFECT)
	end
end
