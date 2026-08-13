--ガラスの鎧
-- 效果：
-- 装备卡给怪兽装备时才能发动。直到回合结束时场上的全部装备卡的效果无效。
function c36868108.initial_effect(c)
	-- 装备卡给怪兽装备时才能发动。直到回合结束时场上的全部装备卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_EQUIP)
	e1:SetOperation(c36868108.activate)
	c:RegisterEffect(e1)
end
-- 发动后的效果处理：创建一个持续到结束阶段、影响双方魔陷区中全部装备卡的无效化效果，使这些装备卡的效果被无效。
function c36868108.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 直到回合结束时场上的全部装备卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c36868108.distarget)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述无效化效果以当前玩家tp为控制者注册到场上，使其在结束阶段前持续影响双方魔陷区。
	Duel.RegisterEffect(e1,tp)
end
-- 筛选条件为装备魔法卡（TYPE_EQUIP），即仅将装备卡作为被无效的对象。
function c36868108.distarget(e,c)
	return c:IsType(TYPE_EQUIP)
end
