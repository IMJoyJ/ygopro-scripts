--セイクリッドの星痕
-- 效果：
-- 自己场上有名字带有「星圣」的超量怪兽特殊召唤时，可以从自己卡组抽1张卡。这个效果1回合只能使用1次。
function c35631584.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对应效果原文：自己场上有名字带有「星圣」的超量怪兽特殊召唤时，可以从自己卡组抽1张卡。这个效果1回合只能使用1次。
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
-- 过滤函数：判断特殊召唤成功的怪兽是否为名字带有「星圣」的超量怪兽，且当前控制者为自己（tp）。
function c35631584.gfilter(c,tp)
	return c:IsSetCard(0x53) and c:IsType(TYPE_XYZ) and c:IsControler(tp)
end
-- 发动条件：特殊召唤成功的怪兽集合中存在至少1只自己场上名字带有「星圣」的超量怪兽。
function c35631584.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c35631584.gfilter,1,nil,tp)
end
-- 目标设定函数：效果发动时先检查自己能否抽卡，然后设定抽卡玩家为自己、抽卡数量为1，并登记抽卡操作信息。
function c35631584.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动的合法性检查：若自己不能抽1张卡，则不能发动该效果。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将本次连锁处理的对象玩家设为自己（tp），即最终抽卡的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将本次连锁处理的对象参数设为1，表示抽卡张数为1。
	Duel.SetTargetParam(1)
	-- 登记操作信息：本连锁为抽卡效果，对象玩家为自己，预计抽卡数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数：从连锁信息中读取目标玩家和参数，并让该玩家执行抽卡。
function c35631584.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和对象参数（即抽卡玩家与抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
