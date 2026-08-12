--ユニオン格納庫
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只机械族·光属性同盟怪兽加入手卡。
-- ②：1回合1次，自己场上有机械族·光属性同盟怪兽召唤·特殊召唤的场合，以那之内的1只为对象才能发动。从卡组选可以给那只怪兽装备而卡名不同的1只机械族·光属性同盟怪兽给那只怪兽装备。这个效果装备的同盟怪兽在这个回合不能特殊召唤。
function c66399653.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只机械族·光属性同盟怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,66399653+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c66399653.activate)
	c:RegisterEffect(e1)
	-- 注册一个合并延迟事件监听器，将通常召唤成功和特殊召唤成功的事件合并为一个自定义事件，用于后续触发效果。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,66399653,{EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS})
	-- ②：1回合1次，自己场上有机械族·光属性同盟怪兽召唤·特殊召唤的场合，以那之内的1只为对象才能发动。从卡组选可以给那只怪兽装备而卡名不同的1只机械族·光属性同盟怪兽给那只怪兽装备。这个效果装备的同盟怪兽在这个回合不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66399653,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(custom_code)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetTarget(c66399653.eqtg)
	e2:SetOperation(c66399653.eqop)
	c:RegisterEffect(e2)
end
c66399653.has_text_type=TYPE_UNION
-- 过滤卡组中满足机械族、光属性、同盟怪兽且能加入手牌条件的卡片。
function c66399653.thfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsType(TYPE_UNION) and c:IsAbleToHand()
end
-- 作为这张卡发动时的效果处理，玩家可以选择是否从卡组检索1只机械族·光属性同盟怪兽。
function c66399653.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的机械族·光属性同盟怪兽。
	local g=Duel.GetMatchingGroup(c66399653.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在符合条件的卡，则询问玩家是否将其加入手牌。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(66399653,0)) then  --"是否把同盟怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片因效果加入玩家手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤自己场上表侧表示的、可以作为效果对象的机械族·光属性同盟怪兽，且卡组中存在可装备给该怪兽的同盟怪兽。
function c66399653.tgfilter(c,e,tp,chk)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_UNION)
		and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsControler(tp) and c:IsCanBeEffectTarget(e)
		-- 检查卡组中是否存在至少1张可以装备给该怪兽的、卡名不同的机械族·光属性同盟怪兽。
		and (chk or Duel.IsExistingMatchingCard(c66399653.cfilter,tp,LOCATION_DECK,0,1,nil,c,tp))
end
-- 过滤卡组中与目标怪兽卡名不同、且能作为同盟卡装备给目标怪兽的机械族·光属性同盟怪兽。
function c66399653.cfilter(c,ec,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_UNION) and not c:IsCode(ec:GetCode())
		-- 检查该卡在场上是否唯一、未被禁止、符合同盟装备对象限制，且可以作为同盟卡装备给目标怪兽。
		and c:CheckUniqueOnField(tp) and not c:IsForbidden() and c:CheckUnionTarget(ec) and aux.CheckUnionEquip(c,ec)
end
-- 效果②的靶向处理（Target），筛选并确定召唤·特殊召唤的怪兽作为效果对象。
function c66399653.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c66399653.tgfilter(chkc,e,tp,true) end
	local g=eg:Filter(c66399653.tgfilter,nil,e,tp,false)
	-- 检查可行性：召唤·特殊召唤的怪兽中存在符合条件的怪兽，且自己魔陷区有空位。
	if chk==0 then return g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	if g:GetCount()==1 then
		-- 如果只有1只符合条件的怪兽，则直接将其设为效果对象。
		Duel.SetTargetCard(g:GetFirst())
	else
		-- 提示玩家选择要装备的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		local tc=g:Select(tp,1,1,nil)
		-- 将玩家选择的怪兽设为效果对象。
		Duel.SetTargetCard(tc)
	end
end
-- 效果②的操作处理（Operation），从卡组选择合适的同盟怪兽装备给目标怪兽，并限制该装备怪兽本回合不能特殊召唤。
function c66399653.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设为效果对象的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 提示玩家选择要装备的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 让玩家从卡组中选择1张可以装备给目标怪兽且卡名不同的机械族·光属性同盟怪兽。
		local sg=Duel.SelectMatchingCard(tp,c66399653.cfilter,tp,LOCATION_DECK,0,1,1,nil,tc,tp)
		local ec=sg:GetFirst()
		-- 如果成功选出卡片，则将其作为装备卡装备给目标怪兽。
		if ec and Duel.Equip(tp,ec,tc) then
			-- 为装备的卡片添加同盟怪兽的装备状态属性。
			aux.SetUnionState(ec)
			-- 这个效果装备的同盟怪兽在这个回合不能特殊召唤。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetRange(LOCATION_SZONE)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			ec:RegisterEffect(e1)
		end
	end
end
