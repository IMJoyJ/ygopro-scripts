--ミラクル・エクスクルーダー
-- 效果：
-- 这个卡名在规则上也当作「元素英雄」卡使用。这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从卡组把1只「新空间侠」怪兽送去墓地才能发动。这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把有「元素英雄」怪兽的卡名记述的1张魔法·陷阱卡加入手卡。
-- ③：这张卡被送去墓地的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
local s,id,o=GetID()
-- 定义卡片的初始效果注册函数，依次为此卡注册效果①（手卡起动效果，送墓新空间侠为代价特殊召唤自身）、效果②（召唤·特殊召唤成功时检索记述元素英雄怪兽名的魔法陷阱）、效果③（被送去墓地时取对象除外对方墓地一张卡），并分别设置1回合1次的次数限制。
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，从卡组把1只「新空间侠」怪兽送去墓地才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把有「元素英雄」怪兽的卡名记述的1张魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"除外"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
end
-- 定义费用筛选函数：判定卡是否为新空间侠怪兽（0x1f系列），且可作为代价从卡组送去墓地。
function s.costfilter(c)
	return c:IsSetCard(0x1f) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 实现效果①的发动代价：从卡组选择1只满足costfilter的「新空间侠」怪兽送去墓地，作为特殊召唤此卡的代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段，确认自己的卡组中是否存在至少1张满足costfilter的「新空间侠」怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示发动者选择要送去墓地的卡，显示“请选择要送去墓地的卡”的选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让发动者从自己卡组中选择1张满足costfilter的「新空间侠」怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的「新空间侠」怪兽以代价（REASON_COST）形式送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果①的发动目标条件：自己主要怪兽区有空位，且此卡能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区域，只有存在空位时才能触发特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记效果①的处理信息：将这张卡本身作为将要特殊召唤的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理效果①：若此卡仍与当前连锁相关联，则将其从手卡特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 实际把此卡以表侧表示特殊召唤到发动者场上，sumtype为0表示通常特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义检索筛选函数：判定卡是否在卡面文本中记述了「元素英雄」怪兽（0x3008系列）卡名，且为魔法·陷阱卡并能够加入手卡。
function s.thfilter(c)
	-- 检查该魔法·陷阱卡是否在卡名或效果文本中记述了「元素英雄」系列怪兽，同时自身为魔法或陷阱卡。
	return aux.IsSetNameMonsterListed(c,0x3008) and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and c:IsAbleToHand()
end
-- 设置效果②的发动条件：自己卡组中存在满足thfilter的卡，并登记从卡组将1张卡加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动判定阶段，确认自己卡组中是否存在至少1张满足thfilter的魔法·陷阱卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记效果②的处理信息：效果处理时从自己卡组将1张符合条件的卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果②：从卡组选择1张满足条件的魔法·陷阱卡加入手卡，并向对方展示确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动者选择要加入手卡的卡，显示“请选择要加入手牌的卡”的选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动者从自己卡组中选择1张满足thfilter的魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法·陷阱卡加入其持有者的手卡（nil表示加入持有者手卡），处理原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对手玩家展示本次加入手卡的卡，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 设置效果③：以对方墓地1张卡为对象，判定该卡能否被除外；并登记除外操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地中是否存在至少1张可以被除外（满足IsAbleToRemove）的卡，作为发动条件。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示发动者选择要除外的卡，显示“请选择要除外的卡”的选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让发动者从对方墓地选择1张可除外的卡作为效果对象，并自动登记为该连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 登记效果③的处理信息：将选中的对象卡除外，归属于对方墓地，数量1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 处理效果③：若对象仍与当前连锁相关，且不受王家长眠之谷等效果的影响，则将其除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果③选择的对象卡（取对象时保存的第一张目标卡）。
	local tc=Duel.GetFirstTarget()
	-- 判定对象卡是否仍与当前效果连锁有联系（未离场或未失效），并且通过王家长眠之谷的抗性过滤。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将满足条件的对象卡以表侧表示除外，处理原因为效果（REASON_EFFECT）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
