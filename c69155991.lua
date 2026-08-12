--スクラップ・シャーク
-- 效果：
-- 效果怪兽的效果·魔法·陷阱卡发动时，场上表侧表示存在的这张卡破坏。这张卡被名字带有「废铁」的卡的效果破坏送去墓地的场合，可以从自己卡组把1只名字带有「废铁」的怪兽送去墓地。
function c69155991.initial_effect(c)
	-- 效果怪兽的效果·魔法·陷阱卡发动时，场上表侧表示存在的这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c69155991.chop)
	c:RegisterEffect(e1)
	-- 效果怪兽的效果·魔法·陷阱卡发动时，场上表侧表示存在的这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetOperation(c69155991.desop1)
	c:RegisterEffect(e2)
	-- 效果怪兽的效果·魔法·陷阱卡发动时，场上表侧表示存在的这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_BATTLED)
	e3:SetOperation(c69155991.desop2)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 这张卡被名字带有「废铁」的卡的效果破坏送去墓地的场合，可以从自己卡组把1只名字带有「废铁」的怪兽送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(69155991,0))  --"送去墓地"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCondition(c69155991.tgcon)
	e4:SetTarget(c69155991.tgtg)
	e4:SetOperation(c69155991.tgop)
	c:RegisterEffect(e4)
end
-- 在有效果发动时，若该效果是魔法·陷阱卡的发动或怪兽效果的发动，则给自身注册一个在连锁内有效的标记
function c69155991.chop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER) then
		e:GetHandler():RegisterFlagEffect(69155991,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
	end
end
-- 在连锁处理结束时，若自身有发动标记，则将自身破坏；若处于伤害步骤且未计算伤害，则延迟到伤害计算后破坏
function c69155991.desop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(69155991)==0 then return end
	c:ResetFlagEffect(69155991)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断当前是否处于伤害步骤或伤害计算时，且尚未进行伤害计算
	if (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and not Duel.IsDamageCalculated() then
		c:RegisterFlagEffect(69155992,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
	else
		-- 将这张卡因效果破坏
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 在伤害计算后，若自身有延迟破坏标记，则将自身破坏
function c69155991.desop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(69155992)~=0 then
		-- 将这张卡因效果破坏
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 判断是否是被「废铁」卡片的效果破坏并送去墓地
function c69155991.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(c:GetReason(),0x41)==0x41 and re:GetOwner():IsSetCard(0x24)
end
-- 过滤卡组中名字带有「废铁」的怪兽
function c69155991.filter(c)
	return c:IsSetCard(0x24) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 检查卡组中是否存在满足条件的卡，并设置送去墓地的操作信息
function c69155991.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1只名字带有「废铁」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c69155991.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示该效果会将自己卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 从自己卡组选择1只名字带有「废铁」的怪兽送去墓地
function c69155991.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张名字带有「废铁」的怪兽
	local g=Duel.SelectMatchingCard(tp,c69155991.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
