--捕食植物モーレイ・ネペンテス
-- 效果：
-- ①：这张卡的攻击力上升场上的捕食指示物数量×200。
-- ②：这张卡战斗破坏对方怪兽时才能发动。那只破坏的怪兽当作装备卡使用给这张卡装备。
-- ③：1回合1次，以这张卡的效果装备的1张怪兽卡为对象才能发动。那张卡破坏，自己基本分回复那个原本攻击力的数值。
function c22011689.initial_effect(c)
	-- ①：这张卡的攻击力上升场上的捕食指示物数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c22011689.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽时才能发动。那只破坏的怪兽当作装备卡使用给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22011689,0))
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCondition(c22011689.eqcon)
	e2:SetTarget(c22011689.eqtg)
	e2:SetOperation(c22011689.eqop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，以这张卡的效果装备的1张怪兽卡为对象才能发动。那张卡破坏，自己基本分回复那个原本攻击力的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22011689,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c22011689.target)
	e3:SetOperation(c22011689.operation)
	c:RegisterEffect(e3)
end
-- 检索满足条件的卡片组，将目标怪兽特殊召唤
function c22011689.atkval(e,c)
	-- 返回场上存在的捕食指示物数量乘以200作为攻击力
	return Duel.GetCounter(0,1,1,0x1041)*200
end
-- 判断是否满足效果发动条件，包括战斗中破坏对方怪兽且该怪兽在墓地或额外/除外区
function c22011689.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE) and bc:IsType(TYPE_MONSTER)
		and (bc:IsLocation(LOCATION_GRAVE) or bc:IsFaceup() and bc:IsLocation(LOCATION_EXTRA+LOCATION_REMOVED))
end
-- 设置效果的目标卡为战斗破坏的怪兽，并设置操作信息为离开墓地
function c22011689.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即玩家场上魔陷区有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local bc=e:GetHandler():GetBattleTarget()
	-- 将当前处理的效果对象设置为战斗破坏的怪兽
	Duel.SetTargetCard(bc)
	-- 设置操作信息为离开墓地的效果
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,bc,1,0,0)
end
-- 执行装备操作，将目标怪兽装备给自身，并设置装备限制效果
function c22011689.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果处理的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 尝试将目标怪兽装备给自身，若失败则返回
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 创建装备限制效果，确保只能装备给自身
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c22011689.eqlimit)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(22011689,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- 装备限制效果的判断函数，确保只能装备给拥有者
function c22011689.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤函数，用于筛选已装备的怪兽卡
function c22011689.desfilter(c,ec)
	return c:GetFlagEffect(22011689)~=0 and c:GetEquipTarget()==ec and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
end
-- 设置效果的目标卡为装备的怪兽卡，并设置操作信息为破坏和回复LP
function c22011689.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c22011689.desfilter(chkc,c) end
	-- 检查是否满足发动条件，即场上存在符合条件的装备怪兽卡
	if chk==0 then return Duel.IsExistingTarget(c22011689.desfilter,tp,LOCATION_SZONE,0,1,nil,c) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标装备怪兽卡
	local g=Duel.SelectTarget(tp,c22011689.desfilter,tp,LOCATION_SZONE,0,1,1,nil,c)
	local atk=g:GetFirst():GetTextAttack()
	-- 设置操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if atk>0 then
		-- 设置操作信息为回复LP效果
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
	end
end
-- 执行效果操作，破坏目标卡并回复LP
function c22011689.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果处理的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且能被破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local atk=tc:GetTextAttack()
		-- 使玩家回复目标卡原本攻击力数值的LP
		Duel.Recover(tp,atk,REASON_EFFECT)
	end
end
