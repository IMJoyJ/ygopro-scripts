--時械神ガブリオン
-- 效果：
-- 这张卡不能从卡组特殊召唤。
-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡不会被战斗·效果破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ③：这张卡进行战斗的战斗阶段结束时发动。对方场上的卡全部回到持有者卡组。那之后，对方抽出回到自身卡组的数量。
-- ④：自己准备阶段发动。这张卡回到持有者卡组。
function c6616912.initial_effect(c)
	-- 这张卡不能从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6616912,0))  --"不用解放作召唤"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c6616912.ntcon)
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
	-- ③：这张卡进行战斗的战斗阶段结束时发动。对方场上的卡全部回到持有者卡组。那之后，对方抽出回到自身卡组的数量。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(6616912,1))
	e6:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetCountLimit(1)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(c6616912.tdcon)
	e6:SetTarget(c6616912.tdtg)
	e6:SetOperation(c6616912.tdop)
	c:RegisterEffect(e6)
	-- ④：自己准备阶段发动。这张卡回到持有者卡组。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(6616912,1))
	e7:SetCategory(CATEGORY_TODECK)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e7:SetCountLimit(1)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(c6616912.rtdcon)
	e7:SetTarget(c6616912.rtdtg)
	e7:SetOperation(c6616912.rtdop)
	c:RegisterEffect(e7)
end
-- 不用解放作召唤的判定条件
function c6616912.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5)
		-- 检查自己场上的怪兽数量是否为0
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查自己场上是否有可用的怪兽区域空格
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判定这张卡在本次战斗阶段中是否进行过战斗
function c6616912.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 对方场上的卡全部回到持有者卡组并抽卡效果的目标判定与操作信息注册
function c6616912.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有可以回到卡组的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁处理中的操作信息：将对方场上的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置连锁处理中的操作信息：对方玩家抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,g:GetCount())
end
-- 过滤函数：用于筛选回到对方卡组（主卡组）的卡片
function c6616912.cfilter(c,p)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(p)
end
-- 对方场上的卡全部回到持有者卡组并抽卡效果的具体处理
function c6616912.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以回到卡组的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	-- 如果对方场上有卡且成功将这些卡送回持有者卡组
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		local ct=g:FilterCount(c6616912.cfilter,nil,1-tp)
		if ct>0 then
			-- 洗切对方卡组
			Duel.ShuffleDeck(1-tp)
			-- 中断当前效果处理，使后续的抽卡处理不与送回卡组同时进行
			Duel.BreakEffect()
			-- 对方玩家根据回到自身卡组的卡片数量进行抽卡
			Duel.Draw(1-tp,ct,REASON_EFFECT)
		end
	end
end
-- 自身回到卡组效果的发动条件判定
function c6616912.rtdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 自身回到卡组效果的目标判定与操作信息注册
function c6616912.rtdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理中的操作信息：将自身（这张卡）送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 自身回到卡组效果的具体处理
function c6616912.rtdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡送回持有者卡组并洗牌
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
