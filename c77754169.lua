--超装甲兵器ロボ ブラックアイアンG
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己墓地有昆虫族同名怪兽3只存在的场合，以那之内的任意数量为对象才能发动。这张卡从手卡特殊召唤。那之后，作为对象的怪兽当作装备卡使用给这张卡装备。
-- ②：把这张卡的效果装备的1张怪兽卡送去墓地才能发动。持有送去墓地的那张卡的攻击力以上的攻击力的对方场上的怪兽全部破坏。
function c77754169.initial_effect(c)
	-- ①：自己墓地有昆虫族同名怪兽3只存在的场合，以那之内的任意数量为对象才能发动。这张卡从手卡特殊召唤。那之后，作为对象的怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77754169,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,77754169)
	e1:SetTarget(c77754169.sptg)
	e1:SetOperation(c77754169.spop)
	c:RegisterEffect(e1)
	-- ②：把这张卡的效果装备的1张怪兽卡送去墓地才能发动。持有送去墓地的那张卡的攻击力以上的攻击力的对方场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77754169,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,77754170)
	e2:SetCost(c77754169.descost)
	e2:SetTarget(c77754169.destg)
	e2:SetOperation(c77754169.desop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中满足“是昆虫族、可以成为效果对象、可以放置在魔陷区，且墓地存在至少2张与其同名的其他卡”的卡片
function c77754169.eqfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsCanBeEffectTarget(e) and c:CheckUniqueOnField(tp)
		-- 检查自己墓地中是否存在至少2张与当前卡同名的其他卡（即加上当前卡共3张同名卡）
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,2,c,c:GetCode())
end
-- 检查选取的卡片组是否全部为同名怪兽
function c77754169.fselect(g)
	return g:GetClassCount(Card.GetCode)==1
end
-- 效果①的特殊召唤与装备效果的发动准备（检查并选择对象）
function c77754169.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地中所有符合条件的昆虫族同名怪兽
	local g=Duel.GetMatchingGroup(c77754169.eqfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 计算当前自己场上可用的魔法与陷阱区域空格数，且最大不超过3个
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_SZONE)),3)
	-- 检查发动条件：自己场上有怪兽区域空位，且有符合条件的对象可选择，且手牌的这张卡可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:CheckSubGroup(c77754169.fselect,1,ft)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	local sg=g:SelectSubGroup(tp,c77754169.fselect,false,1,ft)
	-- 将选取的卡片组设为效果处理的对象
	Duel.SetTargetCard(sg)
	-- 设置效果处理信息：涉及卡片离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,sg:GetCount(),0,0)
	-- 设置效果处理信息：特殊召唤手牌的这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的特殊召唤与装备效果的处理
function c77754169.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍存在于手牌，则将其以表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前自己场上可用的魔法与陷阱区域空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		-- 获取仍与效果关联的对象卡片组
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
		if ft<g:GetCount() then return end
		-- 中断效果处理，使后续的装备处理与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 遍历所有成功成为对象的卡片
		for tc in aux.Next(g) do
			-- 将对象怪兽作为装备卡装备给这张卡（分步进行）
			Duel.Equip(tp,tc,c,false,true)
			-- 当作装备卡使用给这张卡装备
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c77754169.eqlimit)
			tc:RegisterEffect(e1)
			tc:RegisterFlagEffect(77754169,RESET_EVENT+RESETS_STANDARD,0,1)
		end
		-- 完成装备卡装备流程，触发相关时点
		Duel.EquipComplete()
	end
end
-- 装备限制：只能装备给该效果的发动者（即这张卡）
function c77754169.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤由这张卡的效果装备的、可以送去墓地作为cost，且对方场上存在持有其攻击力以上攻击力怪兽的装备卡
function c77754169.tgfilter(c,tp)
	return c:GetFlagEffect(77754169)~=0 and c:IsAbleToGraveAsCost()
		-- 检查对方场上是否存在攻击力在送去墓地的装备卡攻击力以上的怪兽
		and Duel.IsExistingMatchingCard(c77754169.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetTextAttack())
end
-- 过滤对方场上表侧表示且攻击力在指定数值以上的怪兽
function c77754169.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackAbove(atk)
end
-- 效果②的发动代价处理（选择并送去墓地）
function c77754169.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipGroup():IsExists(c77754169.tgfilter,1,nil,tp) end
	-- 提示玩家选择要送去墓地的装备卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=e:GetHandler():GetEquipGroup():FilterSelect(tp,c77754169.tgfilter,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetTextAttack())
	-- 将选中的装备卡送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的破坏效果发动准备
function c77754169.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有攻击力在送去墓地的卡以上的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c77754169.desfilter,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	-- 设置效果处理信息：破坏符合条件的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果②的破坏效果处理
function c77754169.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取对方场上所有攻击力在送去墓地的卡以上的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c77754169.desfilter,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	-- 破坏所有符合条件的对方怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
