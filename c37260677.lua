--竜王絶火ゾロア
-- 效果：
-- 「大贤者」怪兽＋融合·同调·超量·连接怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地或对方场上1只效果怪兽为对象才能发动。那只效果怪兽当作装备魔法卡使用给这张卡装备。
-- ②：怪兽的效果发动时，把自己场上1张表侧表示的「大贤者」怪兽卡送去墓地才能发动。那个效果无效。那之后，可以把对方场上1张卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册「大贤者」怪兽＋融合·同调·超量·连接怪兽的融合召唤手续，以及①②效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册融合召唤所需素材为1只「大贤者」怪兽与1只融合·同调·超量·连接怪兽。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x150),s.mfilter,true)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以自己墓地或对方场上1只效果怪兽为对象才能发动。那只效果怪兽当作装备魔法卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	-- ②：怪兽的效果发动时，把自己场上1张表侧表示的「大贤者」怪兽卡送去墓地才能发动。那个效果无效。那之后，可以把对方场上1张卡破坏。
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
-- 协同融合检查函数：校验素材组是否包含1只「大贤者」卡和1只同调怪兽。
function s.synchro_fusion_check(tp,sg,fc)
	-- 检查素材卡片组中是否同时包含「大贤者」素材与同调怪兽素材。
	return aux.gffcheck(sg,Card.IsFusionSetCard,0x150,Card.IsFusionType,TYPE_SYNCHRO)
end
-- 融合素材过滤函数：检查怪兽是否为融合·同调·超量·连接怪兽。
function s.mfilter(c)
	return c:IsFusionType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
end
-- 装备对象过滤函数：检查卡片是否为表侧表示的效果怪兽、未禁止装备且唯一性合法，并且位于自己墓地或处于对方怪兽区且可变更控制权。
function s.eqfilter(c,tp)
	return c:IsFaceupEx() and c:IsAllTypes(TYPE_EFFECT+TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
		and (c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)
		or c:IsLocation(LOCATION_MZONE) and c:IsControler(1-tp) and c:IsAbleToChangeControler())
end
-- ①效果的目标处理函数：检查自己魔陷区空位及合法对象，优先从场上选取目标并在对象来自墓地时记录离开墓地信息。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_ONFIELD) and s.eqfilter(chkc,tp) end
	-- 发动条件检查：确认自己魔法与陷阱区域至少有1个空位用于放置装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 确认自己墓地或对方场上存在至少1只符合条件的效果怪兽作为对象。
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,LOCATION_ONFIELD,1,nil,tp) end
	-- 发送提示信息，引导玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 优先从场上选择目标，若场上不足则从自己墓地或对方场上选择1只符合条件的效果怪兽作为对象。
	local g=aux.SelectTargetFromFieldFirst(tp,s.eqfilter,tp,LOCATION_GRAVE,LOCATION_ONFIELD,1,1,nil,tp)
	if g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)>0 then
		-- 当对象位于墓地时，设置预计使其离开墓地的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- ①效果的处理函数：校验对象有效且不受王家长眠之谷影响后，将其装备给这张卡并赋予装备限制效果。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁指定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡仍与效果保持联系、不受王家长眠之谷影响且仍是表侧效果怪兽。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and tc:IsFaceupEx() and tc:IsAllTypes(TYPE_EFFECT+TYPE_MONSTER) then
		local c=e:GetHandler()
		-- 将对象怪兽作为装备卡装备给这张卡，若装备失败则结束处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 那只效果怪兽当作装备魔法卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制判定函数：限制该装备卡只能装备给效果的拥有者（即这张卡）。
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ②效果的发动条件：检查当前发动的连锁效果是否为怪兽的效果。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 代价过滤函数：检查卡片是否为表侧表示、原本种类为怪兽、可作为代价送墓的「大贤者」卡。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x150)
		and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:IsAbleToGraveAsCost()
end
-- ②效果的发动代价：检查并把自己场上1张表侧表示的「大贤者」怪兽卡送去墓地。
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检查：确认自己场上存在至少1张符合条件的「大贤者」怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 发送提示信息，引导玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上选择1张表侧表示的「大贤者」怪兽卡。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将所选的「大贤者」怪兽卡作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果的目标处理函数：必发条件已满足时始终返回可发动，并设置使对象怪兽效果无效的操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：预计使触发连锁的怪兽效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ②效果的处理函数：使触发的怪兽效果无效，若对方场上有卡可破坏则询问玩家是否将其破坏。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的怪兽效果无效，并检查对方场上是否存在卡片。
	if Duel.NegateEffect(ev) and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
		-- 询问玩家是否再把对方场上1张卡破坏。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡破坏？"
		-- 中断当前效果处理，使后续破坏与之前的效果无效视为不同时处理。
		Duel.BreakEffect()
		-- 发送提示信息，引导玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方场上选择1张卡。
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 显示选中卡片的对象提示动画。
			Duel.HintSelection(g)
			-- 以效果破坏所选定的对方场上的卡。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
