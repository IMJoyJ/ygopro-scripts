--覇王黒竜オッドアイズ・リベリオン・ドラゴン
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，另一边的自己的灵摆区域没有卡存在的场合才能发动。从卡组把1只灵摆怪兽在自己的灵摆区域放置。
-- 【怪兽效果】
-- 龙族7星怪兽×2
-- 7星可以灵摆召唤的场合在额外卡组的表侧的这张卡可以灵摆召唤。
-- ①：这张卡用超量怪兽为素材作超量召唤的场合发动。对方场上的7星以下的怪兽全部破坏，给与对方破坏数量×1000伤害。这个回合，这张卡在同1次的战斗阶段中可以作3次攻击。
-- ②：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。自己的灵摆区域的卡全部破坏，这张卡在自己的灵摆区域放置。
function c45627618.initial_effect(c)
	-- 为这张卡添加超量召唤手续：素材需为2只等级7的龙族怪兽。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),7,2)
	c:EnableReviveLimit()
	-- 为这张卡添加灵摆怪兽属性（可进行灵摆召唤、作为灵摆卡使用）；不注册灵摆卡的“卡的发动”效果。
	aux.EnablePendulumAttribute(c,false)
	-- ①：1回合1次，另一边的自己的灵摆区域没有卡存在的场合才能发动。从卡组把1只灵摆怪兽在自己的灵摆区域放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45627618,0))  --"放置灵摆怪兽"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c45627618.pctg)
	e1:SetOperation(c45627618.pcop)
	c:RegisterEffect(e1)
	-- ①：这张卡用超量怪兽为素材作超量召唤的场合发动。对方场上的7星以下的怪兽全部破坏，给与对方破坏数量×1000伤害。这个回合，这张卡在同1次的战斗阶段中可以作3次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45627618,1))  --"7星以下的怪兽全部破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c45627618.descon)
	e2:SetTarget(c45627618.destg)
	e2:SetOperation(c45627618.desop)
	c:RegisterEffect(e2)
	-- 这张卡用超量怪兽为素材作超量召唤的场合。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c45627618.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ②：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。自己的灵摆区域的卡全部破坏，这张卡在自己的灵摆区域放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(45627618,2))  --"这张卡在自己的灵摆区域放置"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c45627618.pencon)
	e4:SetTarget(c45627618.pentg)
	e4:SetOperation(c45627618.penop)
	c:RegisterEffect(e4)
end
c45627618.pendulum_level=7
-- 过滤条件：卡的类型为灵摆怪兽且未被禁止使用的卡。
function c45627618.pcfilter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- e1的发动判定：检查己方灵摆区域是否有空位，且卡组中存在可放置的灵摆怪兽。
function c45627618.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方灵摆区域的左或右是否有空位。
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 检查卡组中是否有1张以上满足pcfilter条件的灵摆怪兽。
		and Duel.IsExistingMatchingCard(c45627618.pcfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- e1的效果处理：从卡组选择1只灵摆怪兽，正面表示放置到己方灵摆区域。
function c45627618.pcop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果己方两个灵摆区域都没有空位，则效果处理不执行。
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	-- 向玩家显示选择卡片的提示，提示文字为“请选择要放置到场上的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从卡组选择1张满足pcfilter条件的灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c45627618.pcfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的灵摆怪兽正面表示移动到己方灵摆区域，并立即适用其效果。
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- e2的发动条件：这张卡以超量召唤方式特殊召唤成功，且本次超量召唤使用了超量怪兽作为素材（标签值为1）。
function c45627618.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
-- 过滤条件：对方场上的表侧表示且等级为7星以下的怪兽。
function c45627618.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(7)
end
-- e2的发动目标设定：无条件可以发动；获取对方场上满足条件的怪兽，并设置破坏与伤害的操作信息。
function c45627618.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有表侧表示且7星以下的怪兽，作为可能被破坏的对象。
	local g=Duel.GetMatchingGroup(c45627618.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：破坏对象为这些怪兽，数量为其数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：给予对方伤害，数值为怪兽数量×1000。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*1000)
end
-- e2的效果处理：破坏对方场上所有7星以下的表侧怪兽，造成对应伤害；若这张卡仍在场，追加2次攻击机会。
function c45627618.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示且7星以下的怪兽，用于效果处理。
	local g=Duel.GetMatchingGroup(c45627618.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 以效果破坏这些怪兽，返回实际破坏数量。
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		-- 给予对方破坏数量×1000的效果伤害。
		Duel.Damage(1-tp,ct*1000,REASON_EFFECT)
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡在同1次的战斗阶段中可以作3次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 素材检测：检查超量召唤的素材中是否有超量怪兽，若有则将e2的标签设为1，否则为0。
function c45627618.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_XYZ) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- e4的发动条件：这张卡因战斗或效果被破坏，且破坏前在怪兽区域并表侧表示。
function c45627618.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- e4的发动目标设定：须己方灵摆区域有卡，并设置破坏己方灵摆区域全部卡的操作信息。
function c45627618.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方灵摆区域是否有卡存在。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)>0 end
	-- 获取己方灵摆区域的所有卡。
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 设置操作信息：破坏这些灵摆区域的卡，数量为其数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- e4的效果处理：破坏己方灵摆区域所有卡；若这张卡仍与效果相关，则将其放置到己方灵摆区域。
function c45627618.penop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方灵摆区域的所有卡。
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 若己方灵摆区域的卡被成功破坏，且这张卡仍与效果相关，则继续处理。
	if Duel.Destroy(g,REASON_EFFECT)~=0 and e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡正面表示移动到己方灵摆区域。
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
