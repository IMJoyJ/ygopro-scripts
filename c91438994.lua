--A・ジェネクス・ベルフレイム
-- 效果：
-- ①：每次从自己场上有怪兽被送去墓地，给这张卡放置1个次世代指示物。
-- ②：每次从对方墓地有卡被除外，给这张卡放置2个次世代指示物。
-- ③：这张卡的攻击力上升场上的次世代指示物数量×100。
-- ④：这张卡被战斗破坏送去墓地的场合发动。给与对方这张卡放置的次世代指示物数量×300伤害。
function c91438994.initial_effect(c)
	c:EnableCounterPermit(0xa)
	-- ①：每次从自己场上有怪兽送去墓地，给这张卡放置1个次世代指示物。
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
	-- 离场信息记录：在离场前记录自身持有的次世代指示物数量
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetOperation(c91438994.damp)
	c:RegisterEffect(e4)
	-- ④：这张卡被战斗破坏送去墓地的场合发动。给予对方这张卡放置的次世代指示物数量×300伤害。
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
c91438994.mentioned_counter={
	[0xa]=true,
}
-- 送墓过滤条件：原本由自己控制且从怪兽区域送去墓地的怪兽
function c91438994.filter1(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- ①效果处理：满足条件时给自身放置1个次世代指示物
function c91438994.addc1(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c91438994.filter1,1,nil,tp) then
		e:GetHandler():AddCounter(0xa,1)
	end
end
-- 除外过滤条件：原本由对方控制且从墓地除外的卡
function c91438994.filter2(c,tp)
	return c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_GRAVE)
end
-- ②效果处理：满足条件时给自身放置2个次世代指示物
function c91438994.addc2(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c91438994.filter2,1,nil,tp) then
		e:GetHandler():AddCounter(0xa,2)
	end
end
-- 攻击力上升数值计算：场上的次世代指示物数量×100
function c91438994.attackup(e,c)
	return c:GetCounter(0xa)*100
end
-- 离场信息记录：将离场前自身拥有的次世代指示物数量保存至Label
function c91438994.damp(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetCounter(0xa))
end
-- ④效果发动条件：此卡在墓地存在且是被战斗破坏
function c91438994.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- ④效果发动准备：设置给予对方伤害的操作信息与参数
function c91438994.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabelObject():GetLabel()
	if chk==0 then return ct~=0 end
	-- 设置伤害目标玩家：对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值：离场前的指示物数量×300
	Duel.SetTargetParam(ct*300)
	-- 设置连锁操作信息：给予对方指示物数量×300的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
-- ④效果处理：给予对方设定的伤害数值
function c91438994.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标玩家与伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成卡片效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
