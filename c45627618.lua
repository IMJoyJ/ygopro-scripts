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
	-- 为卡片添加XYZ召唤手续，要求使用满足龙族种族条件且等级为7、数量为2的怪兽作为素材
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),7,2)
	c:EnableReviveLimit()
	-- 为卡片添加灵摆怪兽属性，但不注册灵摆卡的发动效果
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
	-- 检查这张卡的召唤素材中是否包含超量怪兽，若包含则设置触发条件标签为1
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
-- 过滤函数，用于筛选满足灵摆类型且未被禁止的卡
function c45627618.pcfilter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 判断是否满足灵摆区域放置效果的发动条件，包括灵摆区域是否有空位以及卡组中是否存在灵摆怪兽
function c45627618.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断灵摆区域是否有空位
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 判断卡组中是否存在满足条件的灵摆怪兽
		and Duel.IsExistingMatchingCard(c45627618.pcfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 执行灵摆区域放置效果，选择一张灵摆怪兽放置到灵摆区域
function c45627618.pcop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断灵摆区域是否有空位
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择一张满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c45627618.pcfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽放置到灵摆区域
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 判断是否为超量召唤且满足触发条件
function c45627618.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
-- 过滤函数，用于筛选场上满足条件的7星以下的怪兽
function c45627618.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(7)
end
-- 设置破坏和伤害效果的目标信息
function c45627618.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有满足条件的7星以下的怪兽
	local g=Duel.GetMatchingGroup(c45627618.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置伤害效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*1000)
end
-- 执行破坏和伤害效果，同时增加攻击次数
function c45627618.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足条件的7星以下的怪兽
	local g=Duel.GetMatchingGroup(c45627618.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 将场上满足条件的怪兽全部破坏
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		-- 对对方造成破坏数量×1000的伤害
		Duel.Damage(1-tp,ct*1000,REASON_EFFECT)
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 为这张卡增加额外2次攻击次数
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 检查召唤素材中是否包含超量怪兽，若包含则设置标签为1
function c45627618.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_XYZ) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断这张卡是否因战斗或效果被破坏且之前在怪兽区域
function c45627618.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 设置灵摆区域放置效果的目标信息
function c45627618.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断灵摆区域是否有卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)>0 end
	-- 获取灵摆区域的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行灵摆区域放置效果，破坏灵摆区域的卡并将其放置回灵摆区域
function c45627618.penop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取灵摆区域的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 判断是否成功破坏灵摆区域的卡且这张卡仍在场上
	if Duel.Destroy(g,REASON_EFFECT)~=0 and e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡放置回灵摆区域
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
