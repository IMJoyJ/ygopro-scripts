--竜脚獣ブラキオン
-- 效果：
-- 这张卡不能从卡组特殊召唤。这张卡可以把1只恐龙族怪兽解放表侧表示上级召唤。
-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ②：这张卡反转召唤成功的场合发动。这张卡以外的场上的怪兽全部变成里侧守备表示。
-- ③：这张卡被攻击的场合，那次战斗发生的对对方的战斗伤害变成2倍。
function c41753322.initial_effect(c)
	-- 这张卡不能从卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡可以把1只恐龙族怪兽解放表侧表示上级召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41753322,0))  --"把1只恐龙族怪兽解放上级召唤"
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c41753322.otcon)
	e2:SetOperation(c41753322.otop)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
	-- 自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(41753322,1))  --"变成里侧守备"
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c41753322.postg)
	e3:SetOperation(c41753322.posop)
	c:RegisterEffect(e3)
	-- 这张卡反转召唤成功的场合发动。这张卡以外的场上的怪兽全部变成里侧守备表示
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41753322,1))  --"变成里侧守备"
	e4:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e4:SetTarget(c41753322.postg2)
	e4:SetOperation(c41753322.posop2)
	c:RegisterEffect(e4)
	-- 这张卡被攻击的场合，那次战斗发生的对对方的战斗伤害变成2倍
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
	e5:SetCondition(c41753322.dcon)
	-- 将对对方的战斗伤害变为2倍
	e5:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e5)
end
-- 过滤满足条件的恐龙族怪兽
function c41753322.otfilter(c,tp)
	return c:IsRace(RACE_DINOSAUR) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足上级召唤的条件
function c41753322.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足条件的怪兽组
	local mg=Duel.GetMatchingGroup(c41753322.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断是否满足上级召唤的条件
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行上级召唤的处理
function c41753322.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取满足条件的怪兽组
	local mg=Duel.GetMatchingGroup(c41753322.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 选择用于上级召唤的祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放祭品
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 设置效果发动时的处理信息
function c41753322.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(41753322)==0 end
	c:RegisterFlagEffect(41753322,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置效果发动时的处理信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 执行效果的处理
function c41753322.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 设置效果发动时的处理信息
function c41753322.postg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置效果发动时的处理信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 执行效果的处理
function c41753322.posop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 将目标怪兽变为里侧守备表示
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
-- 判断是否为攻击对象
function c41753322.dcon(e)
	local c=e:GetHandler()
	-- 判断是否为攻击对象
	return Duel.GetAttackTarget()==c
end
