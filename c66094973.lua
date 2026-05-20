--トランスフォーム・スフィア
-- 效果：
-- 1回合1次，选择对方场上表侧守备表示存在的1只怪兽才能发动。丢弃1张手卡，把选择的对方怪兽当作装备卡使用只有1只给这张卡装备。这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。这张卡攻击的场合，战斗阶段结束时变成守备表示。结束阶段时，这张卡的效果装备的怪兽在对方场上表侧守备表示特殊召唤。
function c66094973.initial_effect(c)
	-- 1回合1次，选择对方场上表侧守备表示存在的1只怪兽才能发动。丢弃1张手卡，把选择的对方怪兽当作装备卡使用只有1只给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66094973,0))  --"装备"
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c66094973.eqcon)
	e1:SetTarget(c66094973.eqtg)
	e1:SetOperation(c66094973.eqop)
	c:RegisterEffect(e1)
	-- 这张卡攻击的场合，战斗阶段结束时变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c66094973.poscon)
	e2:SetOperation(c66094973.posop)
	c:RegisterEffect(e2)
	-- 结束阶段时，这张卡的效果装备的怪兽在对方场上表侧守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(66094973,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c66094973.spcon)
	e3:SetTarget(c66094973.sptg)
	e3:SetOperation(c66094973.spop)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
end
-- 判断自身是否未通过自身效果装备怪兽（限制只能装备1只）
function c66094973.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsHasEffect(66094973)
end
-- 过滤对方场上表侧守备表示且可以转移控制权的怪兽
function c66094973.filter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsAbleToChangeControler()
end
-- 装备效果的发动准备与目标选择
function c66094973.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c66094973.filter(chkc) end
	-- 检查自身魔陷区是否有空位，以及手牌是否不为空
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetFieldGroup(tp,LOCATION_HAND,0)~=0
		-- 检查对方场上是否存在满足条件的表侧守备表示怪兽
		and Duel.IsExistingTarget(c66094973.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只表侧守备表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c66094973.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为丢弃手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 限制装备卡只能装备给这张卡
function c66094973.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 装备效果的执行逻辑，包括丢弃手牌、装备怪兽、上升攻击力以及添加标记
function c66094973.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若手牌为空则无法处理效果，直接返回
	if Duel.GetFieldGroup(tp,LOCATION_HAND,0)==0 then return end
	-- 玩家选择并丢弃1张手牌
	Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 将目标怪兽作为装备卡装备给自身，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c,false) then return end
		e:SetLabelObject(tc)
		-- 把选择的对方怪兽当作装备卡使用只有1只给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c66094973.eqlimit)
		tc:RegisterEffect(e1)
		if atk>0 then
			-- 这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_SET_AVAILABLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(atk)
			tc:RegisterEffect(e2)
		end
		-- 这张卡的效果装备的怪兽
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e3:SetCode(66094973)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
end
-- 判断自身在本回合是否进行过攻击
function c66094973.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 战斗阶段结束时将自身变为守备表示
function c66094973.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将自身变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 判断自身是否带有通过自身效果装备的怪兽标记
function c66094973.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsHasEffect(66094973)
end
-- 结束阶段特殊召唤效果的发动准备与目标设定
function c66094973.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetLabelObject():GetLabelObject()
	-- 将要特殊召唤的装备怪兽设为效果处理对象
	Duel.SetTargetCard(tc)
	-- 设置效果处理信息为特殊召唤该怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 结束阶段特殊召唤效果的执行逻辑，若特殊召唤失败则送去墓地
function c66094973.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要特殊召唤的装备怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍与效果相关，且玩家是否可以进行特殊召唤
	if tc:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummon(tp) then
		-- 将目标怪兽在对方场上表侧守备表示特殊召唤，并检查是否成功
		if Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)==0 then
			-- 特殊召唤失败时，将该怪兽送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
