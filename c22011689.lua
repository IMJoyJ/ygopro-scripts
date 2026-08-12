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
c22011689.mentioned_counter={
	[0x1041]=true,
}
-- 计算攻击力的上升值：取得场上捕食指示物的数量并乘以200
function c22011689.atkval(e,c)
	-- 返回场上双方区域的捕食指示物数量×200，作为攻击力上升数值
	return Duel.GetCounter(0,1,1,0x1041)*200
end
-- 发动条件：确认这张卡正在进行与对手怪兽的战斗，且被其战斗破坏的那只怪兽是怪兽卡，并且该怪兽在墓地或者以表侧表示在额外卡组·除外区
function c22011689.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE) and bc:IsType(TYPE_MONSTER)
		and (bc:IsLocation(LOCATION_GRAVE) or bc:IsFaceup() and bc:IsLocation(LOCATION_EXTRA+LOCATION_REMOVED))
end
-- 效果对象阶段：先确认自己魔法陷阱区有空位，然后把这张卡战斗破坏的怪兽设为对象，并设置涉及墓地的操作信息
function c22011689.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检查：确认自己的魔法·陷阱区存在可用的空格以装备怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local bc=e:GetHandler():GetBattleTarget()
	-- 把这张卡战斗破坏的那只怪兽设置为当前连锁的对象
	Duel.SetTargetCard(bc)
	-- 设置操作信息：该效果涉及墓地（将墓地等处的怪兽作为装备卡装备）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,bc,1,0,0)
end
-- 效果处理：取得对象的怪兽，若该卡仍与效果关联，就把它当作装备卡使用给这张卡装备；装备成功后为其赋予只能装备给这张卡的装备限制，并登记本卡效果的标记
function c22011689.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象（被战斗破坏的那只怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 把那只破坏的怪兽当作装备卡使用给这张卡装备，装备失败则中止处理
		if not Duel.Equip(tp,tc,c,false) then return end
		-- ②：那只破坏的怪兽当作装备卡使用给这张卡装备。
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
-- 装备限制：这张装备卡只能装备给赋予该效果的那张卡（即捕食植物 海鳝猪笼草）
function c22011689.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 筛选条件：该卡是通过这张卡的效果装备的卡（带有本卡标记、装备目标是这张卡），且原本种类是怪兽卡
function c22011689.desfilter(c,ec)
	return c:GetFlagEffect(22011689)~=0 and c:GetEquipTarget()==ec and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
end
-- 对象选择阶段：确认自己的魔法·陷阱区存在可选择的、以这张卡效果装备的怪兽卡，提示玩家选择1张作为对象，并设置破坏以及按该卡原本攻击力回复基本分的操作信息
function c22011689.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c22011689.desfilter(chkc,c) end
	-- 发动可行性检查：确认自己魔法·陷阱区存在能成为对象的、以这张卡效果装备的怪兽卡
	if chk==0 then return Duel.IsExistingTarget(c22011689.desfilter,tp,LOCATION_SZONE,0,1,nil,c) end
	-- 提示玩家：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 以自己的魔法·陷阱区1张通过这张卡效果装备的怪兽卡为对象
	local g=Duel.SelectTarget(tp,c22011689.desfilter,tp,LOCATION_SZONE,0,1,1,nil,c)
	local atk=g:GetFirst():GetTextAttack()
	-- 设置操作信息：对象的那张卡将被效果破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if atk>0 then
		-- 若原本攻击力大于0，设置操作信息：自己基本分将回复那个原本攻击力的数值
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
	end
end
-- 效果处理：取得对象的卡，若该卡仍与效果关联则将其破坏，破坏成功后自己基本分回复那张卡原本攻击力的数值
function c22011689.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象（要破坏的装备怪兽卡）
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果关联，则用效果破坏那张卡，破坏成功才继续处理
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local atk=tc:GetTextAttack()
		-- 自己基本分回复那张卡原本攻击力的数值
		Duel.Recover(tp,atk,REASON_EFFECT)
	end
end
