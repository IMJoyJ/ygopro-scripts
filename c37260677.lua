--竜王絶火ゾロア
-- 效果：
-- 「大贤者」怪兽＋融合·同调·超量·连接怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地或对方场上1只效果怪兽为对象才能发动。那只效果怪兽当作装备魔法卡使用给这张卡装备。
-- ②：怪兽的效果发动时，把自己场上1张表侧表示的「大贤者」怪兽卡送去墓地才能发动。那个效果无效。那之后，可以把对方场上1张卡破坏。
local s,id,o=GetID()
-- 定义该卡初始化流程：启用苏生限制（必须正规融合召唤过才能从墓地等特殊召唤），添加以「大贤者」怪兽＋融合/同调/超量/连接怪兽为素材的融合召唤手续，并注册①装备②无效破坏两个效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续：融合素材为1只「大贤者」怪兽和1只融合·同调·超量·连接怪兽，使此卡可用这些素材融合召唤。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x150),s.mfilter,true)
	-- ①：以自己墓地或对方场上1只效果怪兽为对象才能发动。那只效果怪兽当作装备魔法卡使用给这张卡装备。
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
-- 过滤函数：判断怪兽是否为融合、同调、超量或连接怪兽中的任意一种，用于限定融合素材的另一方。
function s.mfilter(c)
	return c:IsFusionType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
end
-- 装备效果的对象过滤器：可选择自己墓地的效果怪兽或对方场上的表侧效果怪兽，且该卡不是禁止卡、场上无同名卡限制、满足装备条件。
function s.eqfilter(c,tp)
	return c:IsFaceupEx() and c:IsAllTypes(TYPE_EFFECT+TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
		and (c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)
		or c:IsLocation(LOCATION_MZONE) and c:IsControler(1-tp) and c:IsAbleToChangeControler())
end
-- 发动时合法性判定：若指定对象则检查对象位置和过滤条件；否则检查自己魔陷区有空位且存在合法对象。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_ONFIELD) and s.eqfilter(chkc,tp) end
	-- 检查自己魔陷区是否有可用空格，用于后续放置装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查是否存在符合条件的对象：自己墓地或对方场上的效果怪兽，并且能够成为效果对象。
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,LOCATION_ONFIELD,1,nil,tp) end
	-- 弹出“请选择要装备的卡”的提示消息，引导玩家选择装备对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1张装备对象：优先选择对方场上的效果怪兽；若场上没有合法目标，则选择自己墓地的效果怪兽，并将所选卡设为该效果的取对象目标。
	local g=aux.SelectTargetFromFieldFirst(tp,s.eqfilter,tp,LOCATION_GRAVE,LOCATION_ONFIELD,1,1,nil,tp)
	if g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)>0 then
		-- 设置操作信息：有卡将从墓地离开，便于其他卡检测离墓事件（如王家长眠之谷等）。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 效果处理：取得对象卡，确认合法后将其作为装备魔法卡装备给此卡，并添加只能装备给此卡的限制。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 验证对象仍与效果相关、不受王家长眠之谷影响、表侧表示且为效果怪兽，确保可以继续装备。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and tc:IsFaceupEx() and tc:IsAllTypes(TYPE_EFFECT+TYPE_MONSTER) then
		local c=e:GetHandler()
		-- 将选中的效果怪兽作为装备魔法卡装备给这张卡；若装备失败则不再继续处理。
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
-- 装备限制：该装备卡只能装备给此效果的持有者（此卡），防止其装备到其他怪兽身上。
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ②效果的发动条件：仅在怪兽效果发动时才能发动（检测到连锁中的效果为怪兽效果）。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- cost用卡过滤：自己场上表侧表示、属于「大贤者」系列、原始类型为怪兽且可作为代价送去墓地。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x150)
		and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:IsAbleToGraveAsCost()
end
-- 支付cost：从自己场上选择1张表侧表示的「大贤者」怪兽卡送去墓地作为发动代价。
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查：确认自己场上有满足条件的「大贤者」怪兽卡可以作为cost。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 弹出“请选择要送去墓地的卡”的提示，要求玩家选择cost卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上选择1张符合条件的表侧表示「大贤者」怪兽卡作为cost。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的卡送去墓地，作为效果发动的代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果的目标/操作信息设定：发动时不需要选择对象，但设置操作信息为无效该怪兽效果。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将发动中的怪兽效果（eg）标记为将被无效的对象，供其他卡响应检测。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ②效果处理：无效该怪兽效果；若无效成功且对方场上有卡，则询问是否将对方场上1张卡破坏；选择是则执行破坏。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效该怪兽效果，并检查对方场上是否存在可破坏的卡，决定是否进入后续破坏选择。
	if Duel.NegateEffect(ev) and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
		-- 询问玩家是否要破坏对方场上1张卡。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡破坏？"
		-- 中断当前效果处理，使后续破坏处理与无效处理不在同一时点进行（对应“那之后”的时点）。
		Duel.BreakEffect()
		-- 弹出“请选择要破坏的卡”的提示，要求玩家选择破坏对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上的1张卡作为破坏对象。
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 向玩家展示被选为对象的卡片动画，并记录这些卡被选为对象。
			Duel.HintSelection(g)
			-- 以效果破坏选中的对方场上的卡片。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
