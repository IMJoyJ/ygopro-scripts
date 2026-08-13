--ヴァイロン・ディシグマ
-- 效果：
-- 4星怪兽×3
-- 1回合1次，可以把这张卡1个超量素材取除，选择对方场上表侧攻击表示存在的1只效果怪兽当作装备卡使用给这张卡装备。这张卡和与这个效果装备的怪兽卡相同属性的怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏。
function c39987164.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用任意4星怪兽3只叠放来进行XYZ召唤（对应效果原文：‘4星怪兽×3’）。
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- 对应效果原文：‘1回合1次，可以把这张卡1个超量素材取除，选择对方场上表侧攻击表示存在的1只效果怪兽当作装备卡使用给这张卡装备。’
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39987164,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c39987164.eqcost)
	e1:SetTarget(c39987164.eqtg)
	e1:SetOperation(c39987164.eqop)
	c:RegisterEffect(e1)
	-- 对应效果原文：‘这张卡和与这个效果装备的怪兽卡相同属性的怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏。’
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39987164,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(c39987164.descon)
	e2:SetTarget(c39987164.destg)
	e2:SetOperation(c39987164.desop)
	c:RegisterEffect(e2)
end
-- 发动代价：判定能否将这张卡的1个超量素材取除作为代价，若能则实际取除1个超量素材。
function c39987164.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 对象选择过滤：对方场上表侧攻击表示的效果怪兽，且控制权可转移（能被装备给我方）。
function c39987164.filter(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsType(TYPE_EFFECT) and c:IsAbleToChangeControler()
end
-- 取对象判定：确认选中的对象位于对方怪兽区、是表侧攻击表示的效果怪兽且符合过滤条件；发动时还需我方魔陷区有空位且对方怪兽区存在符合条件的对象。
function c39987164.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c39987164.filter(chkc) end
	-- 发动条件之一：我方魔陷区必须存在空格，以便把对象怪兽作为装备卡装备。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件之二：对方怪兽区存在至少1只满足filter条件的表侧攻击表示效果怪兽。
		and Duel.IsExistingTarget(c39987164.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择装备卡片的提示消息（请选择要装备的卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从对方怪兽区选择1只符合条件的怪兽，并将其登记为此效果的对象（取对象）。
	local g=Duel.SelectTarget(tp,c39987164.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制判定：这张装备卡只能装备给效果的所有者卡（即双西格马大日本体）。
function c39987164.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理：若对象卡仍表侧攻击表示、仍与此效果关联，则将其作为装备卡装备给这张卡；成功后给该装备卡打上标记，并附加只能装备给本卡的装备限制。
function c39987164.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得该效果发动时选择的对象怪兽（本效果只取1个对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsAttackPos() and tc:IsRelateToEffect(e) then
		-- 将对象怪兽作为装备卡装备给这张卡（由我方控制）；若装备失败则直接结束后续处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(39987164,RESET_EVENT+RESETS_STANDARD,0,0)
		-- 对应效果原文：‘当作装备卡使用给这张卡装备。’
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c39987164.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 判断某张装备中的怪兽卡是否带有本效果装备标记，且其属性与指定属性相同。
function c39987164.desfilter(c,att)
	return c:GetFlagEffect(39987164)~=0 and c:IsAttribute(att)
end
-- 战斗开始时的诱发条件：记录本卡当前的战斗对手（若本卡为攻击者则取攻击对象，否则取攻击者）；对手必须表侧表示，且本卡装备区中存在带有本效果装备标记且与对手属性相同的卡。
function c39987164.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前进行战斗的攻击怪兽。
	local dt=Duel.GetAttacker()
	-- 若攻击者就是本卡，则将战斗对象改取其攻击对象；否则战斗对象就是攻击者（对方怪兽）。
	if dt==c then dt=Duel.GetAttackTarget() end
	if not dt or dt:IsFacedown() then return false end
	e:SetLabelObject(dt)
	local att=dt:GetAttribute()
	return c:GetEquipGroup():IsExists(c39987164.desfilter,1,nil,att)
end
-- 破坏效果的发动时点：无额外发动要求；发动时将之前记录的战斗对象登记为破坏对象（不取对象），并设置破坏信息。
function c39987164.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统设置本次连锁的操作信息：破坏对象为已记录的战斗对象，数量1，分类为破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
-- 效果处理：若之前记录的战斗对象仍与战斗相关（仍在场上），则将其破坏。
function c39987164.desop(e,tp,eg,ep,ev,re,r,rp)
	local dt=e:GetLabelObject()
	if dt:IsRelateToBattle() then
		-- 以效果原因破坏那只战斗对手怪兽（不进行伤害计算）。
		Duel.Destroy(dt,REASON_EFFECT)
	end
end
