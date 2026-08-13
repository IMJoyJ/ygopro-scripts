--甲虫装機 エクサスタッグ
-- 效果：
-- 昆虫族5星怪兽×2
-- 1回合1次，可以把这张卡1个超量素材取除，选择对方的场上·墓地1只怪兽当作装备卡使用给这张卡装备。这张卡的攻击力·守备力上升这个效果装备的怪兽的各自一半数值。
function c26211048.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以昆虫族5星怪兽2只为素材进行XYZ召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_INSECT),5,2)
	c:EnableReviveLimit()
	-- 1回合1次，可以把这张卡1个超量素材取除，选择对方的场上·墓地1只怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26211048,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c26211048.eqcost)
	e1:SetTarget(c26211048.eqtg)
	e1:SetOperation(c26211048.eqop)
	c:RegisterEffect(e1)
end
-- 作为发动代价，需要从这张卡上移除1个超量素材；chk==0时检查是否满足代价，否则实际移除1个超量素材。
function c26211048.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 对象过滤器：选择位于对方场上或墓地的怪兽，且该卡未被宣言禁止（IsForbidden）。
function c26211048.eqfilter(c)
	return c:IsLocation(LOCATION_MZONE) or c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 效果对象判定：本效果取对象，对象为对方场上或墓地1只怪兽；检查对象合法性，并确认存在合法对象且自己有魔陷区空格。
function c26211048.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and chkc:IsControler(1-tp) and c26211048.eqfilter(chkc) end
	-- 检查自己魔陷区是否有可用的空格，用于放置装备魔法卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上或墓地是否存在1只满足eqfilter且可作为效果对象的怪兽。
		and Duel.IsExistingTarget(c26211048.eqfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,nil) end
	-- 显示“请选择要装备的卡”的选择提示，供玩家选取对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从对方场上·墓地选择1只怪兽作为装备对象；优先选择场上的对象，场上对象不足时从墓地选择，并将所选卡登录为效果对象。
	local g=aux.SelectTargetFromFieldFirst(tp,c26211048.eqfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 若对象位于墓地，则设置本次效果涉及墓地卡片移动的操作信息（CATEGORY_LEAVE_GRAVE），以便其他效果响应。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 效果处理：将对象怪兽装备给这张卡；成功后为其附加装备限制，并根据对方怪兽表侧时的原攻防值，使这张卡提升对应一半数值的攻击力与守备力。
function c26211048.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时的对象卡，即被选择装备的对方怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not tc:IsType(TYPE_MONSTER) then return end
	-- 将对象怪兽作为装备卡装备给这张卡；装备失败则立即终止后续处理。
	if not Duel.Equip(tp,tc,c,false) then return end
	-- 当作装备卡使用给这张卡装备（通过装备限制效果，使该装备卡只能装备给效果持有者）。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c26211048.eqlimit)
	tc:RegisterEffect(e1)
	if tc:IsFaceup() then
		local atk=math.ceil(tc:GetTextAttack()/2)
		if atk<0 then atk=0 end
		-- 这张卡的攻击力上升这个效果装备的怪兽的攻击力的一半数值。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
		local def=math.ceil(tc:GetTextDefense()/2)
		if def<0 then def=0 end
		-- 这张卡的守备力上升这个效果装备的怪兽的守备力的一半数值。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(def)
		tc:RegisterEffect(e3)
	end
end
-- 装备限制判定函数：只有当目标卡为效果持有者（即此卡）时才允许装备，确保装备卡只能装备给这张甲虫装机 艾可萨锹甲。
function c26211048.eqlimit(e,c)
	return e:GetOwner()==c
end
