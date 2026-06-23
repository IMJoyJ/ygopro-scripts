--儀式魔人プレコグスター
-- 效果：
-- 仪式怪兽的仪式召唤进行的场合，可以作为那次仪式召唤需要的等级数值的1只怪兽，把墓地存在的这张卡从游戏中除外。把这张卡在仪式召唤使用的仪式怪兽给与对方基本分战斗伤害时，对方选择1张手卡丢弃。
function c4141820.initial_effect(c)
	-- 将「仪式魔人 预知者」设置为仪式召唤时可作为仪式祭品的额外等级素材
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 当「仪式魔人 预知者」成为仪式怪兽的仪式召唤素材时，发动效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c4141820.condition)
	e2:SetOperation(c4141820.operation)
	c:RegisterEffect(e2)
end
-- 判断该怪兽是否为仪式召唤且不是从超量素材位置被送入墓地
function c4141820.condition(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and not e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY)
end
-- 为参与仪式召唤的怪兽注册战斗伤害时丢弃手卡的效果
function c4141820.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	while rc do
		if rc:GetFlagEffect(4141820)==0 then
			-- 为参与仪式召唤的怪兽注册战斗伤害时丢弃手卡的效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(4141820,0))  --"「仪式魔人 预知者」效果适用中"
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_BATTLE_DAMAGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetLabel(ep)
			e1:SetCondition(c4141820.hdcon)
			e1:SetOperation(c4141820.hdop)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			rc:RegisterEffect(e1,true)
			rc:RegisterFlagEffect(4141820,RESET_EVENT+RESETS_STANDARD,0,1)
		end
		rc=eg:GetNext()
	end
end
-- 判断是否为对方造成的战斗伤害且伤害来源为该怪兽
function c4141820.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-e:GetLabel() and eg:GetFirst()==e:GetHandler()
end
-- 使对方丢弃1张手卡
function c4141820.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示「仪式魔人 预知者」发动的动画提示
	Duel.Hint(HINT_CARD,0,4141820)
	-- 使对方丢弃1张手卡
	Duel.DiscardHand(1-e:GetLabel(),nil,1,1,REASON_EFFECT+REASON_DISCARD)
end
