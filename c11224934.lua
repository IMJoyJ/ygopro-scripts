--強化空間
-- 效果：
-- 自己场上表侧表示存在的全部超量怪兽的攻击力直到结束阶段时上升那怪兽的超量素材每1个300。
function c11224934.initial_effect(c)
	-- 自己场上表侧表示存在的全部超量怪兽的攻击力直到结束阶段时上升那怪兽的超量素材每1个300。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件为伤害步骤限制，只能在伤害计算前发动，不能进入伤害步骤的伤害计算后阶段。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c11224934.target)
	e1:SetOperation(c11224934.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数，选出自己场上表侧表示且拥有超量素材（叠放卡数量不为0）的超量怪兽。
function c11224934.filter(c)
	return c:IsFaceup() and c:GetOverlayCount()~=0
end
-- 效果发动的目标检测函数，确认自己场上存在至少1只符合条件的表侧表示且有超量素材的超量怪兽，才可发动。
function c11224934.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若自己场上不存在满足筛选条件的怪兽，则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c11224934.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理时，选取自己场上所有符合条件的超量怪兽，并给每只怪兽赋予攻击力上升效果，攻击力上升值为该怪兽超量素材数量×300，持续到结束阶段。
function c11224934.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有符合筛选条件（表侧表示且有超量素材）的超量怪兽，形成怪兽集合。
	local g=Duel.GetMatchingGroup(c11224934.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 攻击力直到结束阶段时上升那怪兽的超量素材每1个300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetOverlayCount()*300)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
