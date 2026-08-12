--超弩級砲塔列車フライング・ランチャー
-- 效果：
-- 10星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。从卡组把1只机械族·地属性怪兽或1张「扫射特攻」加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只机械族怪兽召唤。
-- ③：把这张卡的超量素材任意数量取除，以那个数量的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果：登记卡名列表、添加超量召唤手续和特殊召唤限制，并注册三个效果——超量召唤成功时从卡组检索的①效果、增加机械族怪兽召唤次数的②永续效果、取除超量素材破坏场上魔法·陷阱卡的③起动效果。
function s.initial_effect(c)
	-- 登记这张卡上记载有「扫射特攻」（卡号51369889）的卡名，供其他效果检索或关联判断。
	aux.AddCodeList(c,51369889)
	-- 为这张卡添加超量召唤手续：用2只10星怪兽叠放进行超量召唤。
	aux.AddXyzProcedure(c,nil,10,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合才能发动。从卡组把1只机械族·地属性怪兽或1张「扫射特攻」加入手卡。（这个卡名的①的效果1回合只能使用1次）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只机械族怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"使用「超重型炮塔列车 冲天火箭炮」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 限定这个增加召唤次数的效果只适用于机械族怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_MACHINE))
	c:RegisterEffect(e2)
	-- ③：把这张卡的超量素材任意数量取除，以那个数量的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。（这个卡名的③的效果1回合只能使用1次）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"破坏效果"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：这张卡是超量召唤成功的场合。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 检索过滤器：是机械族·地属性怪兽或「扫射特攻」，并且可以加入手卡的卡。
function s.thfilter(c)
	return (c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) or c:IsCode(51369889)) and c:IsAbleToHand()
end
-- ①效果的目标处理：发动检测时确认卡组存在至少1张满足条件的可检索卡，并设置从卡组把1张卡加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：检查自己卡组是否存在至少1张满足条件的机械族·地属性怪兽或「扫射特攻」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时将从卡组把1张卡加入持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：提示玩家选择要加入手卡的卡，从卡组选择1只机械族·地属性怪兽或1张「扫射特攻」加入手卡，并向对方确认该卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示请选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1张满足条件的机械族·地属性怪兽或「扫射特攻」。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的代价处理：发动检测时确认至少能取除1个超量素材；统计双方场上可作为对象的魔法·陷阱卡数量，以此为上限取除任意数量（至少1个）的超量素材，并将实际取除数量记入标签。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 统计双方场上可以作为效果对象的魔法·陷阱卡的数量，作为可取除超量素材数量的上限。
	local rt=Duel.GetTargetCount(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	local ct=c:RemoveOverlayCard(tp,1,rt,REASON_COST)
	e:SetLabel(ct)
end
-- ③效果的目标处理：读取代价阶段取除的素材数量，确认场上存在可成为对象的魔法·陷阱卡，提示选择要破坏的卡，以与取除素材相同数量的场上魔法·陷阱卡为对象，并设置破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=e:GetLabel()
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 发动检测：确认双方场上存在至少1张可以成为这个效果对象的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 向玩家提示请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择双方场上与取除的超量素材相同数量的魔法·陷阱卡作为这个效果的对象。
	local tg=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置操作信息：效果处理时将破坏这ct张作为对象的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,ct,0,0)
end
-- ③效果的处理：取得与当前连锁关联的对象卡，过滤掉受「王家长眠之谷」影响的卡，将剩余的卡全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与当前连锁关联的效果对象卡，并过滤出不受「王家长眠之谷」影响的卡。
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if g:GetCount()>0 then
		-- 将这些作为对象的魔法·陷阱卡以效果原因破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
