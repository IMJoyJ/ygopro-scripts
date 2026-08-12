--サイバーサル・サイクロン
-- 效果：
-- ①：以对方场上1只连接怪兽为对象才能发动。从自己墓地选连接标记数量和那只怪兽相同的1只怪兽除外，作为对象的怪兽破坏。这个效果除外的自己怪兽的原本种族是电子界族的场合，可以再选对方的魔法与陷阱区域1张表侧表示的卡破坏。
function c37007105.initial_effect(c)
	-- ①：以对方场上1只连接怪兽为对象才能发动。从自己墓地选连接标记数量和那只怪兽相同的1只怪兽除外，作为对象的怪兽破坏。这个效果除外的自己怪兽的原本种族是电子界族的场合，可以再选对方的魔法与陷阱区域1张表侧表示的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c37007105.target)
	e1:SetOperation(c37007105.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断对方场上的怪兽是否为连接怪兽且自己墓地存在与该怪兽连接数相同的怪兽可以除外。
function c37007105.filter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
		-- 检查自己墓地是否存在与目标连接怪兽连接数相同的怪兽。
		and Duel.IsExistingMatchingCard(c37007105.rmfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetLink())
end
-- 过滤函数，用于判断墓地中的怪兽是否为指定连接数的怪兽且可以除外。
function c37007105.rmfilter(c,link)
	return c:IsType(TYPE_MONSTER) and c:IsLink(link) and c:IsAbleToRemove()
end
-- 效果的发动条件和目标选择处理函数。
function c37007105.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c37007105.filter(chkc,tp) end
	-- 检查是否满足发动条件，即对方场上存在符合条件的连接怪兽。
	if chk==0 then return Duel.IsExistingTarget(c37007105.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要破坏的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1只连接怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c37007105.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置效果操作信息，记录将要破坏的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果操作信息，记录将要除外的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 过滤函数，用于判断对方魔法与陷阱区域的卡是否为表侧表示的卡。
function c37007105.desfilter(c)
	return c:IsFaceup() and c:GetSequence()<5
end
-- 效果的处理函数，执行破坏和除外操作。
function c37007105.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 提示玩家选择要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地中选择与目标怪兽连接数相同的怪兽除外。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c37007105.rmfilter),tp,LOCATION_GRAVE,0,1,1,nil,tc:GetLink())
	local rc=g:GetFirst()
	-- 将选中的怪兽除外。
	if rc and Duel.Remove(rc,0,REASON_EFFECT)~=0 and rc:IsLocation(LOCATION_REMOVED)
		-- 若除外的怪兽种族为电子界族，则可发动后续破坏效果。
		and Duel.Destroy(tc,REASON_EFFECT)~=0 and bit.band(rc:GetOriginalRace(),RACE_CYBERSE)>0 then
		-- 获取对方魔法与陷阱区域的表侧表示卡。
		local sg=Duel.GetMatchingGroup(c37007105.desfilter,tp,0,LOCATION_SZONE,nil)
		-- 判断是否选择发动后续破坏效果。
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(37007105,0)) then  --"是否再选1张对方的魔陷破坏？"
			-- 中断当前效果处理，使后续效果视为不同时处理。
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的魔法与陷阱卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local dg=sg:Select(tp,1,1,nil)
			-- 显示所选魔法与陷阱卡被选为对象的动画效果。
			Duel.HintSelection(dg)
			-- 破坏所选的魔法与陷阱卡。
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
