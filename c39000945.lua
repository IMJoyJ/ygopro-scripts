--エンプレス・オブ・エンディミオン
-- 效果：
-- ←2 【灵摆】 2→
-- ①：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：把这张卡3个魔力指示物取除才能发动。手卡1只可以放置魔力指示物的怪兽和灵摆区域的这张卡特殊召唤，给那2只各放置1个魔力指示物。
-- 【怪兽效果】
-- 自己对「恩底弥翁的皇后」1回合只能有1次特殊召唤。
-- ①：这张卡特殊召唤成功的场合，以自己场上1张其他的有魔力指示物放置的卡和对方场上1张卡为对象才能发动。那些自己以及对方的卡回到持有者手卡。那之后，从自己场上回到手卡的卡放置的数量的魔力指示物给这张卡放置。
-- ②：有魔力指示物放置的这张卡被战斗破坏时才能发动。从卡组把1张「恩底弥翁」卡加入手卡。
function c39000945.initial_effect(c)
	c:EnableCounterPermit(0x1,LOCATION_PZONE+LOCATION_MZONE)
	-- 为这张卡赋予灵摆怪兽属性，使其可以进行灵摆召唤以及作为灵摆卡在灵摆区域发动
	aux.EnablePendulumAttribute(c)
	c:SetSPSummonOnce(39000945)
	-- ←2 【灵摆】 2→　①：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（注册连锁发生时的在场记录效果）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_PZONE)
	-- 在效果发动的连锁发生时记录这张卡在场上存在，作为之后给这张卡放置魔力指示物的判定依据
	e1:SetOperation(aux.chainreg)
	c:RegisterEffect(e1)
	-- ①：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetOperation(c39000945.counterop)
	c:RegisterEffect(e2)
	-- ②：把这张卡3个魔力指示物取除才能发动。手卡1只可以放置魔力指示物的怪兽和灵摆区域的这张卡特殊召唤，给那2只各放置1个魔力指示物
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39000945,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCost(c39000945.spcost)
	e3:SetTarget(c39000945.sptg)
	e3:SetOperation(c39000945.spop)
	c:RegisterEffect(e3)
	-- ①：这张卡特殊召唤成功的场合，以自己场上1张其他的有魔力指示物放置的卡和对方场上1张卡为对象才能发动。那些自己以及对方的卡回到持有者手卡。那之后，从自己场上回到手卡的卡放置的数量的魔力指示物给这张卡放置
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(39000945,1))  --"回到手卡并放置指示物"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetTarget(c39000945.rthtg)
	e4:SetOperation(c39000945.rthop)
	c:RegisterEffect(e4)
	-- ②：有魔力指示物放置的这张卡被战斗破坏时才能发动。从卡组把1张「恩底弥翁」卡加入手卡
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(39000945,2))  --"从卡组加入手卡"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_DESTROYED)
	e5:SetCondition(c39000945.thcon)
	e5:SetTarget(c39000945.thtg)
	e5:SetOperation(c39000945.thop)
	c:RegisterEffect(e5)
	-- ②：有魔力指示物放置的这张卡被战斗破坏时才能发动（在这张卡离场前记录其魔力指示物数量，作为②效果发动条件的判定依据）
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_LEAVE_FIELD_P)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetOperation(c39000945.regop)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
c39000945.mentioned_counter={
	[0x1]=true,
}
-- 连锁处理结束时，若该连锁处理的是魔法卡的发动且这张卡当时在场，则给这张卡放置1个魔力指示物
function c39000945.counterop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 发动代价：取除这张卡的3个魔力指示物
function c39000945.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 手卡特殊召唤对象的过滤条件：可以放置魔力指示物、可以实际对其放置1个魔力指示物且可以特殊召唤的怪兽
function c39000945.spfilter(c,e,tp)
	-- 判定该卡能否放置魔力指示物、能否实际添加1个魔力指示物，并满足以这个效果特殊召唤的条件
	return c:IsCanHaveCounter(0x1) and Duel.IsCanAddCounter(tp,0x1,1,c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件检测：自己怪兽区有2个以上可用空格、未受「青眼精灵龙」禁止同时特殊召唤2只以上的效果影响、灵摆区域的这张卡可以特殊召唤并能放置指示物，且手卡存在满足条件的怪兽
function c39000945.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认灵摆区域的这张卡自身可以特殊召唤，且可以对其放置1个魔力指示物
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsCanAddCounter(tp,0x1,1,c)
		-- 确认手卡存在至少1只满足过滤条件的可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c39000945.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：预计特殊召唤2张卡（灵摆区域的这张卡和手卡的1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,LOCATION_HAND)
