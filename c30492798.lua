--儀式魔人ディザーズ
-- 效果：
-- 仪式怪兽的仪式召唤进行的场合，可以作为那次仪式召唤需要的等级数值的1只怪兽，把墓地存在的这张卡从游戏中除外。把这张卡在仪式召唤使用的仪式怪兽不受陷阱卡的效果影响。
function c30492798.initial_effect(c)
	-- 仪式怪兽的仪式召唤进行的场合，可以作为那次仪式召唤需要的等级数值的1只怪兽，把墓地存在的这张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 把这张卡在仪式召唤使用的仪式怪兽不受陷阱卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c30492798.condition)
	e2:SetOperation(c30492798.operation)
	c:RegisterEffect(e2)
end
-- 仅在这次作为仪式召唤素材（r为REASON_RITUAL）且此卡此前不在超量素材区域时，才触发后续赋予仪式怪兽免疫陷阱效果的处理。
function c30492798.condition(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and not e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY)
end
-- 遍历该次仪式召唤相关的怪兽（eg），对尚未附加过此效果的怪兽，为其注册一个在怪兽区生效的“不受陷阱卡效果影响”的永续效果，并登记标记，防止同一只怪兽重复获得该效果。
function c30492798.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	while rc do
		if rc:GetFlagEffect(30492798)==0 then
			-- 把这张卡在仪式召唤使用的仪式怪兽不受陷阱卡的效果影响。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetDescription(aux.Stringid(30492798,0))  --"「仪式魔人 布置者」效果适用中"
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c30492798.efilter)
			rc:RegisterEffect(e1,true)
			rc:RegisterFlagEffect(30492798,RESET_EVENT+RESETS_STANDARD,0,1)
		end
		rc=eg:GetNext()
	end
end
-- 免疫效果的判定函数：若某个欲适用的效果类型为陷阱卡效果，则返回true，使该怪兽不受该陷阱卡效果影响。
function c30492798.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
