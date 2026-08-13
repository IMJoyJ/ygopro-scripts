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
-- 筛选可作为额外超量召唤叠放对象的“银河眼”超量怪兽：表侧表示、字段为0x107b（银河眼）、超量怪兽，且卡名不是本卡（银河眼重铠光子龙）。
function c39030163.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107b) and c:IsType(TYPE_XYZ) and not c:IsCode(39030163)
end
-- ①效果的代价判定：本效果无实际代价，返回true；并给对手发送选择了该效果的提示。
function c39030163.mtcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家展示本效果的文字描述，告知对方我方发动了①效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 筛选可作为效果对象的装备卡：该卡可以作为超量素材，且能成为效果对象。
function c39030163.mtfilter(c,e)
	return c:IsCanOverlay() and c:IsCanBeEffectTarget(e)
end
-- ①效果的发动条件和取对象处理：获取本卡装备的卡组，确认本卡为超量怪兽且存在合法对象后，提示玩家选择1~2张装备卡，并将选择结果设为效果对象。
function c39030163.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetHandler():GetEquipGroup()
	if chkc then return g:IsContains(chkc) and c39030163.mtfilter(chkc,e) end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and g:IsExists(c39030163.mtfilter,1,nil,e) end
	-- 显示选择提示，让玩家从装备卡中选择要重叠为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	local tg=g:FilterSelect(tp,c39030163.mtfilter,1,2,nil,e)
	-- 将选中的装备卡组登记为当前连锁的效果对象，供处理阶段获取。
	Duel.SetTargetCard(tg)
end
-- 效果处理时对对象卡的筛选：与效果仍有联系、不免疫此效果、且仍可作为超量素材。
function c39030163.matfilter(c,e)
	return c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) and c:IsCanOverlay()
end
-- ①效果处理时：若本卡仍合法且表侧表示，则取出连锁对象并过滤出合法卡，将它们重叠到本卡下面作为超量素材。
function c39030163.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 从当前连锁的对象卡组中，过滤出满足matfilter条件的卡（仍相关、不免疫、可叠放）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c39030163.matfilter,nil,e)
	if g:GetCount()>0 then
		-- 将过滤后的对象卡作为超量素材叠放到本卡下面。
		Duel.Overlay(c,g)
	end
end
-- ②效果的代价处理和发动提示：检查能否取除本卡1个超量素材；若能，则实际取除1个作为代价，并向对方发送效果发动提示。
function c39030163.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 向对方玩家展示本效果的文字描述，告知对方我方发动了②效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 定义②效果可选择的对象：对方场上表侧表示的卡。
function c39030163.desfilter(c)
	return c:IsFaceup()
end
-- ②效果的发动条件与取对象处理：检查对方场上有表侧表示卡可作为对象后，提示选择1张，并设置破坏的操作信息。
function c39030163.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c39030163.desfilter(chkc) end
	-- 发动合法性检查：确认对方场上存在至少1张表侧表示卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c39030163.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示，让玩家选择1张要破坏的对方表侧表示卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张表侧表示卡作为效果对象（取对象效果），并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c39030163.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，登记本连锁将破坏对象卡，供其他联动效果检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理时：获取对象卡，若其仍与效果相关，则将其破坏。
function c39030163.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出②效果选择的对象卡（当前连锁的第一个对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
