--星遺物－『星冠』
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，③的效果1回合只能使用1次。
-- ①：这张卡可以从手卡往作为连接怪兽所连接区的自己场上守备表示特殊召唤。
-- ②：从额外卡组特殊召唤的场上的怪兽的效果发动时，把这张卡解放才能发动。那个发动无效并破坏。
-- ③：通常召唤的这张卡被解放的场合才能发动。从卡组把1张「星遗物」魔法·陷阱卡加入手卡。
function c27918365.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以从手卡往作为连接怪兽所连接区的自己场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27918365,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCountLimit(1,27918365+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c27918365.spcon)
	e1:SetValue(c27918365.spval)
	c:RegisterEffect(e1)
	-- ②：从额外卡组特殊召唤的场上的怪兽的效果发动时，把这张卡解放才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27918365,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c27918365.negcon)
	e2:SetCost(c27918365.negcost)
	e2:SetTarget(c27918365.negtg)
	e2:SetOperation(c27918365.negop)
	c:RegisterEffect(e2)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次，③的效果1回合只能使用1次。③：通常召唤的这张卡被解放的场合才能发动。从卡组把1张「星遗物」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27918365,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_RELEASE)
	e3:SetCountLimit(1,27918366)
	e3:SetCondition(c27918365.thcon)
	e3:SetTarget(c27918365.thtg)
	e3:SetOperation(c27918365.thop)
	c:RegisterEffect(e3)
end
-- 特殊召唤条件判定：当c为空时视为满足；否则确认自己场上存在可用的连接怪兽所连接区（主怪兽区空格）以从手卡守备特殊召唤。
function c27918365.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家场上所有连接怪兽所指向的连接区域（额外怪兽区或主要怪兽区），作为可特殊召唤到的位置。
	local zone=Duel.GetLinkedZone(tp)
	-- 判断在可用的连接区域中是否存在空位（主怪兽区空格），若存在则满足特殊召唤条件。
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 设置该特殊召唤规则的参数：返回0和连接区域，表示以此规则特殊召唤时可使用的区域为连接区，召唤表示形式由TargetRange设置。
function c27918365.spval(e,c)
	-- 返回0和当前控制者的连接区，指定本次特殊召唤只能选择这些区域进行，且不额外改变玩家。
	return 0,Duel.GetLinkedZone(c:GetControler())
end
-- ②的发动条件：此卡不是战斗破坏状态，且发动连锁的效果是场上怪兽的效果，该怪兽是从额外卡组特殊召唤的，效果发动位置在主要怪兽区，且该连锁可以被无效。
function c27918365.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这个连锁（ev）发生的位置，用于判断怪兽效果是否在场上发动。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSummonLocation(LOCATION_EXTRA) and loc==LOCATION_MZONE
		-- 追加确认该连锁是可以被无效的（满足无效发动的前提）。
		and Duel.IsChainNegatable(ev)
end
-- ②的发动代价：确认此卡可以被解放；若可以则解放此卡作为cost。
function c27918365.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放此卡，作为发动②效果的cost；此解放不因效果无效而取消。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ②的发动对象设定：将当前连锁（正在发动的怪兽效果）设为要无效的对象；若对象卡存在且可被破坏，则同时设定为要破坏的对象。
function c27918365.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本次效果处理要无效的是当前连锁的事件eg，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 追加登记操作信息：本次效果处理要破坏的是eg（发动的怪兽），数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②的效果处理：成功无效该发动后，如果那只怪兽仍与该效果关联，则将其破坏。
function c27918365.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断无效发动是否成功，并确认发动效果的那只怪兽仍然存在于场上且与效果关联（未被连锁离场/失去关系）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将eg中的怪兽破坏，破坏原因是效果。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 检索过滤器：符合条件的卡必须是「星遗物」字段的魔法·陷阱卡，且能够加入手卡。
function c27918365.thfilter(c)
	return c:IsSetCard(0xfe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ③的发动条件：被解放的这张卡是通过通常召唤上场过的怪兽（不是特殊召唤或覆盖）。
function c27918365.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- ③的发动目标：从卡组中选择1张符合条件的「星遗物」魔法·陷阱卡加入手卡；设置操作信息。
function c27918365.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中必须至少存在1张符合过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c27918365.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果处理会将1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③的效果处理：从卡组挑选1张符合条件的「星遗物」魔法·陷阱卡加入手卡，并向对方展示。
function c27918365.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息，让玩家选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从自己卡组中选出1张符合过滤条件的卡，返回选中的卡片组g。
	local g=Duel.SelectMatchingCard(tp,c27918365.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入其持有者手卡，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
