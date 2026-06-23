--ギャラクシーアイズ FA・フォトン・ドラゴン
-- 效果：
-- 8星怪兽×3
-- 这张卡也能在「银河眼重铠光子龙」以外的自己场上的「银河眼」超量怪兽上面重叠来超量召唤。
-- ①：1回合1次，以这张卡最多2张装备卡为对象才能发动。那些卡在这张卡下面重叠作为超量素材。
-- ②：1回合1次，把这张卡1个超量素材取除，以对方场上1张表侧表示的卡为对象才能发动。那张卡破坏。
function c39030163.initial_effect(c)
	aux.AddXyzProcedure(c,nil,8,3,c39030163.ovfilter,aux.Stringid(39030163,0))  --"是否在「银河眼」超量怪兽上面重叠超量召唤？"
	c:EnableReviveLimit()
	-- ①：1回合1次，以这张卡最多2张装备卡为对象才能发动。那些卡在这张卡下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39030163,1))  --"把装备卡作为超量素材"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCost(c39030163.mtcost)
	e1:SetTarget(c39030163.mttg)
	e1:SetOperation(c39030163.mtop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除，以对方场上1张表侧表示的卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39030163,2))  --"把对方1张卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c39030163.descost)
	e2:SetTarget(c39030163.destg)
	e2:SetOperation(c39030163.desop)
	c:RegisterEffect(e2)
end
-- 用于判断是否满足在「银河眼」超量怪兽上面重叠超量召唤的条件
function c39030163.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107b) and c:IsType(TYPE_XYZ) and not c:IsCode(39030163)
end
-- 效果发动时的费用处理，提示对方玩家效果已被发动
function c39030163.mtcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示“对方选择了：...”效果描述内容
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 用于筛选可以作为超量素材的装备卡
function c39030163.mtfilter(c,e)
	return c:IsCanOverlay() and c:IsCanBeEffectTarget(e)
end
-- 选择作为超量素材的装备卡，最多选择2张
function c39030163.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetHandler():GetEquipGroup()
	if chkc then return g:IsContains(chkc) and c39030163.mtfilter(chkc,e) end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and g:IsExists(c39030163.mtfilter,1,nil,e) end
	-- 提示玩家选择作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	local tg=g:FilterSelect(tp,c39030163.mtfilter,1,2,nil,e)
	-- 将选择的装备卡设置为效果的对象
	Duel.SetTargetCard(tg)
end
-- 用于筛选可以叠放的超量素材
function c39030163.matfilter(c,e)
	return c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) and c:IsCanOverlay()
end
-- 将装备卡叠放至本卡作为超量素材
function c39030163.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取连锁中设定的目标卡组并筛选符合条件的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c39030163.matfilter,nil,e)
	if g:GetCount()>0 then
		-- 将符合条件的卡叠放至本卡
		Duel.Overlay(c,g)
	end
end
-- 效果发动时的费用处理，扣除1个超量素材作为代价
function c39030163.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 向对方玩家提示“对方选择了：...”效果描述内容
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 用于筛选对方场上的表侧表示的卡
function c39030163.desfilter(c)
	return c:IsFaceup()
end
-- 选择对方场上的1张表侧表示的卡作为破坏对象
function c39030163.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c39030163.desfilter(chkc) end
	-- 确认对方场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(c39030163.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张表侧表示的卡作为破坏对象
	local g=Duel.SelectTarget(tp,c39030163.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，指定破坏效果的处理对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果，将目标卡破坏
function c39030163.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
