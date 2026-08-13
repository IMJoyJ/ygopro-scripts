--チェイス・スカッド
-- 效果：
-- 场上守备表示存在的怪兽被战斗破坏送去墓地时，给与对方基本分500分伤害。
function c27870033.initial_effect(c)
	-- 场上守备表示存在的怪兽被战斗破坏送去墓地时，给与对方基本分500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27870033,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c27870033.damcon)
	e1:SetTarget(c27870033.damtg)
	e1:SetOperation(c27870033.damop)
	c:RegisterEffect(e1)
end
-- 筛选满足条件的怪兽：判定送入墓地的怪兽此前为守备表示、现位于墓地、因战斗破坏被送去且为怪兽卡，用于确认触发事件中是否存在符合“场上守备表示存在的怪兽被战斗破坏送去墓地”的怪兽。
function c27870033.cfilter(c)
	return c:IsPreviousPosition(POS_DEFENSE) and c:IsLocation(LOCATION_GRAVE)
		and c:IsReason(REASON_BATTLE) and c:IsType(TYPE_MONSTER)
end
-- 效果发动条件：若触发事件eg中存在至少1只满足cfilter条件的怪兽，则条件成立，效果可以发动。
function c27870033.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c27870033.cfilter,1,nil)
end
-- 效果发动时的目标处理：若chk==0则返回true表示可发动（不设置）；在chk==1时设置对方玩家为受伤害对象、伤害值为500，并登记操作信息为对对方造成500点伤害。
function c27870033.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家（1-tp），即伤害承受者为对手。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为500，表示将要造成的伤害数值。
	Duel.SetTargetParam(500)
	-- 登记操作信息：本次效果类别为伤害（CATEGORY_DAMAGE），无对象卡，目标玩家为对方玩家，伤害值为500，用于连锁判定和相关卡片的响应。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理操作：从连锁信息中读取目标玩家和参数，并对其造成对应的效果伤害，实现给与对方基本分500分伤害。
function c27870033.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中同时取得对象玩家（CHAININFO_TARGET_PLAYER）和对象参数（CHAININFO_TARGET_PARAM），分别存入p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害（REASON_EFFECT）为原因，向玩家p造成d点伤害，即给对方500点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
