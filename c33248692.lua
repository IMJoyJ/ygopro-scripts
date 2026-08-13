--オプションハンター
-- 效果：
-- 自己场上的怪兽被战斗破坏送去墓地时发动。自己回复破坏怪兽的原本攻击力的数值的基本分。
function c33248692.initial_effect(c)
	-- 自己场上的怪兽被战斗破坏送去墓地时发动。自己回复破坏怪兽的原本攻击力的数值的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c33248692.condition)
	e1:SetTarget(c33248692.target)
	e1:SetOperation(c33248692.operation)
	c:RegisterEffect(e1)
end
-- 筛选被战斗破坏后送去墓地的怪兽：其上一个控制者为发动者，当前位于墓地，且破坏原因为战斗破坏。
function c33248692.filter(c,tp)
	return c:IsPreviousControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
end
-- 发动条件判定：诱发事件组eg中存在至少1只满足上述筛选条件的怪兽，即自己场上有怪兽被战斗破坏送去墓地。
function c33248692.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c33248692.filter,1,nil,tp)
end
-- 发动时处理目标与回复数值：无脑满足发动条件；从eg中取出第一只符合条件的怪兽，将其原本攻击力作为回复数值；若原本攻击力为负则视为0；设定回复玩家为发动者、回复参数为该数值，并登记回复效果的操作信息。
function c33248692.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rec=eg:Filter(c33248692.filter,nil,tp):GetFirst():GetBaseAttack()
	if rec<0 then rec=0 end
	-- 将当前连锁效果的对象玩家设定为发动者tp。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁效果的对象参数设定为回复数值rec。
	Duel.SetTargetParam(rec)
	-- 登记当前连锁的处理信息：此效果为回复LP效果，目标玩家为tp，预计回复数值为rec，无需指定对象卡。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 效果处理：从连锁信息中取得之前设定的回复玩家和回复数值，然后执行回复LP操作。
function c33248692.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家p和对象参数d，即之前设定的回复玩家与回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p回复d点基本分，完成效果结算。
	Duel.Recover(p,d,REASON_EFFECT)
end
