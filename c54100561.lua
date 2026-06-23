--ファドレミコード・ファンシア
-- 效果：
-- ←5 【灵摆】 5→
-- ①：自己的「七音服」灵摆怪兽的灵摆召唤不会被无效化。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从卡组把「发之七音服·凡西娅」以外的1只「七音服」灵摆怪兽表侧加入额外卡组。
-- ②：自己的灵摆区域有奇数的灵摆刻度存在，自己的「七音服」灵摆怪兽被战斗破坏的场合，可以作为代替把这张卡破坏。
function c54100561.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡发动效果
	aux.EnablePendulumAttribute(c)
	-- ①：自己的「七音服」灵摆怪兽的灵摆召唤不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(c54100561.distg)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。从卡组把「发之七音服·凡西娅」以外的1只「七音服」灵摆怪兽表侧加入额外卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54100561,0))
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,54100561)
	e2:SetTarget(c54100561.tetg)
	e2:SetOperation(c54100561.teop)
	c:RegisterEffect(e2)
	-- ②：自己的灵摆区域有奇数的灵摆刻度存在，自己的「七音服」灵摆怪兽被战斗破坏的场合，可以作为代替把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c54100561.repcon)
	e3:SetTarget(c54100561.reptg)
	e3:SetValue(c54100561.repval)
	c:RegisterEffect(e3)
end
-- 过滤自身场上进行灵摆召唤的「七音服」灵摆怪兽
function c54100561.distg(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 过滤卡组中「发之七音服·凡西娅」以外的「七音服」灵摆怪兽
function c54100561.tefilter(c)
	return not c:IsCode(54100561) and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM)
end
-- ①号怪兽效果的发动准备与可行性检查
function c54100561.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c54100561.tefilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组的1张卡加入额外卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
-- ①号怪兽效果的处理：从卡组选1只满足条件的「七音服」灵摆怪兽表侧加入额外卡组
function c54100561.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入额外卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(54100561,1))  --"请选择要加入额外卡组的卡"
	-- 让玩家从卡组选择1张满足条件的「七音服」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c54100561.tefilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡表侧表示送去额外卡组
		Duel.SendtoExtraP(g,nil,REASON_EFFECT)
	end
end
-- 过滤灵摆刻度为奇数的卡
function c54100561.pfilter(c)
	return c:GetCurrentScale()%2~=0
end
-- 检查自己的灵摆区域是否存在奇数灵摆刻度的卡
function c54100561.repcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己的灵摆区域是否存在至少1张奇数灵摆刻度的卡
	return Duel.IsExistingMatchingCard(c54100561.pfilter,tp,LOCATION_PZONE,0,1,nil)
end
-- 过滤自己场上因战斗被破坏的「七音服」灵摆怪兽
function c54100561.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM)
		and c:IsReason(REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的发动准备与可行性检查
function c54100561.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) and eg:IsExists(c54100561.repfilter,1,c,tp) end
	-- 询问玩家是否使用代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 作为代替将这张卡破坏
		Duel.Destroy(c,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
-- 确定被代替破坏的卡是否符合条件
function c54100561.repval(e,c)
	return c54100561.repfilter(c,e:GetHandlerPlayer())
end
