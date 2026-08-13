--グリザイユの牢獄
-- 效果：
-- 自己场上有上级召唤·仪式召唤·融合召唤的怪兽之内任意种表侧表示存在的场合才能发动。直到下次的对方回合的结束时，双方不能进行同调·超量召唤，场上的同调·超量怪兽效果无效化，不能攻击。
function c22888900.initial_effect(c)
	-- 对应效果原文：自己场上有上级召唤·仪式召唤·融合召唤的怪兽之内任意种表侧表示存在的场合才能发动。（创建并注册这张魔陷的发动效果，满足条件时可自由时点发动）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c22888900.condition)
	e1:SetOperation(c22888900.operation)
	c:RegisterEffect(e1)
end
-- 筛选表侧表示且为上级召唤、仪式召唤或融合召唤的怪兽，用于满足发动条件。
function c22888900.cfilter(c)
	return c:IsFaceup()
		and (c:IsSummonType(SUMMON_TYPE_ADVANCE) or c:IsSummonType(SUMMON_TYPE_RITUAL) or c:IsSummonType(SUMMON_TYPE_FUSION))
end
-- 发动条件判定：检查自己场上是否存在至少1只通过上级召唤、仪式召唤或融合召唤出场的表侧表示怪兽。
function c22888900.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.IsExistingMatchingCard，在自己主要怪兽区检索是否存在1只满足cfilter条件的怪兽，存在则返回true（发动条件成立）。
	return Duel.IsExistingMatchingCard(c22888900.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果处理：生成并注册三个持续效果——无效化场上的同调·超量怪兽、使其不能攻击、禁止双方进行同调·超量召唤；并根据当前是否为对方回合设置重置时机，使效果持续到下次对方回合结束。
function c22888900.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 对应效果原文：场上的同调·超量怪兽效果无效化，不能攻击。（e1为无效化，e2为不能攻击，tg筛选同调·超量怪兽）
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c22888900.tg)
	e1:SetCode(EFFECT_DISABLE)
	-- 判断当前回合玩家是否为对方（即是否在对方回合发动）：若是，则需要两个结束阶段后才重置，以持续到下次对方回合结束。
	if Duel.GetTurnPlayer()~=tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	end
	-- 将‘场上的同调·超量怪兽效果无效化’的持续效果注册到场上，由效果发动者控制。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	-- 将‘场上的同调·超量怪兽不能攻击’的持续效果注册到场上。
	Duel.RegisterEffect(e2,tp)
	-- 对应效果原文：双方不能进行同调·超量召唤。（e3限制特殊召唤，splimit限定为同调召唤或超量召唤）
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c22888900.splimit)
	-- 对禁止特殊召唤效果同样判断当前是否为对方回合，以决定其重置时机（确保持续到下次对方回合结束）。
	if Duel.GetTurnPlayer()~=tp then
		e3:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	else
		e3:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	end
	-- 将‘双方不能进行同调·超量召唤’的限制效果注册到场上，影响双方玩家。
	Duel.RegisterEffect(e3,tp)
end
-- 筛选场上的同调怪兽或超量怪兽，作为‘效果无效化’和‘不能攻击’的适用对象。
function c22888900.tg(e,c)
	return c:IsType(TYPE_SYNCHRO+TYPE_XYZ)
end
-- 作为特殊召唤限制的判定函数：当特殊召唤的召唤类型为同调召唤或超量召唤时，禁止该特殊召唤。
function c22888900.splimit(e,c,tp,sumtp,sumpos)
	return bit.band(sumtp,SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO or bit.band(sumtp,SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ
end
