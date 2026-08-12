--覇王烈竜オッドアイズ・レイジング・ドラゴン
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，另一边的自己的灵摆区域没有卡存在的场合才能发动。从卡组选1只灵摆怪兽在自己的灵摆区域放置。
-- 【怪兽效果】
-- 龙族7星怪兽×2
-- 7星可以灵摆召唤的场合在额外卡组的表侧表示的这张卡可以灵摆召唤。
-- ①：超量怪兽为素材作超量召唤的这张卡得到以下效果。
-- ●这张卡在同1次的战斗阶段中可以作2次攻击。
-- ●1回合1次，把这张卡1个超量素材取除才能发动。对方场上的卡全部破坏，这张卡的攻击力直到回合结束时上升破坏的卡数量×200。
-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c86238081.initial_effect(c)
	-- 添加超量召唤手续：龙族7星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),7,2)
	c:EnableReviveLimit()
	-- 为这张卡添加灵摆怪兽属性，但不注册默认的灵摆卡发动效果
	aux.EnablePendulumAttribute(c,false)
	-- ①：1回合1次，另一边的自己的灵摆区域没有卡存在的场合才能发动。从卡组选1只灵摆怪兽在自己的灵摆区域放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86238081,0))  --"从卡组把灵摆怪兽放置"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c86238081.pctg)
	e1:SetOperation(c86238081.pcop)
	c:RegisterEffect(e1)
	-- ①：超量怪兽为素材作超量召唤的这张卡得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c86238081.regcon)
	e2:SetOperation(c86238081.regop)
	c:RegisterEffect(e2)
	-- ①：超量怪兽为素材作超量召唤的这张卡得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c86238081.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ●这张卡在同1次的战斗阶段中可以作2次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetValue(1)
	e4:SetCondition(c86238081.effcon)
	c:RegisterEffect(e4)
	-- ●1回合1次，把这张卡1个超量素材取除才能发动。对方场上的卡全部破坏，这张卡的攻击力直到回合结束时上升破坏的卡数量×200。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(86238081,1))  --"对方场上的卡全部破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c86238081.effcon)
	e5:SetCost(c86238081.descost)
	e5:SetTarget(c86238081.destg)
	e5:SetOperation(c86238081.desop)
	c:RegisterEffect(e5)
	-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(86238081,2))  --"这张卡在灵摆区域放置"
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(c86238081.pencon)
	e6:SetTarget(c86238081.pentg)
	e6:SetOperation(c86238081.penop)
	c:RegisterEffect(e6)
end
c86238081.pendulum_level=7
-- 过滤卡组中可以放置到灵摆区域的灵摆怪兽
function c86238081.pcfilter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 灵摆效果的发动准备与合法性检测
function c86238081.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的左或右灵摆区域是否有空位
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 并且检查卡组中是否存在可以放置的灵摆怪兽
		and Duel.IsExistingMatchingCard(c86238081.pcfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 灵摆效果的处理：从卡组选1只灵摆怪兽在自己的灵摆区域放置
function c86238081.pcop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若两个灵摆区域都已满，则不处理
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从卡组选择1张满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c86238081.pcfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽表侧表示放置到自己的灵摆区域
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 检查自身是否是通过超量召唤特殊召唤，且超量素材中包含超量怪兽
function c86238081.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
-- 为自身注册特定标记（Flag），表示已获得超量怪兽作为素材超量召唤时的追加效果，并添加客户端提示
function c86238081.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(86238081,RESET_EVENT+RESETS_STANDARD,0,1)
	c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(86238081,3))  --"超量怪兽为素材作超量召唤"
end
-- 检查自身是否带有超量怪兽作为素材超量召唤的标记，作为追加效果的适用条件
function c86238081.effcon(e)
	return e:GetHandler():GetFlagEffect(86238081)>0
end
-- 破坏效果的Cost：取除这张卡的1个超量素材
function c86238081.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 破坏效果的Target：检查对方场上是否有卡，并设置破坏的操作信息
function c86238081.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在卡片
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end
	-- 获取对方场上的所有卡片
	local sg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	-- 设置破坏对方场上所有卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 破坏效果的处理：破坏对方场上所有的卡，并根据破坏数量提升自身的攻击力
function c86238081.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的所有卡片
	local sg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	-- 破坏获取到的所有卡片，并记录实际被破坏的卡片数量
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升破坏的卡数量×200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 检查超量召唤的素材中是否存在超量怪兽，并将结果保存在LabelObject中
function c86238081.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_XYZ) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 检查被破坏的这张卡之前是否在怪兽区域表侧表示存在
function c86238081.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 灵摆区域放置效果的Target：检查自己的灵摆区域是否有空位
function c86238081.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的左或右灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 灵摆区域放置效果的处理：将这张卡在自己的灵摆区域放置
function c86238081.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示移动并放置到自己的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
