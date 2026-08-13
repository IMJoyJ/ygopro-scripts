--フォーチュンレディ・ウォーテリー
-- 效果：
-- ①：这张卡的攻击力·守备力变成这张卡的等级×300。
-- ②：自己准备阶段发动。这张卡的等级上升1星（最多到12星）。
-- ③：自己场上有「命运女郎·沃特莉」以外的「命运女郎」怪兽存在，这张卡特殊召唤成功的场合发动。自己从卡组抽2张。
function c29088922.initial_effect(c)
	-- ①：这张卡的攻击力变成这张卡的等级×300。（即'这张卡的攻击力·守备力变成这张卡的等级×300'中的攻击力部分）
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
	-- ②：自己准备阶段发动。这张卡的等级上升1星（最多到12星）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29088922,0))  --"等级上升"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c29088922.lvcon)
	e3:SetOperation(c29088922.lvop)
	c:RegisterEffect(e3)
	-- ③：自己场上有「命运女郎·沃特莉」以外的「命运女郎」怪兽存在，这张卡特殊召唤成功的场合发动。自己从卡组抽2张。
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
-- 计算这张卡当前等级乘以300的数值，作为①效果中攻击力（或守备力）的设定值。
function c29088922.value(e,c)
	return c:GetLevel()*300
end
-- ②效果的发动条件：当前回合玩家为自己（tp），即自己的准备阶段。
function c29088922.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己。
	return Duel.GetTurnPlayer()==tp
end
-- ②效果处理：若此卡仍表侧表示、与效果保持关联且等级不高于12，则给它注册一个等级+1的持续效果；否则不处理。
function c29088922.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsLevelAbove(12) then return end
	-- ②：这张卡的等级上升1星（最多到12星）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- ③效果的判定过滤器：筛选表侧表示、属于「命运女郎」（0x31）系列且不是自身（卡号29088922）的怪兽，用于确认自己场上是否存在其他命运女郎。
function c29088922.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x31) and not c:IsCode(29088922)
end
-- ③效果的发动条件与目标设定：检查是否存在其他命运女郎，若存在则将抽取玩家设为自己、抽取数量设为2，并设置操作信息。
function c29088922.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己场上是否存在至少1只满足cfilter条件（其他表侧命运女郎）的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c29088922.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 将当前连锁的对象玩家设为自己（tp），使后续抽卡作用于自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为2，表示本次要抽2张卡。
	Duel.SetTargetParam(2)
	-- 设置操作信息：本次连锁的效果分类为抽卡（CATEGORY_DRAW），对象玩家为tp，预计抽卡数为2（不取对象，故目标卡组为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- ③效果处理：从连锁信息中取得对象玩家和抽卡数，令该玩家抽相应数量的卡（因效果抽卡）。
function c29088922.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中保存的对象玩家和对象参数，分别作为抽卡玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 令玩家p以效果原因（REASON_EFFECT）抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
