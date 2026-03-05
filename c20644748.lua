--宇宙の収縮
-- 效果：
-- 各自场上存在的卡都在5张以下时这张卡才能发动。双方出场的卡各自不能超过5张。
function c20644748.initial_effect(c)
	-- 效果原文内容：各自场上存在的卡都在5张以下时这张卡才能发动。双方出场的卡各自不能超过5张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c20644748.condition)
	c:RegisterEffect(e1)
	-- 效果原文内容：各自场上存在的卡都在5张以下时这张卡才能发动。双方出场的卡各自不能超过5张。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c20644748.adjustop)
	c:RegisterEffect(e2)
	-- 效果原文内容：各自场上存在的卡都在5张以下时这张卡才能发动。双方出场的卡各自不能超过5张。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_MAX_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetValue(c20644748.mvalue)
	c:RegisterEffect(e3)
	-- 效果原文内容：各自场上存在的卡都在5张以下时这张卡才能发动。双方出场的卡各自不能超过5张。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_MAX_SZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	e4:SetValue(c20644748.svalue)
	c:RegisterEffect(e4)
	-- 效果原文内容：各自场上存在的卡都在5张以下时这张卡才能发动。双方出场的卡各自不能超过5张。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,1)
	e5:SetValue(c20644748.aclimit)
	c:RegisterEffect(e5)
	-- 效果原文内容：各自场上存在的卡都在5张以下时这张卡才能发动。双方出场的卡各自不能超过5张。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCode(EFFECT_CANNOT_SSET)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,1)
	e6:SetTarget(c20644748.setlimit)
	c:RegisterEffect(e6)
end
-- 判断发动条件：确保自己和对方场上存在的卡都小于等于5张。
function c20644748.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上存在的卡小于等于5张。
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<=5
		-- 判断对方场上存在的卡小于等于5张。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)<=5
end
-- 获取当前游戏阶段。
function c20644748.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果当前阶段是伤害步骤但尚未计算伤害，或伤害计算阶段，则不执行后续操作。
	local phase=Duel.GetCurrentPhase()
	-- 获取自己场上存在的卡的数量。
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	-- 获取对方场上存在的卡的数量。
	local c1=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	-- 提示玩家选择要送去墓地的卡。
	local c2=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if c1>5 or c2>5 then
		local g=Group.CreateGroup()
		if c1>5 then
			-- 从自己场上选择指定数量的卡送去墓地。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 提示对方玩家选择要送去墓地的卡。
			local g1=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,c1-5,c1-5,nil)
			g:Merge(g1)
		end
		if c2>5 then
			-- 从对方场上选择指定数量的卡送去墓地。
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 将满足条件的卡送去墓地。
			local g2=Duel.SelectMatchingCard(1-tp,nil,1-tp,LOCATION_ONFIELD,0,c2-5,c2-5,nil)
			g:Merge(g2)
		end
		-- 刷新场上卡的信息。
		Duel.SendtoGrave(g,REASON_RULE)
		-- 返回自己场上灵摆区域的卡数量。
		Duel.Readjust()
	end
end
-- 返回5减去自己场上灵摆区域的卡数量。
function c20644748.mvalue(e,fp,rp,r)
	-- 计算自己场上魔陷区的卡数量。
	return 5-Duel.GetFieldGroupCount(fp,LOCATION_SZONE,0)
end
-- 计算自己场上怪兽区的卡数量。
function c20644748.svalue(e,fp,rp,r)
	local ct=5
	for i=5,7 do
		-- 如果自己场上存在场地区域的卡，则减少计数。
		if Duel.GetFieldCard(fp,LOCATION_SZONE,i) then ct=ct-1 end
	end
	-- 返回5减去自己场上怪兽区的卡数量。
	return ct-Duel.GetFieldGroupCount(fp,LOCATION_MZONE,0)
end
-- 判断是否无法发动魔法或陷阱卡效果。
function c20644748.aclimit(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	if re:IsActiveType(TYPE_FIELD) then
		-- 若无场地区域且自己场上卡数超过4张，则禁止发动。
		return not Duel.GetFieldCard(tp,LOCATION_FZONE,0) and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>4
	elseif re:IsActiveType(TYPE_PENDULUM) then
		-- 若自己场上卡数超过4张，则禁止发动。
		return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>4
	end
	return false
end
-- 判断是否无法覆盖设置魔法或陷阱卡。
function c20644748.setlimit(e,c,tp)
	-- 若为场地卡且无场地区域且自己场上卡数超过4张，则禁止设置。
	return c:IsType(TYPE_FIELD) and not Duel.GetFieldCard(tp,LOCATION_FZONE,0) and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>4
end
