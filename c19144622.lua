--妖精伝姫－マチリル
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：场上有原本攻击力是1850的魔法师族怪兽存在的场合才能发动。这张卡从手卡·墓地特殊召唤。这个回合，自己不是魔法师族怪兽不能特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「妖精传姬」魔法·陷阱卡或「妖精的传姬」加入手卡。
-- ③：支付500基本分才能发动。对方场上1只效果怪兽的卡名当作「妖精王子」使用。
local s,id,o=GetID()
-- 注册该卡的全部效果：①场上存在原本攻击力1850的魔法师族怪兽时从手卡·墓地特殊召唤并附加本回合只能特殊召唤魔法师族的自肃；②召唤·特殊召唤成功时从卡组将1张「妖精传姬」魔法·陷阱卡或「妖精的传姬」加入手牌；③支付500LP将对方场上1只效果怪兽的卡名视为「妖精王子」。
function s.initial_effect(c)
	-- 将该卡效果文本中提到的「妖精的传姬」（91957038）和「妖精王子」（19144623）登记为引用卡名，供规则判定使用。
	aux.AddCodeList(c,91957038,19144623)
	-- ①：场上有原本攻击力是1850的魔法师族怪兽存在的场合才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「妖精传姬」魔法·陷阱卡或「妖精的传姬」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：支付500基本分才能发动。对方场上1只效果怪兽的卡名当作「妖精王子」使用。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"改变卡名"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCost(s.codecost)
	e4:SetTarget(s.codetg)
	e4:SetOperation(s.codeop)
	c:RegisterEffect(e4)
end
-- 过滤条件：表侧表示且原本攻击力为1850的魔法师族怪兽。
function s.cfilter(c)
	return c:GetBaseAttack()==1850 and c:IsRace(RACE_SPELLCASTER) and c:IsFaceup()
end
-- ①效果的发动条件：双方场上存在至少1只原本攻击力1850且表侧表示的魔法师族怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测场上是否存在满足s.cfilter条件的魔法师族怪兽，作为①效果的发动前提。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ①效果发动时的合法性检查：确认自己场上有可用的怪兽区域，且这张卡能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己主要怪兽区是否有空位，供这张卡特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁将进行特殊召唤操作，对象为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：在满足连锁关联且不受王家长眠之谷影响时将这张卡表侧表示特殊召唤；随后给本方附加直到结束阶段不能特殊召唤魔法师族以外怪兽的自肃效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍与发动连锁有关，且不会被王家长眠之谷无效其特殊召唤。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不是魔法师族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤魔法师族以外怪兽的自肃效果注册到当前玩家（tp）身上，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定：若被特殊召唤的怪兽不是魔法师族，则禁止该特殊召唤。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_SPELLCASTER)
end
-- 检索过滤条件：卡名是「妖精的传姬」（91957038），或者是「妖精传姬」字段的魔法·陷阱卡，并且可以被加入手牌。
function s.thfilter(c)
	return (c:IsCode(91957038) or c:IsSetCard(0x1db) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToHand()
end
-- ②效果的发动条件与信息登记：检查卡组存在符合条件的检索目标，并设置将卡片加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足s.thfilter的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将把卡组中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从自己卡组选择1张符合条件的卡加入手牌，并向对方展示确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示‘请选择要加入手牌的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中筛选并选择1张满足s.thfilter的卡作为加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入其持有者手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的代价：检查能否支付500基本分，并实际支付500LP。
function s.codecost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能够支付500基本分作为发动代价。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分，完成③效果的发动代价。
	Duel.PayLPCost(tp,500)
end
-- 选择对象的过滤条件：对方场上的表侧表示效果怪兽，且卡名不是「妖精王子」。
function s.codefilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsCode(19144623)
end
-- ③效果的目标判定：获取对方场上符合条件的表侧表示效果怪兽集合，若存在则可发动。
function s.codetg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有符合s.codefilter条件的表侧表示效果怪兽。
	local g=Duel.GetMatchingGroup(s.codefilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
end
-- ③效果处理：选择对方场上1只效果怪兽，将其卡名变更为「妖精王子」，持续到其离开场上或重置。
function s.codeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示‘请选择表侧表示的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方场上选择1只符合条件的表侧表示效果怪兽作为改卡名对象。
	local g=Duel.SelectMatchingCard(tp,s.codefilter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 播放选中对象的动画，并将其标记为本效果的对象。
		Duel.HintSelection(g)
		-- 对方场上1只效果怪兽的卡名当作「妖精王子」使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(19144623)
		tc:RegisterEffect(e1)
	end
end
