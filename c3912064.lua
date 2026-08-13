--The tripping MERCURY
-- 效果：
-- ①：这张卡上级召唤成功时才能发动。场上的怪兽全部变成表侧攻击表示。
-- ②：这张卡也能把3只怪兽解放作召唤。
-- ③：只要这张卡的②的方法召唤的这张卡在怪兽区域存在，对方场上的怪兽的攻击力下降那怪兽的原本攻击力数值。
-- ④：这张卡在同1次的战斗阶段中可以作2次攻击。
function c3912064.initial_effect(c)
	-- ①：这张卡上级召唤成功时才能发动。场上的怪兽全部变成表侧攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c3912064.poscon)
	e1:SetTarget(c3912064.postg)
	e1:SetOperation(c3912064.posop)
	c:RegisterEffect(e1)
	-- ②：这张卡也能把3只怪兽解放作召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3912064,0))  --"解放3只怪兽召唤"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c3912064.ttcon)
	e2:SetOperation(c3912064.ttop)
	e2:SetValue(SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF)
	c:RegisterEffect(e2)
	-- ③：只要这张卡的②的方法召唤的这张卡在怪兽区域存在，对方场上的怪兽的攻击力下降那怪兽的原本攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(c3912064.atkcon)
	e3:SetValue(c3912064.atkval)
	c:RegisterEffect(e3)
	-- ④：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 筛选出场上处于守备表示或里侧表示的怪兽，作为效果①要变成表侧攻击表示的对象。
function c3912064.posfilter(c)
	return c:IsDefensePos() or c:IsFacedown()
end
-- 效果①的发动条件：这张卡的召唤类型为上级召唤（即上级召唤成功时）。
function c3912064.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果①的发动时点判定：检查场上是否存在至少1只守备表示或里侧表示的怪兽，若有则可发动。
function c3912064.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段（chk==0），确认场上存在至少1只符合条件的怪兽（守备表示或里侧表示）。
	if chk==0 then return Duel.IsExistingMatchingCard(c3912064.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果①处理时：获取场上所有守备表示或里侧表示的怪兽，若存在则将它们全部变成表侧攻击表示。
function c3912064.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有守备表示或里侧表示的怪兽组。
	local g=Duel.GetMatchingGroup(c3912064.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	-- 将选中的怪兽全部变为表侧攻击表示。
	Duel.ChangePosition(g,POS_FACEUP_ATTACK)
end
-- 效果②的召唤规则条件：允许通过解放3只怪兽来通常召唤这张卡（若c为空则规则效果存在；否则要求所需解放数不超过3且场上存在3只可解放的怪兽）。
function c3912064.ttcon(e,c,minc)
	if c==nil then return true end
	-- 确认所需解放数不超过3，且场上存在至少3只可解放的怪兽作为祭品。
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 效果②召唤规则的处理：让玩家选择3只怪兽作为祭品，将其设为这张卡的素材并解放，用于这次召唤。
function c3912064.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 向玩家显示『请选择要解放的卡』的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择3只要解放的怪兽作为上级召唤的祭品。
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 将选择的3只怪兽解放，作为这张卡的上级召唤素材。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 效果③的适用条件：这张卡是以效果②的方法（解放3只怪兽）召唤的，即召唤类型为上级召唤+自身规则值。
function c3912064.atkcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF
end
-- 被适用怪兽的攻击力下降其原本攻击力数值（若原本攻击力为负则视为0）。
function c3912064.atkval(e,c)
	local rec=c:GetBaseAttack()
	if rec<0 then rec=0 end
	return rec*-1
end