end
-- 效果处理：从手卡选择1只符合条件的怪兽，与灵摆区域的这张卡一起特殊召唤，并给那2只各放置1个魔力指示物
function c39000945.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只可以放置魔力指示物且可以特殊召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,c39000945.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		g:AddCard(c)
		-- 将选择的怪兽和这张卡一起以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 遍历特殊召唤成功的卡片组中的每张卡
		for tc in aux.Next(g) do
			tc:AddCounter(0x1,1)
		end
	end
end
-- 回手对象的过滤条件：可以回到手卡且有魔力指示物放置的卡
function c39000945.rthfilter(c)
	return c:IsAbleToHand() and c:GetCounter(0x1)>0
end
-- 取对象条件检测：自己场上存在这张卡以外的有魔力指示物放置且可回手的卡，且对方场上存在可以回到手卡的卡
function c39000945.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在这张卡以外的有魔力指示物放置且可以回到手卡的卡
	if chk==0 then return Duel.IsExistingTarget(c39000945.rthfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 检查对方场上是否存在可以回到手卡的卡
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要回到手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1张其他的有魔力指示物放置的卡作为效果对象
	local g1=Duel.SelectTarget(tp,c39000945.rthfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 向玩家提示选择要回到手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张可以回到手卡的卡作为效果对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁操作信息：将作为对象的2张卡回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,g1:GetCount(),0,LOCATION_ONFIELD)
end
-- 效果处理：先记录自己方对象卡上的魔力指示物数量，将2张对象卡回到持有者手卡，那之后按从自己场上回到手卡的卡放置的数量的魔力指示物给这张卡放置
function c39000945.rthop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	local ctable={}
	-- 遍历对象卡，记录其中自己控制的卡上放置的魔力指示物数量
	for tc in aux.Next(g) do
		if tc:IsControler(tp) then
			ctable[tc]=tc:GetCounter(0x1)
		end
	end
	-- 将作为对象的卡回到各自持有者的手卡
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 获取刚才实际被送回手卡的卡片组
	local og=Duel.GetOperatedGroup()
	local ct=0
	for tc,num in pairs(ctable) do
		if og:IsContains(tc) and tc:IsLocation(LOCATION_HAND) then
			ct=ct+num
		end
	end
	if ct>0 then
		-- 中断当前效果处理，使之后放置魔力指示物的处理视为不同时处理
		Duel.BreakEffect()
		e:GetHandler():AddCounter(0x1,ct)
	end
end
-- 发动条件：这张卡离场时有魔力指示物放置（离场前记录的指示物数量大于0）
function c39000945.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()>0
end
-- 卡组检索的过滤条件：「恩底弥翁」卡且可以加入手卡
function c39000945.thfilter(c)
	return c:IsSetCard(0x12a) and c:IsAbleToHand()
end
-- 发动条件检测：卡组存在可以加入手卡的「恩底弥翁」卡，并设置从卡组加入手卡的操作信息
function c39000945.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张可以加入手卡的「恩底弥翁」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c39000945.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：预计从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张「恩底弥翁」卡加入手卡，并向对方展示确认
function c39000945.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张可以加入手卡的「恩底弥翁」卡
	local g=Duel.SelectMatchingCard(tp,c39000945.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 这张卡离场前，把其放置的魔力指示物数量记录到被战斗破坏时触发的效果上，作为「有魔力指示物放置」条件的判定依据
function c39000945.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(e:GetHandler():GetCounter(0x1))
end
