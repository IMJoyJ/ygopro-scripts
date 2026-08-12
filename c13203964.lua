--パーフェクトロン・ハイドライブ・ドラゴン
-- 效果：
-- 连接怪兽1只以上
-- ①：这张卡连接召唤的场合或者这张卡进行战斗的伤害步骤结束时发动。对方场上的怪兽全部破坏。那之后，给与对方为自己墓地的连接怪兽数量×300伤害。
-- ②：这张卡只要在怪兽区域存在，属性也当作「光」「水」「炎」「风」使用，不受和自身相同属性的怪兽发动的效果影响。
-- ③：攻击力1000以上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡的攻击力变成下降1000的数值。
local s,id,o=GetID()
-- 注册卡片的效果
function s.initial_effect(c)
	-- 设定连接召唤条件（连接怪兽1只以上）
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_LINK),1)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合或者这张卡进行战斗的伤害步骤结束时发动。对方场上的怪兽全部破坏。那之后，给与对方为自己墓地的连接怪兽数量×300伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	-- 设置进行战斗的伤害步骤结束时发动效果的条件判定
	e2:SetCondition(aux.dsercon)
	c:RegisterEffect(e2)
	-- ②：这张卡只要在怪兽区域存在，属性也当作「光」「水」「炎」「风」使用，
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_ADD_ATTRIBUTE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(ATTRIBUTE_LIGHT+ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_WIND)
	c:RegisterEffect(e3)
	-- 不受和自身相同属性的怪兽发动的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.immval)
	c:RegisterEffect(e4)
	-- ③：攻击力1000以上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡的攻击力变成下降1000的数值。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.reptg)
	c:RegisterEffect(e5)
end
-- 检查是否为连接召唤成功
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①发动的可行性检测与效果目标处理
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有的怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 设置破坏操作信息（对方场上全部怪兽）
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
	-- 计算自己墓地的连接怪兽数量乘以300的伤害数值
	local dam=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_LINK)*300
	if dam>0 then
		-- 设置伤害操作信息（给予对方伤害）
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	end
end
-- 效果①的处理逻辑，破坏对方场上所有怪兽并给予对应伤害
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的怪兽群
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 尝试破坏这些怪兽，如果成功破坏了至少1只怪兽
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 统计自己墓地中连接怪兽的数量
		local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_LINK)
		if ct>0 then
			-- 中断效果处理，使后续伤害步骤与破坏视为不同时处理
			Duel.BreakEffect()
			-- 给予对方为自己墓地的连接怪兽数量×300的伤害值
			Duel.Damage(1-tp,ct*300,REASON_EFFECT)
		end
	end
end
-- 免疫效果判断过滤函数，检查是否为相同属性的怪兽发动的效果
function s.immval(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:IsActivated()
		and e:GetHandler():IsAttribute(te:GetHandler():GetAttribute())
end
-- 代替破坏效果的发动检测与判断（检查被破坏原因及自身攻击力是否在1000以上）
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and atk>=1000 end
	-- 询问玩家是否发动该代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 可以作为代替把这张卡的攻击力变成下降1000的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(atk-1000)
		c:RegisterEffect(e1)
		return true
	else return false end
end
