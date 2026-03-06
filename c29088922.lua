--フォーチュンレディ・ウォーテリー
-- 效果：
-- ①：这张卡的攻击力·守备力变成这张卡的等级×300。
-- ②：自己准备阶段发动。这张卡的等级上升1星（最多到12星）。
-- ③：自己场上有「命运女郎·沃特莉」以外的「命运女郎」怪兽存在，这张卡特殊召唤成功的场合发动。自己从卡组抽2张。
function c29088922.initial_effect(c)
	-- 效果原文：①：这张卡的攻击力·守备力变成这张卡的等级×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(c29088922.value)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
	-- 效果原文：②：自己准备阶段发动。这张卡的等级上升1星（最多到12星）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29088922,0))  --"等级上升"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c29088922.lvcon)
	e3:SetOperation(c29088922.lvop)
	c:RegisterEffect(e3)
	-- 效果原文：③：自己场上有「命运女郎·沃特莉」以外的「命运女郎」怪兽存在，这张卡特殊召唤成功的场合发动。自己从卡组抽2张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(29088922,1))  --"抽卡"
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(c29088922.drtg)
	e4:SetOperation(c29088922.drop)
	c:RegisterEffect(e4)
end
-- 规则层面：设置攻击力为等级乘以300
function c29088922.value(e,c)
	return c:GetLevel()*300
end
-- 规则层面：判断是否为自己的准备阶段
function c29088922.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：当前回合玩家等于效果发动玩家
	return Duel.GetTurnPlayer()==tp
end
-- 规则层面：使自身等级上升1星（最多到12星）
function c29088922.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsLevelAbove(12) then return end
	-- 规则层面：设置自身等级增加1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 规则层面：过滤场上的「命运女郎」怪兽（除沃特莉外）
function c29088922.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x31) and not c:IsCode(29088922)
end
-- 规则层面：设置抽卡效果的目标玩家和抽卡数量
function c29088922.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查场上是否存在符合条件的「命运女郎」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c29088922.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 规则层面：设置连锁效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 规则层面：设置连锁效果的目标参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 规则层面：设置操作信息为抽卡效果，抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 规则层面：执行抽卡效果
function c29088922.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取连锁效果的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面：让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
