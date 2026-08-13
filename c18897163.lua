--DDD超死偉王ダークネス・ヘル・アーマゲドン
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，另一边的自己的灵摆区域有「DD」卡存在的场合才能发动。从额外卡组把「DDD 超死伟王 黑地狱终末神」以外的1只「DDD」超量怪兽特殊召唤。
-- 【怪兽效果】
-- 8星「DDD」怪兽×2
-- ①：这张卡超量召唤成功时才能发动。选自己的额外卡组1只表侧表示的「DD」灵摆怪兽在这张卡下面重叠作为超量素材。
-- ②：自己场上的灵摆怪兽不会被效果破坏。
-- ③：1回合1次，把这张卡1个超量素材取除，以自己场上的灵摆怪兽数量的对方场上的怪兽为对象才能发动。那些怪兽破坏。
-- ④：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c18897163.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加灵摆怪兽的基本属性，但不注册灵摆卡的发动效果，灵摆区域效果由e1单独注册。
	aux.EnablePendulumAttribute(c,false)
	-- 为这张卡添加超量召唤手续，素材为2只等级8的「DDD」怪兽。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x10af),8,2)
	-- ①：1回合1次，另一边的自己的灵摆区域有「DD」卡存在的场合才能发动。从额外卡组把「DDD 超死伟王 黑地狱终末神」以外的1只「DDD」超量怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18897163,0))  --"「DDD」超量怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c18897163.spcon)
	e1:SetTarget(c18897163.sptg)
	e1:SetOperation(c18897163.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡超量召唤成功时才能发动。选自己的额外卡组1只表侧表示的「DD」灵摆怪兽在这张卡下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18897163,1))  --"补充超量素材"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c18897163.xyzcon)
	e2:SetTarget(c18897163.xyztg)
	e2:SetOperation(c18897163.xyzop)
	c:RegisterEffect(e2)
	-- ②：自己场上的灵摆怪兽不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设定该永续效果的保护对象为自己场上的灵摆怪兽，使其不受效果破坏。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_PENDULUM))
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：1回合1次，把这张卡1个超量素材取除，以自己场上的灵摆怪兽数量的对方场上的怪兽为对象才能发动。那些怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(18897163,2))  --"对方怪兽破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCost(c18897163.descost)
	e4:SetTarget(c18897163.destg)
	e4:SetOperation(c18897163.desop)
	c:RegisterEffect(e4)
	-- ④：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(18897163,3))  --"这张卡在自己的灵摆区域放置"
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(c18897163.pencon)
	e6:SetTarget(c18897163.pentg)
	e6:SetOperation(c18897163.penop)
	c:RegisterEffect(e6)
end
-- e1的发动条件：检查自己的灵摆区域除自身外是否存在「DD」卡，存在1张以上时条件满足。
function c18897163.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域是否存在除自身以外的「DD」卡，存在1张以上则返回true。
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0xaf)
end
-- 灵摆效果①的特殊召唤筛选条件：额外卡组的「DDD」超量怪兽，且不是这张卡自身，能够被特殊召唤，并且有可用的额外怪兽区空格。
function c18897163.spfilter(c,e,tp)
	return c:IsSetCard(0x10af) and c:IsType(TYPE_XYZ) and not c:IsCode(18897163)
		-- 确认该卡能够被玩家tp用此效果特殊召唤（检查召唤条件与苏生限制），且从额外卡组特殊召唤时有可用空格。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- e1的target函数：发动时检查额外卡组是否存在符合spfilter的「DDD」超量怪兽；若可发动，则设置特殊召唤的操作信息。
function c18897163.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认额外卡组存在至少1只满足spfilter的「DDD」超量怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c18897163.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息：效果将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- e1的operation函数：实际执行特殊召唤，从额外卡组选择1只符合条件的「DDD」超量怪兽表侧表示特殊召唤。
function c18897163.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示选择提示，请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的额外卡组中选择1张满足spfilter条件的「DDD」超量怪兽。
	local g=Duel.SelectMatchingCard(tp,c18897163.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- e2的发动条件：这张卡以超量召唤的方式成功召唤。
function c18897163.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 筛选额外卡组中表侧表示的「DD」灵摆怪兽，并且可以成为超量素材。
function c18897163.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xaf) and c:IsCanOverlay()
end
-- e2的target函数：发动时检查额外卡组是否存在符合条件的表侧表示「DD」灵摆怪兽。
function c18897163.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：额外卡组存在至少1张表侧表示的「DD」灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c18897163.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
-- e2的operation函数：从额外卡组选择1张表侧表示的「DD」灵摆怪兽，重叠在这张卡下面作为超量素材。
function c18897163.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 取得额外卡组中所有符合xyzfilter条件的表侧表示「DD」灵摆怪兽的集合。
	local g=Duel.GetMatchingGroup(c18897163.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		-- 给玩家显示选择提示，请选择要作为超量素材的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		local og=g:Select(tp,1,1,nil)
		-- 将选中的「DD」灵摆怪兽作为超量素材叠放到这张卡下面。
		Duel.Overlay(c,og)
	end
end
-- e4的cost函数：把这张卡1个超量素材取除作为发动代价；先检查是否有素材，然后实际取除1个。
function c18897163.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选自己场上表侧表示的灵摆怪兽，用于计算③效果可选取对象数量。
function c18897163.descfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- e4的target函数：以自己场上的灵摆怪兽数量为ct，选择对方场上的ct只怪兽为对象，并设置破坏的操作信息。
function c18897163.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 计算自己场上表侧表示灵摆怪兽的数量ct，作为可选对方怪兽的数量。
	local ct=Duel.GetMatchingGroupCount(c18897163.descfilter,tp,LOCATION_MZONE,0,nil)
	-- 效果发动合法性检查：自己场上有表侧表示灵摆怪兽，且对方场上有至少ct只怪兽可以作为效果对象。
	if chk==0 then return ct>0 and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,ct,nil) end
	-- 给玩家显示选择提示，请选择要破坏的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的ct只怪兽作为这张卡效果的对象（取对象效果）。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,ct,ct,nil)
	-- 设置当前连锁的操作信息：将选中的g作为破坏对象，数量为g的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- e4的operation函数：效果处理时，将仍与效果关联的对象卡全部破坏。
function c18897163.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得取对象阶段选择的对象卡，并过滤出仍与效果有联系的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将过滤后仍有效的对象卡以效果破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- e6的发动条件：这张卡在怪兽区域被破坏，且破坏前是表侧表示。
function c18897163.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- e6的target函数：检查自己的灵摆区域是否存在空位，以决定能否放置。
function c18897163.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：自己的灵摆区域左侧或右侧任一空位可用。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- e6的operation函数：把这张卡移动到自己的灵摆区域表侧放置。
function c18897163.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示移动到自己的灵摆区域（灵摆放置）。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
