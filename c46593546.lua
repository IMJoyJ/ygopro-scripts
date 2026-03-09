--DDD赦俿王デス・マキナ
-- 效果：
-- ←10 【灵摆】 10→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域有卡存在的场合，以自己的场上·墓地1只灵摆怪兽为对象才能发动。另一边的自己的灵摆区域的卡特殊召唤，作为对象的灵摆怪兽在自己的灵摆区域放置。
-- 【怪兽效果】
-- 恶魔族10星怪兽×2
-- 这张卡也能在自己场上的「DDD」怪兽上面重叠来超量召唤。
-- ①：「DDD 赦俿王 死亡机降神」在自己的怪兽区域只能有1只表侧表示存在。
-- ②：对方场上的怪兽卡的效果发动时才能发动（同一连锁上最多1次）。这张卡2个超量素材取除或自己场上1张「契约书」卡破坏，那张对方的卡作为这张卡的超量素材。
-- ③：自己准备阶段才能发动。这张卡在自己的灵摆区域放置。
function c46593546.initial_effect(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),10,2,c46593546.ovfilter,aux.Stringid(46593546,0))  --"是否在「DDD」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 为卡片添加灵摆怪兽属性，但不注册灵摆卡的发动效果
	aux.EnablePendulumAttribute(c,false)
	c:SetUniqueOnField(1,0,46593546,LOCATION_MZONE)
	-- ①：另一边的自己的灵摆区域有卡存在的场合，以自己的场上·墓地1只灵摆怪兽为对象才能发动。另一边的自己的灵摆区域的卡特殊召唤，作为对象的灵摆怪兽在自己的灵摆区域放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46593546,1))  --"特殊召唤灵摆区域的怪兽"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,46593546)
	e1:SetTarget(c46593546.sptg)
	e1:SetOperation(c46593546.spop)
	c:RegisterEffect(e1)
	-- ②：对方场上的怪兽卡的效果发动时才能发动（同一连锁上最多1次）。这张卡2个超量素材取除或自己场上1张「契约书」卡破坏，那张对方的卡作为这张卡的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46593546,2))  --"发动效果的怪兽作为超量素材"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c46593546.ovlcon)
	e2:SetTarget(c46593546.ovltg)
	e2:SetOperation(c46593546.ovlop)
	c:RegisterEffect(e2)
	-- ③：自己准备阶段才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46593546,3))  --"这张卡在自己的灵摆区域放置"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c46593546.pencon)
	e3:SetTarget(c46593546.pentg)
	e3:SetOperation(c46593546.penop)
	c:RegisterEffect(e3)
end
-- 检查怪兽是否为表侧表示且属于DDD系列
function c46593546.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10af)
end
-- 检查怪兽是否为表侧表示或在墓地、类型为灵摆且未被禁止
function c46593546.sptgfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 设置灵摆效果的发动条件：确保灵摆区域有卡、场上可用区域大于0、目标怪兽可特殊召唤、存在符合条件的目标怪兽
function c46593546.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c46593546.sptgfilter(chkc) end
	local c=e:GetHandler()
	-- 获取玩家灵摆区域的第一张符合条件的卡
	local tc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,c)
	-- 检查是否满足灵摆效果发动条件之一：灵摆区域有卡且场上可用区域大于0且目标怪兽可特殊召唤
	if chk==0 then return tc and Duel.GetMZoneCount(tp)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否存在符合条件的目标怪兽
		and Duel.IsExistingTarget(c46593546.sptgfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要放置到灵摆区域的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(46593546,4))  --"请选择要放置到灵摆区域的卡"
	-- 选择目标怪兽作为放置对象
	local g=Duel.SelectTarget(tp,c46593546.sptgfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：特殊召唤一张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息：目标怪兽从墓地离开
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 执行灵摆效果的操作：将灵摆区域的卡特殊召唤并将其放置到灵摆区域
function c46593546.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家灵摆区域的第一张符合条件的卡
	local tc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,c)
	-- 获取当前连锁的目标卡
	local fc=Duel.GetFirstTarget()
	-- 检查灵摆区域是否有卡且场上可用区域大于0
	if tc and Duel.GetMZoneCount(tp)>0
		-- 将灵摆区域的卡特殊召唤到场上
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		and fc:IsRelateToEffect(e) then
		-- 将目标怪兽移动到灵摆区域
		Duel.MoveToField(fc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 判断对方发动的效果是否为怪兽效果或魔法/陷阱卡的发动
function c46593546.ovlcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsControler(1-tp) and rc:GetOriginalType()&TYPE_MONSTER~=0
		and (re:GetActivateLocation()&LOCATION_ONFIELD~=0 or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 检查怪兽是否为表侧表示且属于契约书系列
function c46593546.ovltgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xae)
end
-- 设置超量素材效果的发动条件：确认自身为XYZ怪兽、可取除2个超量素材或场上存在契约书卡
function c46593546.ovltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if chk==0 then return c:IsType(TYPE_XYZ)
		and (c:CheckRemoveOverlayCard(tp,2,REASON_EFFECT)
			-- 检查场上是否存在契约书卡
			or Duel.IsExistingMatchingCard(c46593546.ovltgfilter,tp,LOCATION_ONFIELD,0,1,nil))
		and rc:IsRelateToEffect(re) and rc:IsCanOverlay() end
end
-- 执行超量素材效果的操作：选择取除超量素材或破坏契约书卡，并将对方怪兽作为超量素材
function c46593546.ovlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local opt1=c:IsRelateToEffect(e) and c:CheckRemoveOverlayCard(tp,2,REASON_EFFECT)
	-- 检查场上是否存在契约书卡
	local opt2=Duel.IsExistingMatchingCard(c46593546.ovltgfilter,tp,LOCATION_ONFIELD,0,1,nil)
	local result=0
	if not opt1 and not opt2 then return end
	if opt1 and not opt2 then result=0 end
	if opt2 and not opt1 then result=1 end
	-- 提示玩家选择操作方式：取除超量素材或破坏契约书卡
	if opt1 and opt2 then result=Duel.SelectOption(tp,aux.Stringid(46593546,5),aux.Stringid(46593546,6)) end  --"这张卡2个超量素材取除/自己场上1张「契约书」卡破坏"
	if result==0 then
		result=c:RemoveOverlayCard(tp,2,2,REASON_EFFECT)
	else
		-- 提示玩家选择要破坏的契约书卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择要破坏的契约书卡
		local g=Duel.SelectMatchingCard(tp,c46593546.ovltgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		-- 显示选中契约书卡的动画效果
		Duel.HintSelection(g)
		-- 破坏选中的契约书卡
		result=Duel.Destroy(g,REASON_EFFECT)
	end
	if result>0 and c:IsRelateToEffect(e)
		and rc:IsRelateToEffect(re) and rc:IsControler(1-tp) and not rc:IsImmuneToEffect(e) then
		local og=rc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将对方怪兽的叠放卡送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将对方怪兽作为超量素材叠放
		Duel.Overlay(c,rc)
	end
end
-- 设置灵摆区域放置效果的发动条件：当前回合玩家为自身
function c46593546.pencon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自身
	return Duel.GetTurnPlayer()==tp
end
-- 设置准备阶段放置效果的目标确认：检查灵摆区域是否有空位
function c46593546.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 执行准备阶段放置效果的操作：将自身移动到灵摆区域
function c46593546.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身移动到灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
