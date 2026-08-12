--ギャラクシー・ドラグーン
-- 效果：
-- ①：这张卡不能直接攻击，只能向龙族怪兽攻击。
-- ②：这张卡和龙族怪兽进行战斗的场合，只在战斗阶段内那只怪兽的效果无效化，只在伤害步骤内这张卡的攻击力上升1000。
function c9024367.initial_effect(c)
	-- 只能向龙族怪兽攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetValue(c9024367.bttg)
	c:RegisterEffect(e1)
	-- 这张卡不能直接攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	-- 只在伤害步骤内这张卡的攻击力上升1000
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(c9024367.atkcon)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
	-- 这张卡和龙族怪兽进行战斗的场合
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(c9024367.disop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_BE_BATTLE_TARGET)
	c:RegisterEffect(e5)
	-- 只在战斗阶段内那只怪兽的效果无效化
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_DISABLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetTarget(c9024367.distg)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e7)
end
-- 限制攻击目标：不能选择里侧表示怪兽以及非龙族怪兽作为攻击对象
function c9024367.bttg(e,c)
	return c:IsFacedown() or not c:IsRace(RACE_DRAGON)
end
-- 攻击力上升效果的判定条件：当前为伤害步骤且与龙族怪兽进行战斗
function c9024367.atkcon(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	local bc=e:GetHandler():GetBattleTarget()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and bc and bc:IsRace(RACE_DRAGON)
end
-- 在攻击宣言或被选择为攻击对象时，给进行战斗的龙族怪兽添加在战斗阶段结束时重置的标记
function c9024367.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsRace(RACE_DRAGON) then
		bc:RegisterFlagEffect(9024367,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
-- 过滤出带有特定标记的怪兽作为效果无效的对象
function c9024367.distg(e,c)
	return c:GetFlagEffect(9024367)~=0
end
