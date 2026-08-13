--宇宙の収縮
-- 效果：
-- 各自场上存在的卡都在5张以下时这张卡才能发动。双方出场的卡各自不能超过5张。
function c20644748.initial_effect(c)
	-- 各自场上存在的卡都在5张以下时这张卡才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c20644748.condition)
	c:RegisterEffect(e1)
	-- 双方出场的卡各自不能超过5张。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c20644748.adjustop)
	c:RegisterEffect(e2)
	-- 双方出场的卡各自不能超过5张。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_MAX_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetValue(c20644748.mvalue)
	c:RegisterEffect(e3)
	-- 双方出场的卡各自不能超过5张。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_MAX_SZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	e4:SetValue(c20644748.svalue)
	c:RegisterEffect(e4)
	-- 双方出场的卡各自不能超过5张。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,1)
	e5:SetValue(c20644748.aclimit)
	c:RegisterEffect(e5)
	-- 双方出场的卡各自不能超过5张。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCode(EFFECT_CANNOT_SSET)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,1)
	e6:SetTarget(c20644748.setlimit)
	c:RegisterEffect(e6)
end
-- 定义发动条件判断函数，要求发动方自己场上和对方场上的卡片数量均不超过5张。
function c20644748.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动方自己场上的卡片数量是否不超过5张。
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<=5
		-- 检查对方场上的卡片数量是否不超过5张。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)<=5
end
-- 定义数量调整操作函数，当任一方场上卡片超过5张时，由该方玩家选择超出数量的卡送去墓地，以维持“双方出场的卡各自不能超过5张”的限制。
function c20644748.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断是否处于不适合进行卡片处理的伤害阶段。
	local phase=Duel.GetCurrentPhase()
	-- 若当前处于伤害步骤且尚未计算伤害，或正处于伤害计算时，则跳过本次调整，避免干扰战斗伤害计算。
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	-- 获取本方（效果控制者）场上的卡片数量。
	local c1=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	-- 获取对方场上的卡片数量。
	local c2=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if c1>5 or c2>5 then
		local g=Group.CreateGroup()
		if c1>5 then
			-- 向本方玩家显示“选择要送去墓地的卡”的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 让本方玩家从自己场上选择超出5张数量的卡（c1-5张），作为本次要送去墓地的对象。
			local g1=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,c1-5,c1-5,nil)
			g:Merge(g1)
		end
		if c2>5 then
			-- 向对方玩家显示“选择要送去墓地的卡”的提示信息。
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 让对方玩家从自己场上选择超出5张数量的卡（c2-5张），作为本次要送去墓地的对象。
			local g2=Duel.SelectMatchingCard(1-tp,nil,1-tp,LOCATION_ONFIELD,0,c2-5,c2-5,nil)
			g:Merge(g2)
		end
		-- 将选出的超出数量限制的卡以规则理由全部送去墓地。
		Duel.SendtoGrave(g,REASON_RULE)
		-- 刷新场上卡片信息，重新计算卡片数量限制，确保后续判定准确。
		Duel.Readjust()
	end
end
-- 定义怪兽区域上限取值函数，用于计算当前玩家可用的怪兽区域格数上限。
function c20644748.mvalue(e,fp,rp,r)
	-- 返回怪兽区域可用格数上限，即5减去当前魔陷区的卡片数量，使场上总卡数不超过5。
	return 5-Duel.GetFieldGroupCount(fp,LOCATION_SZONE,0)
end
-- 定义魔陷区域上限取值函数，计算当前玩家可用的魔陷区域格数上限。
function c20644748.svalue(e,fp,rp,r)
	local ct=5
	for i=5,7 do
		-- 若序号5至7的魔陷区域（场地魔法·灵摆区域）中存在卡片，则从可用魔陷区数中扣除该卡所占的格子。
		if Duel.GetFieldCard(fp,LOCATION_SZONE,i) then ct=ct-1 end
	end
	-- 返回魔陷区域可用格数上限，即剩余可用数再减去当前怪兽区的卡片数量，确保总数不超过5。
	return ct-Duel.GetFieldGroupCount(fp,LOCATION_MZONE,0)
end
-- 定义“不能发动魔法·陷阱卡”的判定函数，用于阻止玩家在场上卡片数量已达上限时发动会增加场上卡片数量的卡。
function c20644748.aclimit(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	if re:IsActiveType(TYPE_FIELD) then
		-- 当本方没有已发动的场地魔法卡且场上卡片数已超过4张时，禁止发动新的场地魔法，防止总数超过5。
		return not Duel.GetFieldCard(tp,LOCATION_FZONE,0) and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>4
	elseif re:IsActiveType(TYPE_PENDULUM) then
		-- 当本方场上卡片数已超过4张时，禁止发动灵摆卡，防止放置到魔陷区后总数超过5。
		return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>4
	end
	return false
end
-- 定义“不能覆盖魔法·陷阱卡”的判定函数，用于阻止玩家在场上卡片数量已达上限时覆盖会增加卡片数的卡。
function c20644748.setlimit(e,c,tp)
	-- 当覆盖对象为场地魔法卡、本方没有已发动的场地魔法卡且场上卡片数已超过4张时，禁止覆盖，防止总数超过5。
	return c:IsType(TYPE_FIELD) and not Duel.GetFieldCard(tp,LOCATION_FZONE,0) and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>4
end
