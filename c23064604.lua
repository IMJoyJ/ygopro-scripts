--冥帝エレボス
-- 效果：
-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。
-- ①：这张卡上级召唤的场合才能发动。从手卡·卡组把「帝王」魔法·陷阱卡2种类各1张送去墓地，从对方的手卡·场上·墓地让1张卡回到卡组（从手卡是随机选）。
-- ②：这张卡在墓地存在的场合，1回合1次，自己·对方的主要阶段，从手卡丢弃1张「帝王」魔法·陷阱卡，以自己墓地1只攻击力2400以上而守备力1000的怪兽为对象才能发动。那只怪兽加入手卡。
function c23064604.initial_effect(c)
	-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23064604,0))  --"把1只上级召唤的怪兽解放作上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c23064604.otcon)
	e1:SetOperation(c23064604.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ①：这张卡上级召唤的场合才能发动。从手卡·卡组把「帝王」魔法·陷阱卡2种类各1张送去墓地，从对方的手卡·场上·墓地让1张卡回到卡组（从手卡是随机选）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23064604,1))  --"从手卡·卡组把「帝王」魔法·陷阱卡2种类送去墓地，从对方的手卡·场上·墓地之中选1张卡回到卡组"
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c23064604.tdcon)
	e3:SetTarget(c23064604.tdtg)
	e3:SetOperation(c23064604.tdop)
	c:RegisterEffect(e3)
	-- ②：这张卡在墓地存在的场合，1回合1次，自己·对方的主要阶段，从手卡丢弃1张「帝王」魔法·陷阱卡，以自己墓地1只攻击力2400以上而守备力1000的怪兽为对象才能发动。那只怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(23064604,2))  --"以自己墓地1只攻击力2400以上而守备力1000的怪兽为对象才能发动。那只怪兽加入手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1)
	e4:SetCondition(c23064604.thcon)
	e4:SetCost(c23064604.thcost)
	e4:SetTarget(c23064604.thtg)
	e4:SetOperation(c23064604.thop)
	c:RegisterEffect(e4)
