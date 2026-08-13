--儀式魔人プレサイダー
-- 效果：
-- 仪式怪兽的仪式召唤进行的场合，可以作为那次仪式召唤需要的等级数值的1只怪兽，把墓地存在的这张卡从游戏中除外。把这张卡在仪式召唤使用的仪式怪兽战斗破坏怪兽的场合，那只仪式怪兽的控制者从卡组抽1张卡。
function c34358408.initial_effect(c)
	-- 仪式怪兽的仪式召唤进行的场合，可以作为那次仪式召唤需要的等级数值的1只怪兽，把墓地存在的这张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 把这张卡在仪式召唤使用的仪式怪兽战斗破坏怪兽的场合，那只仪式怪兽的控制者从卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c34358408.condition)
	e2:SetOperation(c34358408.operation)
	c:RegisterEffect(e2)
end
-- 判定触发条件：本卡作为仪式召唤的素材被使用（REASON_RITUAL），且此前不在超量素材区域（LOCATION_OVERLAY），满足时才发动后续效果。
function c34358408.condition(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and not e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY)
end
-- 遍历本次仪式召唤使用的仪式怪兽，若其尚未附加过抽卡效果，则为其注册“战斗破坏怪兽时控制者抽1张卡”的诱发效果，并用Flag效果防止重复附加；该效果随怪兽离场等正常重置。
function c34358408.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	while rc do
		if rc:GetFlagEffect(34358408)==0 then
			-- 把这张卡在仪式召唤使用的仪式怪兽战斗破坏怪兽的场合，那只仪式怪兽的控制者从卡组抽1张卡。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(34358408,0))  --"「仪式魔人 主持者」效果适用中"
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_BATTLE_DESTROYING)
			e1:SetOperation(c34358408.drawop)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			rc:RegisterEffect(e1,true)
			rc:RegisterFlagEffect(34358408,RESET_EVENT+RESETS_STANDARD,0,1)
		end
		rc=eg:GetNext()
	end
end
-- 仪式怪兽战斗破坏怪兽的诱发效果处理：让该仪式怪兽的控制者从卡组抽1张卡。
function c34358408.drawop(e,tp,eg,ep,ev,re,r,rp)
	-- 让效果的控制者tp（即战斗破坏怪兽的仪式怪兽的控制者）从卡组抽1张卡，抽卡原因为REASON_EFFECT。
	Duel.Draw(tp,1,REASON_EFFECT)
end
