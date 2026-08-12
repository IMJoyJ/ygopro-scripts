--儀式魔人プレサイダー
-- 效果：
-- 仪式怪兽的仪式召唤进行的场合，可以作为那次仪式召唤需要的等级数值的1只怪兽，把墓地存在的这张卡从游戏中除外。把这张卡在仪式召唤使用的仪式怪兽战斗破坏怪兽的场合，那只仪式怪兽的控制者从卡组抽1张卡。
function c34358408.initial_effect(c)
	-- 将此卡作为仪式召唤的额外祭品
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
-- 判断是否为仪式召唤使用的素材
function c34358408.condition(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and not e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY)
end
-- 为仪式怪兽注册战斗破坏时抽卡效果
function c34358408.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	while rc do
		if rc:GetFlagEffect(34358408)==0 then
			-- 为仪式怪兽注册战斗破坏时抽卡效果
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
-- 抽卡效果的处理函数
function c34358408.drawop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家从卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
