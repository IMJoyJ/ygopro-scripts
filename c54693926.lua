--冥王結界波
-- 效果：
-- 不能对应这张卡的发动让怪兽的效果发动。
-- ①：对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。
function c54693926.initial_effect(c)
	-- 不能对应这张卡的发动让怪兽的效果发动。①：对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c54693926.target)
	e1:SetOperation(c54693926.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的准备阶段，检查是否存在可无效的怪兽，设置操作信息并限制对方不能对应此卡的发动将怪兽效果连锁
function c54693926.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为发动条件，检查对方场上是否存在至少1只可以被无效化的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有可以被无效化的表侧表示怪兽
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息，表明此效果的处理分类为无效效果，涉及对象为上述获取的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制，使对方不能对应这张卡的发动让怪兽的效果发动
		Duel.SetChainLimit(c54693926.chainlm)
	end
end
-- 连锁限制条件函数，规定连锁发动的卡不能是怪兽卡
function c54693926.chainlm(e,rp,tp)
	return not e:GetHandler():IsType(TYPE_MONSTER)
end
-- 效果处理阶段，使对方场上全部表侧表示怪兽的效果无效，并使对方直到回合结束受到的全部伤害变成0
function c54693926.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上当前所有可以被无效化的表侧表示怪兽
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CHANGE_DAMAGE)
		e3:SetTargetRange(0,1)
		e3:SetValue(0)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 向玩家注册直到回合结束对方受到的全部伤害（包括战斗伤害和效果伤害）变成0的效果
		Duel.RegisterEffect(e3,tp)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e4:SetReset(RESET_PHASE+PHASE_END)
		-- 向玩家注册直到回合结束对方受到的效果伤害变成0的效果（用于免疫效果伤害的判定）
		Duel.RegisterEffect(e4,tp)
	end
end
