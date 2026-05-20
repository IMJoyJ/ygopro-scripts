--希望の魔術師
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，自己或者对方的怪兽的攻击宣言时才能发动。那次攻击无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- 4星怪兽×2
-- 4星可以灵摆召唤的场合在额外卡组的表侧表示的这张卡可以灵摆召唤。这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从手卡把1只7星以下的灵摆怪兽效果无效守备表示特殊召唤。那之后，可以把表侧表示的这张卡在自己的灵摆区域放置。
-- ②：这张卡灵摆召唤成功的场合，以自己墓地1只灵摆怪兽为对象才能发动。那只怪兽在这张卡下面重叠作为超量素材。
function c67865534.initial_effect(c)
	-- 为卡片添加超量召唤手续：4星怪兽2只
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 启用灵摆怪兽属性，且不注册默认的灵摆卡发动效果
	aux.EnablePendulumAttribute(c,false)
	-- ①：1回合1次，自己或者对方的怪兽的攻击宣言时才能发动。那次攻击无效。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67865534,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c67865534.atktg)
	e1:SetOperation(c67865534.atkop)
	c:RegisterEffect(e1)
	-- ①：把这张卡1个超量素材取除才能发动。从手卡把1只7星以下的灵摆怪兽效果无效守备表示特殊召唤。那之后，可以把表侧表示的这张卡在自己的灵摆区域放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67865534,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,67865534)
	e2:SetCost(c67865534.spcost)
	e2:SetTarget(c67865534.sptg)
	e2:SetOperation(c67865534.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡灵摆召唤成功的场合，以自己墓地1只灵摆怪兽为对象才能发动。那只怪兽在这张卡下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67865534,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c67865534.xyzcon)
	e3:SetTarget(c67865534.xyztg)
	e3:SetOperation(c67865534.xyzop)
	c:RegisterEffect(e3)
end
c67865534.pendulum_level=4
-- 灵摆效果①的发动准备与靶向函数：设置破坏自身的操作信息
function c67865534.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为破坏这张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆效果①的空间处理函数：无效攻击并破坏自身
function c67865534.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 检查是否成功无效了那次攻击
	if Duel.NegateAttack() then
		-- 中断当前效果处理，使后续的破坏处理与无效攻击不视为同时处理
		Duel.BreakEffect()
		-- 因效果破坏这张卡
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 怪兽效果①的发动代价函数：取除这张卡的1个超量素材
function c67865534.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤手卡中等级7以下且可以守备表示特殊召唤的灵摆怪兽
function c67865534.spfilter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 怪兽效果①的发动准备函数：检查怪兽区域空位及手卡中是否存在符合条件的怪兽，并设置特殊召唤的操作信息
function c67865534.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足条件的灵摆怪兽
		and Duel.IsExistingMatchingCard(c67865534.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 怪兽效果①的空间处理函数：特殊召唤手卡的灵摆怪兽并无效其效果，之后可选择将这张卡放置在灵摆区域
function c67865534.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c67865534.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 尝试将选中的怪兽以表侧守备表示进行特殊召唤的单步处理
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
		end
		-- 完成特殊召唤的流程
		Duel.SpecialSummonComplete()
		-- 检查自己的灵摆区域是否有空位
		if (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
			and c:IsRelateToEffect(e) and c:IsFaceup()
			-- 询问玩家是否选择发动“把这张卡在自己的灵摆区域放置”的效果
			and Duel.SelectEffectYesNo(tp,c,aux.Stringid(67865534,3)) then  --"是否把这张卡在自己的灵摆区域放置？"
			-- 将这张卡移动到自己的灵摆区域表侧表示放置
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
-- 怪兽效果②的发动条件函数：这张卡灵摆召唤成功
function c67865534.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 过滤墓地中可以作为超量素材的灵摆怪兽
function c67865534.xyzfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 怪兽效果②的发动准备函数：选择墓地中1只灵摆怪兽作为对象，并设置离开墓地的操作信息
function c67865534.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c67865534.xyzfilter(chkc) end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查自己墓地是否存在至少1只满足条件的灵摆怪兽
		and Duel.IsExistingTarget(c67865534.xyzfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 让玩家选择墓地中1只满足条件的灵摆怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c67865534.xyzfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为使目标卡片离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 怪兽效果②的空间处理函数：将作为对象的墓地怪兽重叠在这张卡下作为超量素材
function c67865534.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsCanOverlay() then
		-- 将目标怪兽重叠在这张卡下面作为超量素材
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
