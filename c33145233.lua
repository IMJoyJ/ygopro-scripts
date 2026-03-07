--儀式魔人デモリッシャー
-- 效果：
-- ①：仪式召唤进行的场合，可以作为那次仪式召唤需要的等级数值的1只怪兽，把墓地的这张卡除外。
-- ②：使用这张卡仪式召唤的怪兽不会成为对方的效果的对象。
function c33145233.initial_effect(c)
	-- 效果原文：①：仪式召唤进行的场合，可以作为那次仪式召唤需要的等级数值的1只怪兽，把墓地的这张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 效果原文：②：使用这张卡仪式召唤的怪兽不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c33145233.condition)
	e2:SetOperation(c33145233.operation)
	c:RegisterEffect(e2)
end
-- 规则层面：判断是否为仪式召唤作为素材，且不是从超量素材位置被送入墓地
function c33145233.condition(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and not e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY)
end
-- 规则层面：为使用该卡仪式召唤的怪兽设置不能成为对方效果的对象
function c33145233.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	while rc do
		if rc:GetFlagEffect(33145233)==0 then
			-- 规则层面：设置怪兽不能成为对方效果的对象的效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(33145233,0))  --"「仪式魔人 摧毁者」效果适用中"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
			e1:SetLabel(ep)
			e1:SetValue(c33145233.tgval)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			rc:RegisterEffect(e1,true)
			rc:RegisterFlagEffect(33145233,RESET_EVENT+RESETS_STANDARD,0,1)
		end
		rc=eg:GetNext()
	end
end
-- 规则层面：当对方发动效果时，若效果的发动玩家是当前玩家的对手，则该效果不适用
function c33145233.tgval(e,re,rp)
	return rp==1-e:GetLabel()
end
