--覇王黒竜オッドアイズ・リベリオン・エクシーズ・ドラゴン
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡特殊召唤。那之后，可以从自己墓地把1只暗属性怪兽作为这张卡的超量素材。
-- 【怪兽效果】
-- 7星灵摆怪兽×2
-- 7星可以灵摆召唤的场合在额外卡组的表侧的这张卡可以灵摆召唤。这张卡在超量召唤的回合不能作为超量召唤的素材。这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除，以对方场上最多2只攻击力3000以下的怪兽为对象才能发动。那些怪兽破坏。
-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c30095833.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用满足灵摆类型的等级为7的怪兽作为素材，最少需要2只
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsXyzType,TYPE_PENDULUM),7,2)
	c:EnableReviveLimit()
	-- 为卡片添加灵摆怪兽属性，不注册灵摆卡发动效果
	aux.EnablePendulumAttribute(c,false)
	-- 这个卡名的①的怪兽效果1回合只能使用1次。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetCondition(c30095833.xyzcon)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- ①：自己主要阶段才能发动。这张卡特殊召唤。那之后，可以从自己墓地把1只暗属性怪兽作为这张卡的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,30095833)
	e1:SetTarget(c30095833.sptg)
	e1:SetOperation(c30095833.spop)
	c:RegisterEffect(e1)
	-- ①：把这张卡1个超量素材取除，以对方场上最多2只攻击力3000以下的怪兽为对象才能发动。那些怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30095833,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,30095834)
	e2:SetCost(c30095833.descost)
	e2:SetTarget(c30095833.destg)
	e2:SetOperation(c30095833.desop)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30095833,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c30095833.pencon)
	e3:SetTarget(c30095833.pentg)
	e3:SetOperation(c30095833.penop)
	c:RegisterEffect(e3)
end
c30095833.pendulum_level=7
-- 判断该卡是否在超量召唤的回合被特殊召唤
function c30095833.xyzcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤满足暗属性且可作为叠放卡的怪兽
function c30095833.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanOverlay()
end
-- 判断是否可以特殊召唤该卡
function c30095833.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理特殊召唤效果，若为XYZ怪兽则可选择从墓地叠放暗属性怪兽
function c30095833.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否与效果相关且成功特殊召唤
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	if c:IsType(TYPE_XYZ)
		-- 判断墓地中是否存在满足条件的暗属性怪兽
		and Duel.GetMatchingGroupCount(aux.NecroValleyFilter(c30095833.mfilter),tp,LOCATION_GRAVE,0,nil)>0
		-- 询问玩家是否选择从墓地叠放暗属性怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(30095833,2)) then  --"是否从墓地选暗属性怪兽作为超量素材？"
		-- 提示玩家选择作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 选择1只满足条件的暗属性怪兽作为超量素材
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c30095833.mfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的怪兽叠放至该卡上
		Duel.Overlay(c,g)
	end
end
-- 支付效果的费用，移除该卡的一个超量素材
function c30095833.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤满足场上怪兽为表侧表示且攻击力不超过3000的条件
function c30095833.filter(c)
	return c:IsFaceup() and c:IsAttackBelow(3000)
end
-- 设置破坏效果的目标选择，选择对方场上攻击力不超过3000的怪兽
function c30095833.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c30095833.filter(chkc) end
	-- 判断是否存在满足条件的对方怪兽
	if chk==0 then return Duel.IsExistingTarget(c30095833.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上攻击力不超过3000的1~2只怪兽
	local g=Duel.SelectTarget(tp,c30095833.filter,tp,0,LOCATION_MZONE,1,2,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 处理破坏效果，将选中的怪兽破坏
function c30095833.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #tg>0 then
		-- 将满足条件的卡片破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 判断该卡是否从怪兽区域被破坏且为表侧表示
function c30095833.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 设置灵摆区域放置效果的目标判断
function c30095833.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家的灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 处理灵摆区域放置效果，将该卡移至玩家的灵摆区域
function c30095833.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡移动到玩家的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
