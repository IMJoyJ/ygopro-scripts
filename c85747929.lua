--銀河光子竜
-- 效果：
-- 4星怪兽×2
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己场上的其他的光属性怪兽的攻击力上升500。
-- ②：把这张卡1个超量素材取除才能发动。从卡组选1张「光子」卡或「银河」卡加入手卡或送去墓地。
-- ③：自己场上有光属性怪兽特殊召唤的场合，以那之内的1只为对象才能发动。那只怪兽的等级直到回合结束时变成4星或8星。
function c85747929.initial_effect(c)
	-- 添加XYZ召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：自己场上的其他的光属性怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c85747929.atktg)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	-- ②：把这张卡1个超量素材取除才能发动。从卡组选1张「光子」卡或「银河」卡加入手卡或送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85747929,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,85747929)
	e2:SetCost(c85747929.thcost)
	e2:SetTarget(c85747929.thtg)
	e2:SetOperation(c85747929.thop)
	c:RegisterEffect(e2)
	-- ③：自己场上有光属性怪兽特殊召唤的场合，以那之内的1只为对象才能发动。那只怪兽的等级直到回合结束时变成4星或8星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85747929,1))  --"改变等级"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,85747930)
	e3:SetCondition(c85747929.lvcon)
	e3:SetTarget(c85747929.lvtg)
	e3:SetOperation(c85747929.lvop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上除自身以外的光属性怪兽作为攻击力上升的对象
function c85747929.atktg(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c~=e:GetHandler()
end
-- ②号效果的发动代价：取除这张卡的1个超量素材
function c85747929.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤卡组中可以加入手卡或送去墓地的「光子」或「银河」卡片
function c85747929.filter(c)
	return c:IsSetCard(0x55,0x7b) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- ②号效果的靶向函数：检查卡组中是否存在满足条件的「光子」或「银河」卡片
function c85747929.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查卡组中是否存在至少1张满足过滤条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c85747929.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②号效果的运行空间：从卡组选择1张「光子」或「银河」卡，并选择将其加入手卡或送去墓地
function c85747929.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c85747929.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	-- 判断卡片是否能加入手卡，并在能送去墓地的情况下让玩家选择是加入手卡还是送去墓地
	if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将选择的卡片加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	else
		-- 将选择的卡片送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 过滤自己场上特殊召唤成功且等级在1以上的光属性怪兽
function c85747929.cfilter(c,tp)
	return c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevelAbove(1)
end
-- ③号效果的发动条件：检查特殊召唤成功的怪兽中是否存在自己场上的光属性怪兽
function c85747929.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c85747929.cfilter,1,nil,tp)
end
-- ③号效果的靶向函数：选择特殊召唤成功的光属性怪兽中的1只作为效果对象
function c85747929.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c85747929.cfilter,nil,tp):Filter(Card.IsLocation,nil,LOCATION_MZONE)
	-- 在重构连锁时，检查已选择的对象是否仍在怪兽区且属于特殊召唤的怪兽组
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.IsInGroup(chkc,g) end
	-- 在发动准备阶段，检查场上是否存在可以作为对象的特殊召唤的光属性怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.IsInGroup,tp,LOCATION_MZONE,0,1,nil,g) end
	local sg
	if g:GetCount()==1 then
		sg=g:Clone()
		-- 当特殊召唤的怪兽只有1只时，直接将其设为效果对象
		Duel.SetTargetCard(sg)
	else
		-- 向玩家发送提示信息，提示选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 让玩家从特殊召唤的怪兽中选择1只作为效果对象
		sg=Duel.SelectTarget(tp,aux.IsInGroup,tp,LOCATION_MZONE,0,1,1,nil,g)
	end
end
-- ③号效果的运行空间：将作为对象的怪兽的等级直到回合结束时变成4星或8星
function c85747929.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local lv
		if tc:GetLevel()==4 then lv=8
		elseif tc:GetLevel()==8 then lv=4
		-- 若对象怪兽的等级既不是4也不是8，则由玩家宣言选择变成4星还是8星
		else lv=Duel.AnnounceNumber(tp,4,8) end
		-- 那只怪兽的等级直到回合结束时变成4星或8星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
