--真実の眼
-- 效果：
-- 只要这张卡在场上存在，对方把手卡持续公开。对方的准备阶段时对方手卡有魔法卡的场合，对方回复1000基本分。
function c34694160.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，对方把手卡持续公开。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PUBLIC)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_HAND)
	c:RegisterEffect(e2)
	-- 对方的准备阶段时对方手卡有魔法卡的场合，对方回复1000基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34694160,0))  --"回复"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c34694160.reccon)
	e3:SetTarget(c34694160.rectg)
	e3:SetOperation(c34694160.recop)
	c:RegisterEffect(e3)
end
-- 回复效果的发动条件：仅在对方回合的准备阶段，且对方手牌中存在至少1张魔法卡时才满足。
function c34694160.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家不是本卡控制者（即为对方回合），并且对方手牌中存在魔法卡。
	return Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_HAND,1,nil,TYPE_SPELL)
end
-- 回复效果发动时的目标设定：将回复对象指定为对方玩家，回复数值设为1000，并登记对应的回复操作信息。
function c34694160.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的对象玩家设为对方玩家（1-tp），表示回复的是对方的基本分。
	Duel.SetTargetPlayer(1-tp)
	-- 将本次连锁的对象参数设为1000，表示回复的数值为1000。
	Duel.SetTargetParam(1000)
	-- 登记效果处理信息：该效果属于回复（CATEGORY_RECOVER），目标玩家为对方，回复数值为1000。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,1000)
end
-- 回复效果的实际处理：从连锁信息中取出目标玩家和回复数值，并让该玩家回复相应基本分。
function c34694160.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和对象参数，分别作为回复对象和回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）让玩家p回复d点基本分，完成回复处理。
	Duel.Recover(p,d,REASON_EFFECT)
end
