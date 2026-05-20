--生還の宝札
-- 效果：
-- 自己墓地存在的怪兽特殊召唤成功时，可以从自己卡组抽1张卡。
function c57953380.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己墓地存在的怪兽特殊召唤成功时，可以从自己卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57953380,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c57953380.con)
	e2:SetTarget(c57953380.tg)
	e2:SetOperation(c57953380.op)
	c:RegisterEffect(e2)
end
-- 过滤出原本在自己墓地且原本控制者为自己的怪兽
function c57953380.gfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
-- 检查特殊召唤成功的怪兽中是否存在原本在自己墓地的怪兽
function c57953380.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c57953380.gfilter,1,nil,tp)
end
-- 效果发动的目标处理，检查是否能抽卡并设置抽卡的目标玩家、数量和操作信息
function c57953380.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己是否可以从卡组抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理的执行函数，获取目标玩家和参数并执行抽卡
function c57953380.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
