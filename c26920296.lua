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
	-- 融合：1回合1次，自己的手卡·场上的怪兽被效果送去墓地的场合才能发动。自己从卡组抽1张。
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
	-- 同调：怪兽的召唤·特殊召唤成功时才能由自己把这个效果发动。那些怪兽的等级上升1星。
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
	-- 超量：自己结束阶段发动。场上的等级最高的怪兽破坏。
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
-- 检查卡片是否表侧表示且为指定类型（融合/同调/超量）
function c26920296.cfilter(c,type)
	return c:IsFaceup() and c:IsType(type)
end
-- 检测被效果送去墓地的自己的怪兽（手卡或场上）
function c26920296.drcfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_HAND+LOCATION_MZONE) and c:IsType(TYPE_MONSTER) and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
end
-- 若自己的怪兽因效果被送墓，则满足抽卡效果发动条件
function c26920296.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c26920296.drcfilter,1,nil,tp)
end
-- 抽卡效果的发动条件检查：玩家可抽卡且场上有融合怪兽
function c26920296.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查场上是否有表侧表示的融合怪兽
		and Duel.IsExistingMatchingCard(c26920296.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,TYPE_FUSION) end
	-- 设置抽卡对象玩家为玩家自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为1
	Duel.SetTargetParam(1)
	-- 设置抽卡操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 提示对方玩家选择了抽卡效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 抽卡效果的具体处理：从连锁信息中获取目标玩家和抽卡数量，执行抽卡
function c26920296.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 筛选表侧表示且等级大于0的怪兽
function c26920296.lvfilter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 检查是否有怪兽成功召唤/特召且场上有同调怪兽，满足升星效果发动条件
function c26920296.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c26920296.lvfilter,1,nil)
		-- 检查场上是否有表侧表示的同调怪兽
		and Duel.IsExistingMatchingCard(c26920296.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,TYPE_SYNCHRO) end
	-- 设置升星对象为成功召唤/特召的怪兽
	Duel.SetTargetCard(eg)
	-- 提示对方玩家选择了升星效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 对成功召唤/特召的每只怪兽施加等级上升1星的效果
function c26920296.lvop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c26920296.lvfilter,nil):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 那些怪兽的等级上升1星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 结束阶段时，若当前回合玩家为自己，则满足破坏效果发动条件
function c26920296.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 破坏效果的发动条件检查：场上有超量怪兽；选取等级最高的怪兽并设置破坏操作信息
function c26920296.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有表侧表示的超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c26920296.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,TYPE_XYZ) end
	-- 提示对方玩家选择了破坏效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 获取场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	local mg,lv=g:GetMaxGroup(Card.GetLevel)
	if lv==0 then return end
	-- 设置破坏操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,mg,mg:GetCount(),0,0)
end
-- 破坏效果的处理：选出场上等级最高的怪兽并破坏
function c26920296.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧表示的怪兽（用于破坏处理）
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	local mg,lv=g:GetMaxGroup(Card.GetLevel)
	if lv==0 then return end
	if mg:GetCount()>0 then
		-- 执行破坏处理
		Duel.Destroy(mg,REASON_EFFECT)
	end
end
