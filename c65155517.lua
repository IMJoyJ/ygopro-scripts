--SRクラッカーネル
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：从自己墓地把1张「疾行机人」卡除外才能发动。从卡组把1只「疾行机人」灵摆怪兽在自己的灵摆区域放置。这个回合，自己不是风属性怪兽不能特殊召唤。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：场上的这张卡被战斗·效果破坏的场合才能发动。从自己的手卡·卡组·墓地把1只「疾行机人 碰碰球上校」当作调整使用特殊召唤。
-- ②：这张卡在额外卡组表侧存在的状态，自己的「幻透翼」怪兽进行战斗的伤害计算时才能发动。这张卡除外，那只怪兽的攻击力上升700。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 为怪兽添加灵摆怪兽属性（注册灵摆召唤及在灵摆区发动等规则）
	aux.EnablePendulumAttribute(c)
	-- ①：从自己墓地把1张「疾行机人」卡除外才能发动。从卡组把1只「疾行机人」灵摆怪兽在自己的灵摆区域放置。这个回合，自己不是风属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.pccost)
	e1:SetTarget(s.pctg)
	e1:SetOperation(s.pcop)
	c:RegisterEffect(e1)
	-- ①：场上的这张卡被战斗·效果破坏的场合才能发动。从自己的手卡·卡组·墓地把1只「疾行机人 碰碰球上校」当作调整使用特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力上升"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡在额外卡组表侧存在的状态，自己的「幻透翼」怪兽进行战斗的伤害计算时才能发动。这张卡除外，那只怪兽的攻击力上升700。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
-- 过滤墓地中可作为Cost除外的「疾行机人」卡的过滤函数
function s.cfilter(c)
	return c:IsSetCard(0x2016) and c:IsAbleToRemoveAsCost()
end
-- 灵摆效果①的Cost函数：从自己墓地把1张「疾行机人」卡除外
function s.pccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可作为Cost除外的「疾行机人」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张「疾行机人」卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡因Cost除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤卡组中可放置到灵摆区的「疾行机人」灵摆怪兽的过滤函数
function s.pcfilter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 灵摆效果①的Target函数：检查灵摆区是否有空位以及卡组中是否存在可放置的怪兽
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的左或右灵摆区是否有空位
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 检查卡组中是否存在满足条件的「疾行机人」灵摆怪兽
		and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 灵摆效果①的Operation函数：将卡组的「疾行机人」灵摆怪兽放置到灵摆区，并适用风属性以外不能特殊召唤的限制
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查灵摆区是否有空位
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) then
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 让玩家从卡组选择1只满足条件的「疾行机人」灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽放置到自己的灵摆区域
			Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
	-- 这个回合，自己不是风属性怪兽不能特殊召唤。①：场上的这张卡被战斗·效果破坏的场合才能发动。从自己的手卡·卡组·墓地把1只「疾行机人 碰碰球上校」当作调整使用特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册风属性以外不能特殊召唤的玩家限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤风属性以外怪兽的过滤函数
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
-- 怪兽效果①的Condition函数：检查场上的这张卡是否因战斗或效果被破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤手卡·卡组·墓地中同名卡的过滤函数
function s.spfilter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果①的Target函数：检查怪兽区域空位及是否存在可特殊召唤的同名卡，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组·墓地中是否存在可特殊召唤的同名卡
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置在手卡·卡组·墓地特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 怪兽效果①的Operation函数：从手卡·卡组·墓地特殊召唤同名卡并当作调整使用
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组·墓地选择1只同名卡（适用墓地限制过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功将选择的怪兽以表侧表示特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 当作调整使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 怪兽效果②的Condition函数：检查是否是自己的「幻透翼」怪兽进行战斗的伤害计算时
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽为对方怪兽，则获取被攻击的怪兽（即我方怪兽）
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	if tc and tc:IsControler(tp) and tc:IsSetCard(0xff) then
		e:SetLabelObject(tc)
		return true
	end
	return false
end
-- 怪兽效果②的Target函数：检查这张卡是否能除外，并设置除外的操作信息
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	-- 设置将额外卡组的这张卡除外的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 怪兽效果②的Operation函数：将额外卡组的这张卡除外，使进行战斗的「幻透翼」怪兽攻击力上升700
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 若这张卡仍存在于额外卡组且成功因效果除外
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 then
		if tc:IsRelateToBattle() then
			-- 那只怪兽的攻击力上升700。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(700)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
