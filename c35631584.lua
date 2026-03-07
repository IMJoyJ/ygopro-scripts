--セイクリッドの星痕
-- 效果：
-- 自己场上有名字带有「星圣」的超量怪兽特殊召唤时，可以从自己卡组抽1张卡。这个效果1回合只能使用1次。
function c35631584.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 诱发选发效果，当自己场上有名字带有「星圣」的超量怪兽特殊召唤成功时发动，效果为抽1张卡，每回合只能发动1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35631584,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c35631584.con)
	e2:SetTarget(c35631584.tg)
	e2:SetOperation(c35631584.op)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的怪兽：名字带有「星圣」、类型为超量、控制者为指定玩家。
function c35631584.gfilter(c,tp)
	return c:IsSetCard(0x53) and c:IsType(TYPE_XYZ) and c:IsControler(tp)
end
-- 判断触发条件：确认特殊召唤成功的怪兽中是否存在满足gfilter条件的怪兽。
function c35631584.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c35631584.gfilter,1,nil,tp)
end
-- 设置效果目标：检查玩家是否可以抽卡，若可以则设置目标玩家为发动者，目标参数为1，操作信息为抽卡效果。
function c35631584.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查效果是否可以发动：确认目标玩家是否可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为当前处理的玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1（表示抽1张卡）。
	Duel.SetTargetParam(1)
	-- 设置当前处理的连锁的操作信息为抽卡效果，目标玩家为当前玩家，抽卡数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数：从连锁信息中获取目标玩家和抽卡数量，并执行抽卡效果。
function c35631584.op(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家以效果原因抽指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
