--The tripping MERCURY
-- 效果：
-- ①：这张卡上级召唤成功时才能发动。场上的怪兽全部变成表侧攻击表示。
-- ②：这张卡也能把3只怪兽解放作召唤。
-- ③：只要这张卡的②的方法召唤的这张卡在怪兽区域存在，对方场上的怪兽的攻击力下降那怪兽的原本攻击力数值。
-- ④：这张卡在同1次的战斗阶段中可以作2次攻击。
function c3912064.initial_effect(c)
	-- 效果原文：①：这张卡上级召唤成功时才能发动。场上的怪兽全部变成表侧攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c3912064.poscon)
	e1:SetTarget(c3912064.postg)
	e1:SetOperation(c3912064.posop)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡也能把3只怪兽解放作召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3912064,0))  --"解放3只怪兽召唤"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c3912064.ttcon)
	e2:SetOperation(c3912064.ttop)
	e2:SetValue(SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF)
	c:RegisterEffect(e2)
	-- 效果原文：③：只要这张卡的②的方法召唤的这张卡在怪兽区域存在，对方场上的怪兽的攻击力下降那怪兽的原本攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(c3912064.atkcon)
	e3:SetValue(c3912064.atkval)
	c:RegisterEffect(e3)
	-- 效果原文：④：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断怪兽是否为里侧表示或守备表示
function c3912064.posfilter(c)
	return c:IsDefensePos() or c:IsFacedown()
end
-- 条件函数：判断此卡是否为上级召唤
function c3912064.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 目标函数：检查场上是否存在至少1只里侧或守备表示的怪兽
function c3912064.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只里侧或守备表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c3912064.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果处理函数：将场上所有里侧或守备表示的怪兽变为表侧攻击表示
function c3912064.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有里侧或守备表示的怪兽
	local g=Duel.GetMatchingGroup(c3912064.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	-- 将怪兽变为表侧攻击表示
	Duel.ChangePosition(g,POS_FACEUP_ATTACK)
end
-- 召唤条件函数：判断是否满足解放3只怪兽的召唤条件
function c3912064.ttcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否满足解放3只怪兽的召唤条件
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 效果处理函数：选择并解放3只怪兽进行召唤
function c3912064.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择3只怪兽作为祭品
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 解放所选的怪兽
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 攻击力下降效果的触发条件：此卡通过②的方法召唤
function c3912064.atkcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF
end
-- 攻击力下降效果的数值计算：返回怪兽原本攻击力的负值
function c3912064.atkval(e,c)
	local rec=c:GetBaseAttack()
	if rec<0 then rec=0 end
	return rec*-1
end
