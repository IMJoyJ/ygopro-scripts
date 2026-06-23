--儀式魔人デモリッシャー
-- 效果：
-- ①：仪式召唤进行的场合，可以作为那次仪式召唤需要的等级数值的1只怪兽，把墓地的这张卡除外。
-- ②：使用这张卡仪式召唤的怪兽不会成为对方的效果的对象。
function c33145233.initial_effect(c)
	-- ①：仪式召唤进行的场合，可以作为那次仪式召唤需要的等级数值的1只怪兽，把墓地的这张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：使用这张卡仪式召唤的怪兽不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c33145233.condition)
	e2:SetOperation(c33145233.operation)
	c:RegisterEffect(e2)
end
-- 作为素材判定函数，判定被用作素材的原因是否为仪式召唤，且在此之前不能作为超量素材存在。
function c33145233.condition(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and not e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY)
end
-- 作为素材时的处理函数，遍历所有通过此卡仪式召唤出来的怪兽，为其注册“不会成为对方效果的对象”的效果，并注册相应的标记。
function c33145233.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	while rc do
		if rc:GetFlagEffect(33145233)==0 then
			-- ②：使用这张卡仪式召唤的怪兽不会成为对方的效果的对象。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(33145233,0))  --"「仪式魔人 摧毁者」效果适用中"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_IGNORE_IMMUNE)
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
-- 不能被对象效果指向的值判定函数，判断对方（非获得此效果的仪式怪兽的控制者）发动效果指向自己时该抗性生效。
function c33145233.tgval(e,re,rp)
	return rp==1-e:GetLabel()
end
