--A・ジェネクス・ベルフレイム
-- 效果：
-- ①：每次从自己场上有怪兽被送去墓地，给这张卡放置1个次世代指示物。
-- ②：每次从对方墓地有卡被除外，给这张卡放置2个次世代指示物。
-- ③：这张卡的攻击力上升场上的次世代指示物数量×100。
-- ④：这张卡被战斗破坏送去墓地的场合发动。给与对方这张卡放置的次世代指示物数量×300伤害。
function c91438994.initial_effect(c)
	c:EnableCounterPermit(0xa)
	-- ①：每次从自己场上有怪兽被送去墓地，给这张卡放置1个次世代指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c91438994.addc1)
	c:RegisterEffect(e1)
	-- ②：每次从对方墓地有卡被除外，给这张卡放置2个次世代指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c91438994.addc2)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击力上升场上的次世代指示物数量×100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c91438994.attackup)
	c:RegisterEffect(e3)
	-- ④：这张卡被战斗破坏送去墓地的场合发动。给与对方这张卡放置的次世代指示物数量×300伤害。（用于记录离场时的指示物数量）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetOperation(c91438994.damp)
	c:RegisterEffect(e4)
	-- ④：这张卡被战斗破坏送去墓地的场合发动。给与对方这张卡放置的次世代指示物数量×300伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(91438994,0))  --"伤害"
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EVENT_BATTLE_DESTROYED)
	e5:SetCondition(c91438994.damcon)
	e5:SetTarget(c91438994.damtg)
	e5:SetOperation(c91438994.damop)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
-- 过滤条件：判断卡片是否由自己控制且原本存在于怪兽区域
function c91438994.filter1(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 在有自己场上的怪兽被送去墓地时，给这张卡放置1个次世代指示物
function c91438994.addc1(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c91438994.filter1,1,nil,tp) then
		e:GetHandler():AddCounter(0xa,1)
	end
end
-- 过滤条件：判断卡片是否由对方控制且原本存在于墓地
function c91438994.filter2(c,tp)
	return c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_GRAVE)
end
-- 在有对方墓地的卡被除外时，给这张卡放置2个次世代指示物
function c91438994.addc2(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c91438994.filter2,1,nil,tp) then
		e:GetHandler():AddCounter(0xa,2)
	end
end
-- 计算并返回这张卡因自身指示物数量而上升的攻击力数值
function c91438994.attackup(e,c)
	return c:GetCounter(0xa)*100
end
-- 在卡片即将离场时，将当前的次世代指示物数量记录在效果的Label中
function c91438994.damp(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetCounter(0xa))
end
-- 判断这张卡是否在墓地且因战斗破坏而送去墓地
function c91438994.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 获取记录的指示物数量，若不为0则设置伤害的目标玩家、伤害数值并注册操作信息
function c91438994.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabelObject():GetLabel()
	if chk==0 then return ct~=0 end
	-- 将当前连锁的目标玩家设置为对方
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的伤害数值参数设置为指示物数量×300
	Duel.SetTargetParam(ct*300)
	-- 向系统注册伤害操作信息，指定对象为对方玩家以及对应的伤害数值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
-- 效果处理：获取连锁信息中的目标玩家和伤害数值，并执行伤害处理
function c91438994.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
