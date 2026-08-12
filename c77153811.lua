--儀式魔人カースエンチャンター
-- 效果：
-- 仪式怪兽的仪式召唤进行的场合，可以作为那次仪式召唤需要的等级数值的1只怪兽，把墓地存在的这张卡从游戏中除外。把这张卡在仪式召唤使用的仪式怪兽只要在场上表侧表示存在，同调怪兽的效果无效化。
function c77153811.initial_effect(c)
	-- 仪式怪兽的仪式召唤进行的场合，可以作为那次仪式召唤需要的等级数值的1只怪兽，把墓地存在的这张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 把这张卡在仪式召唤使用的仪式怪兽只要在场上表侧表示存在，同调怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c77153811.condition)
	e2:SetOperation(c77153811.operation)
	c:RegisterEffect(e2)
end
-- 检查是否作为仪式召唤的素材（且之前不是超量素材）
function c77153811.condition(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and not e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY)
end
-- 为仪式召唤出的怪兽注册无效同调怪兽效果的永续效果与连锁处理时无效同调怪兽效果的连续效果
function c77153811.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	while rc do
		if rc:GetFlagEffect(77153811)==0 then
			-- 同调怪兽的效果无效化
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(77153811,0))  --"「仪式魔人 诅咒魔法师」效果适用中"
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetRange(LOCATION_MZONE)
			e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e1:SetTarget(c77153811.distg)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			rc:RegisterEffect(e1,true)
			-- 同调怪兽的效果无效化
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_SOLVING)
			e2:SetRange(LOCATION_MZONE)
			e2:SetOperation(c77153811.disop)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			rc:RegisterEffect(e2,true)
			rc:RegisterFlagEffect(77153811,RESET_EVENT+RESETS_STANDARD,0,1)
		end
		rc=eg:GetNext()
	end
end
-- 确定无效的目标为同调怪兽
function c77153811.distg(e,c)
	return c:IsType(TYPE_SYNCHRO)
end
-- 在连锁处理时，若发动效果的卡是同调怪兽，则将其效果无效
function c77153811.disop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SYNCHRO) then
		-- 使该连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
