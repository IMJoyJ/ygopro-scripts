--竜王絶火ゾロア
-- 效果：
-- 「大贤者」怪兽＋融合·同调·超量·连接怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地或对方场上1只效果怪兽为对象才能发动。那只效果怪兽当作装备魔法卡使用给这张卡装备。
-- ②：怪兽的效果发动时，把自己场上1张表侧表示的「大贤者」怪兽卡送去墓地才能发动。那个效果无效。那之后，可以把对方场上1张卡破坏。
local s,id,o=GetID()
-- 初始化效果，设置融合召唤条件并注册两个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足条件的「大贤者」怪兽和融合·同调·超量·连接怪兽作为素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x150),s.mfilter,true)
	-- 效果①：以自己墓地或对方场上1只效果怪兽为对象才能发动。那只效果怪兽当作装备魔法卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	-- 效果②：怪兽的效果发动时，把自己场上1张表侧表示的「大贤者」怪兽卡送去墓地才能发动。那个效果无效。那之后，可以把对方场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
s.material_type=TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK
-- 过滤函数，用于筛选融合类型为融合·同调·超量·连接的怪兽
function s.mfilter(c)
	return c:IsFusionType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
end
-- 过滤函数，用于筛选可以被装备的怪兽（满足位置、控制权、类型等条件）
function s.eqfilter(c,tp)
	return c:IsFaceupEx() and c:IsAllTypes(TYPE_EFFECT+TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
		and (c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)
		or c:IsLocation(LOCATION_MZONE) and c:IsControler(1-tp) and c:IsAbleToChangeControler())
end
-- 效果①的目标选择函数，检查目标是否满足装备条件
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_ONFIELD) and s.eqfilter(chkc,tp) end
	-- 检查场上是否有足够的装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,LOCATION_ONFIELD,1,nil,tp) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 优先从场上选择目标怪兽，若无则从墓地选择
	local g=aux.SelectTargetFromFieldFirst(tp,s.eqfilter,tp,LOCATION_GRAVE,LOCATION_ONFIELD,1,1,nil,tp)
	if g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)>0 then
		-- 设置操作信息，记录将要离开墓地的卡
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 效果①的处理函数，执行装备操作
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否有效且满足装备条件
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and tc:IsFaceupEx() and tc:IsAllTypes(TYPE_EFFECT+TYPE_MONSTER) then
		local c=e:GetHandler()
		-- 尝试将目标怪兽装备给自身
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 设置装备限制效果，防止被其他卡装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制效果的值函数，限制只能被自身装备
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果②的发动条件，判断是否为怪兽效果的发动
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 过滤函数，用于筛选场上的「大贤者」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x150)
		and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:IsAbleToGraveAsCost()
end
-- 效果②的费用支付函数，选择并送入墓地一张「大贤者」怪兽
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的「大贤者」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择要送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的目标选择函数，设置操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，记录将要使效果无效的卡
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果②的处理函数，使效果无效并可选择破坏对方卡牌
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使效果无效并检查对方场上是否存在卡
	if Duel.NegateEffect(ev) and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
		-- 询问玩家是否破坏对方卡牌
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡破坏？"
		-- 中断当前效果，使后续处理视为错时点
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择要破坏的卡
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 显示被选为对象的卡的动画效果
			Duel.HintSelection(g)
			-- 将选中的卡破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
