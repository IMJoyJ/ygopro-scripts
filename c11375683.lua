--ティンダングル・トリニティ
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡反转的场合才能发动。从卡组把1只「廷达魔三角之底边守卫者」特殊召唤。
-- ②：只要反转过的这张卡在怪兽区域存在，自己的「廷达魔三角」怪兽不会被战斗破坏。
-- ③：这张卡作为「廷达魔三角」连接怪兽的连接素材送去墓地的场合才能发动。从卡组把1张「热尔岗终焉」加入手卡，从卡组把1张魔法·陷阱卡送去墓地。
function c11375683.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从卡组把1只「廷达魔三角之底边守卫者」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11375683,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c11375683.sptg)
	e1:SetOperation(c11375683.spop)
	c:RegisterEffect(e1)
	-- ②：只要反转过的这张卡在怪兽区域存在，
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c11375683.flipop)
	c:RegisterEffect(e2)
	-- 自己的「廷达魔三角」怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置该效果的作用对象为我方场上“廷达魔三角”系列怪兽（字段0x10b），只有这些怪兽享受②的不被战斗破坏效果。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x10b))
	e3:SetCondition(c11375683.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡作为「廷达魔三角」连接怪兽的连接素材送去墓地的场合才能发动。从卡组把1张「热尔岗终焉」加入手卡，从卡组把1张魔法·陷阱卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(11375683,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCountLimit(1,11375683)
	e4:SetCondition(c11375683.thcon)
	e4:SetTarget(c11375683.thtg)
	e4:SetOperation(c11375683.thop)
	c:RegisterEffect(e4)
end
-- 定义“廷达魔三角之底边守卫者”的特殊召唤检索过滤函数：卡名必须是94365540，且能够被效果特殊召唤。
function c11375683.spfilter(c,e,tp)
	return c:IsCode(94365540) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件：自己主要怪兽区有空位，且卡组中存在满足spfilter的“廷达魔三角之底边守卫者”。
function c11375683.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查自己主要怪兽区域是否有空位（没有空位则不能发动）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且检查卡组中是否存在满足spfilter的“廷达魔三角之底边守卫者”（存在才可发动）。
		and Duel.IsExistingMatchingCard(c11375683.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次效果的操作信息：包含从卡组特殊召唤1只怪兽（具体对象在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：若主怪兽区仍有空位，从卡组选1只“廷达魔三角之底边守卫者”表侧攻击表示特殊召唤。
function c11375683.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主怪兽区有空位，若无空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从卡组中获取第一张满足spfilter条件的卡（“廷达魔三角之底边守卫者”）。
	local tc=Duel.GetFirstMatchingCard(c11375683.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 将选中的“廷达魔三角之底边守卫者”以表侧攻击表示特殊召唤到当前玩家场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 反转时要给这张卡打上“已反转”标记，用于②效果判断；该标记在卡离开/重置标准场合时清除。
function c11375683.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(11375683,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- ②效果的适用条件：这张卡带有“已反转”标记（即曾经反转成功过）时才适用。
function c11375683.indcon(e)
	return e:GetHandler():GetFlagEffect(11375683)~=0
end
-- ③效果的发动条件：这张卡作为连接素材被送去墓地时，且那次连接素材的怪兽是“廷达魔三角”连接怪兽（REASON_LINK且原因怪兽含字段0x10b）。
function c11375683.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0x10b)
end
-- 定义“加入手卡对象”的过滤条件：是“热尔岗终焉”（59490397）、能加入手卡，且卡组中还有可送去墓地的魔陷。
function c11375683.thfilter(c,tp)
	return c:IsCode(59490397) and c:IsAbleToHand()
		-- 同时要求卡组中除“热尔岗终焉”外还存在至少1张可送去墓地的魔法·陷阱卡，保证检索和堆墓都能处理。
		and Duel.IsExistingMatchingCard(c11375683.tgfilter,tp,LOCATION_DECK,0,1,c)
end
-- 定义“送去墓地对象”的过滤条件：是魔法卡或陷阱卡，且能够被效果送去墓地。
function c11375683.tgfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- ③效果的发动条件和操作信息：卡组中存在满足thfilter的“热尔岗终焉”时才能发动；并设置从卡组加入手卡1张、从卡组送去墓地1张的操作信息。
function c11375683.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查卡组中是否存在满足thfilter的“热尔岗终焉”（存在才可发动）。
	if chk==0 then return Duel.IsExistingMatchingCard(c11375683.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置本次效果的操作信息：包含从卡组把1张卡加入手卡（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置本次效果的操作信息：包含从卡组把1张卡送去墓地（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：先选择1张“热尔岗终焉”加入手卡并给对方确认；若成功加入手卡，再从卡组选1张魔法·陷阱卡送去墓地。
function c11375683.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家显示选择提示，要求选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从卡组选出1张满足thfilter的“热尔岗终焉”（同时保证后续有可堆墓的魔陷）。
	local hg=Duel.SelectMatchingCard(tp,c11375683.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	-- 如果成功选到卡且该卡成功加入手卡，则继续执行堆墓部分。
	if hg:GetCount()>0 and Duel.SendtoHand(hg,tp,REASON_EFFECT)>0
		and hg:GetFirst():IsLocation(LOCATION_HAND) then
		-- 将检索加入手卡的“热尔岗终焉”展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,hg)
		-- 向当前玩家显示选择提示，要求选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让当前玩家从卡组选出1张满足tgfilter的魔法·陷阱卡。
		local g=Duel.SelectMatchingCard(tp,c11375683.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的魔法·陷阱卡以效果原因送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