end
-- 过滤场上以表侧表示存在的上级召唤过的怪兽，用于作为这张卡上级召唤时可解放的祭品候选。
function c23064604.otfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 召唤规则效果的发动条件：这张卡为7星以上，且所需解放数量不超过1只；同时在场上存在至少1只上级召唤过的怪兽可用作祭品。
function c23064604.otcon(e,c,minc)
	if c==nil then return true end
	-- 取得双方怪兽区中所有上级召唤过的怪兽，作为可供选择的祭品集合。
	local mg=Duel.GetMatchingGroup(c23064604.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 确认这张卡的等级不低于7、召唤所需祭品数不超过1，并且场上存在足以作为1只祭品的上级召唤怪兽。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 召唤规则效果的处理：从祭品候选中选择1只上级召唤过的怪兽解放，完成这张卡的上级召唤。
function c23064604.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 再次取得场上所有上级召唤过的怪兽，作为本次上级召唤的祭品候选集合。
	local mg=Duel.GetMatchingGroup(c23064604.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 让玩家从祭品候选中选择1只怪兽作为这次上级召唤的祭品。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选择的怪兽解放，解放原因记为上级召唤的素材（召唤解放）。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 效果发动条件：这张卡是上级召唤成功时才能发动。
function c23064604.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 筛选从手卡·卡组送去墓地所需的卡：卡名含有「帝王」字段的魔法·陷阱卡，且能够被送去墓地。
function c23064604.tgfilter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- 效果发动时点与合法性的判定：我方手卡·卡组中至少存在2种类「帝王」魔法·陷阱卡可供送去墓地，并且对方手卡·场上·墓地存在至少1张能回到卡组的卡；同时登记本效果会送去墓地2张卡、使对方1张卡回到卡组。
function c23064604.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 取得我方手卡·卡组中所有满足条件的「帝王」魔法·陷阱卡，用于后续选择送去墓地的2张卡。
		local g=Duel.GetMatchingGroup(c23064604.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>1
			-- 确认对方手卡、场上或墓地中至少存在1张可以被送回卡组的卡，以满足“从对方的手卡·场上·墓地让1张卡回到卡组”的条件。
			and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
	end
	-- 登记本次连锁的处理信息：将2张卡送去墓地，来源为我方卡组（后续用于触发相关卡片的判定）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
	-- 登记本次连锁的处理信息：将1张卡回到卡组，来源为对方手卡·场上·墓地。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果处理：先选择2种类「帝王」魔法·陷阱卡送去墓地，若成功送去墓地则再从此前确定的对方手卡·场上·墓地中根据玩家选择将1张卡随机或指定地回到卡组。
function c23064604.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前手卡·卡组中满足送去墓地条件的「帝王」魔法·陷阱卡集合，若种类不足2则直接结束处理。
	local g=Duel.GetMatchingGroup(c23064604.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从符合条件的卡中选择2张卡名互不相同的「帝王」魔法·陷阱卡送去墓地。
	local tg1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 若这2张卡实际被效果送去墓地，并且其中至少2张卡已在墓地，则继续执行让对方1张卡回到卡组的处理。
	if Duel.SendtoGrave(tg1,REASON_EFFECT)~=0 and tg1:IsExists(Card.IsLocation,2,nil,LOCATION_GRAVE) then
		local sg=nil
		-- 取得对方手卡中所有可以回到卡组的卡，用于随机选对方手卡1张时使用。
		local hg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_HAND,nil)
		-- 检查对方手卡是否存在至少1张可回到卡组的卡。
		local b1=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil)
		-- 检查对方场上是否存在至少1张可回到卡组的卡。
		local b2=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查对方墓地是否存在至少1张可回到卡组的卡。
		local b3=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil)
		local op=0
		if not b1 and not b2 and not b3 then return end
		if b1 then
			if b2 and b3 then
				-- 当对方手卡、场上、墓地都存在可回卡组的卡时，让玩家选择要从哪个区域选1张卡回卡组。
				op=Duel.SelectOption(tp,aux.Stringid(23064604,3),aux.Stringid(23064604,4),aux.Stringid(23064604,5))  --"选对方的1张手卡回到卡组/选对方场上的1张卡回到卡组/选对方墓地的1张卡回到卡组"
			elseif b2 and not b3 then
				-- 当对方手卡和场上存在可回卡组的卡而墓地没有时，让玩家选择回卡组的是对方手卡还是对方场上的卡。
				op=Duel.SelectOption(tp,aux.Stringid(23064604,3),aux.Stringid(23064604,4))  --"选对方的1张手卡回到卡组/选对方场上的1张卡回到卡组"
			elseif not b2 and b3 then
				-- 当对方手卡和墓地存在可回卡组的卡而场上没有时，让玩家选择回卡组的是对方手卡还是对方墓地的卡，并把选项序号转换为区域编号。
				op=Duel.SelectOption(tp,aux.Stringid(23064604,3),aux.Stringid(23064604,5))  --"选对方的1张手卡回到卡组/选对方墓地的1张卡回到卡组"
				if op==1 then op=2 end
			else
				op=0
			end
		else
			if b2 and b3 then
				-- 当对方手卡不存在可回卡组的卡而场上和墓地都有时，让玩家从“场上”或“墓地”中选择回卡组的区域，并转为内部区域编号。
				op=Duel.SelectOption(tp,aux.Stringid(23064604,4),aux.Stringid(23064604,5))+1  --"选对方场上的1张卡回到卡组/选对方墓地的1张卡回到卡组"
			elseif b2 and not b3 then
				op=1
			else
				op=2
			end
		end
		if op==0 then
			sg=hg:RandomSelect(tp,1)
		elseif op==1 then
			-- 提示玩家选择要返回卡组的卡（场上或墓地路线）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			-- 从对方场上选择1张可以回到卡组的卡。
			sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
			-- 手动展示被选为对象的卡片动画，并记录选择。
			Duel.HintSelection(sg)
		else
			-- 提示玩家选择要返回卡组的卡（墓地路线）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			-- 从对方墓地选择1张可以回到卡组的卡。
			sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
			-- 手动展示被选为对象的卡片动画，并记录选择。
			Duel.HintSelection(sg)
		end
		-- 把选出的对方卡片送回持有者卡组并洗切卡组。
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 效果②的发动条件：仅在自己·对方的主要阶段可以发动。
function c23064604.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否为主要阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 筛选丢弃用的「帝王」魔法·陷阱卡：卡名含有「帝王」字段的魔法·陷阱卡且可以丢弃。
function c23064604.cfilter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable()
end
-- 效果②的代价处理：从手卡丢弃1张「帝王」魔法·陷阱卡作为发动代价。
function c23064604.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前确认手卡中是否存在至少1张满足丢弃条件的「帝王」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c23064604.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际从手卡选择1张「帝王」魔法·陷阱卡丢弃，视为发动代价。
	Duel.DiscardHand(tp,c23064604.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选对象怪兽：攻击力2400以上、守备力1000、且可以加入手卡的自己墓地怪兽。
function c23064604.thfilter(c)
	return c:IsAttackAbove(2400) and c:IsDefense(1000) and c:IsAbleToHand()
end
-- 效果②的取对象判定：以自己墓地1只攻击力2400以上、守备力1000的怪兽为对象，并登记将对象加入手卡的处理信息。
function c23064604.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c23064604.thfilter(chkc) end
	-- 确认自己墓地是否存在至少1只满足攻击力2400以上、守备力1000且能加入手卡的怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c23064604.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手卡的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1只符合条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c23064604.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次连锁的操作信息：将1张对象卡加入持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②处理：对象卡仍然与效果相关联时，将对象怪兽加入手卡。
function c23064604.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果①发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果原因加入其持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
