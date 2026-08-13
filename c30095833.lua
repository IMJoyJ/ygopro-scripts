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
	-- 为这张卡添加超量召唤手续：可用2只等级7的灵摆怪兽作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsXyzType,TYPE_PENDULUM),7,2)
	c:EnableReviveLimit()
	-- 为这张卡添加灵摆怪兽属性（能在灵摆区放置、灵摆召唤），但不注册灵摆卡“作为魔法卡发动”的效果。
	aux.EnablePendulumAttribute(c,false)
	-- 这张卡在超量召唤的回合不能作为超量召唤的素材。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetCondition(c30095833.xyzcon)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：自己主要阶段才能发动。这张卡特殊召唤。那之后，可以从自己墓地把1只暗属性怪兽作为这张卡的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,30095833)
	e1:SetTarget(c30095833.sptg)
	e1:SetOperation(c30095833.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①的怪兽效果1回合只能使用1次。①：把这张卡1个超量素材取除，以对方场上最多2只攻击力3000以下的怪兽为对象才能发动。那些怪兽破坏。
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
-- 判定这张卡是否处于“超量召唤的回合”：本回合已被超量召唤（持有本回合特殊召唤状态且召唤方式为超量召唤），作为e0的限制条件。
function c30095833.xyzcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 筛选可作为超量素材的怪兽：属性为暗属性，且可以作为超量素材叠放。
function c30095833.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanOverlay()
end
-- 灵摆①效果的发动条件：自己主要怪兽区有空位，且这张卡能够被特殊召唤，才可发动。
function c30095833.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本效果处理涉及特殊召唤这张卡（数量1），供其他卡连锁时判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 灵摆①效果处理：先特殊召唤这张卡；若成功且这张卡仍为超量怪兽，且墓地存在可用的暗属性怪兽，则询问玩家是否选择1只叠放为超量素材。
function c30095833.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡已与效果失去关联，或特殊召唤未能成功，则结束处理。
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	if c:IsType(TYPE_XYZ)
		-- 检查自己墓地是否存在符合条件（不受王家长眠之谷影响）的暗属性怪兽，作为可叠放素材的候选。
		and Duel.GetMatchingGroupCount(aux.NecroValleyFilter(c30095833.mfilter),tp,LOCATION_GRAVE,0,nil)>0
		-- 弹出确认提示，询问玩家是否要从墓地选1只暗属性怪兽作为这张卡的超量素材。
		and Duel.SelectYesNo(tp,aux.Stringid(30095833,2)) then  --"是否从墓地选暗属性怪兽作为超量素材？"
		-- 发送选择提示，将后续选择界面的说明设为“请选择要作为超量素材的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 让玩家从自己墓地选择1只满足条件的暗属性怪兽（已过滤王家长眠之谷影响）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c30095833.mfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的怪兽叠放在这张卡下方作为超量素材。
		Duel.Overlay(c,g)
	end
end
-- 发动代价：检查这张卡是否有超量素材可去除，并实际去除1个超量素材。
function c30095833.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义破坏对象筛选条件：表侧表示且攻击力3000以下。
function c30095833.filter(c)
	return c:IsFaceup() and c:IsAttackBelow(3000)
end
-- 破坏效果的发动条件与选对象：发动时确认存在合法对象，然后选择对方场上1~2只攻击力3000以下的表侧怪兽，并设置破坏的操作信息。
function c30095833.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c30095833.filter(chkc) end
	-- 发动条件检查：对方场上是否存在至少1只满足条件的表侧怪兽。
	if chk==0 then return Duel.IsExistingTarget(c30095833.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 发送选择提示，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1~2只满足条件的表侧攻击力3000以下的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c30095833.filter,tp,0,LOCATION_MZONE,1,2,nil)
	-- 设置操作信息：本次效果将破坏这些对象，数量为选择的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 破坏效果处理：取得连锁中记录的对象，过滤出仍与效果关联的卡并破坏。
function c30095833.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的效果对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #tg>0 then
		-- 将仍与效果关联的对象卡以效果破坏。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- ②效果发动条件：这张卡被破坏前在怪兽区域且被破坏时为表侧表示（即从怪兽区域被破坏）。
function c30095833.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- ②效果发动条件：自己灵摆区域有空格可供放置。
function c30095833.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己灵摆区域的第0格或第1格是否可用。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- ②效果处理：若这张卡仍与效果关联，则将其移动到自己的灵摆区域。
function c30095833.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示移动到自己的灵摆区域，并立即适用其效果。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
