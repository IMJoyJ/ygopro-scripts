--氷結界の虎将 ウェイン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方场上有怪兽存在，自己场上有「冰结界」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「冰结界」魔法·陷阱卡加入手卡。
-- ③：只要这张卡在怪兽区域存在，从场上送去对方墓地的魔法·陷阱卡不去墓地而除外。
function c81825063.initial_effect(c)
	-- ①：对方场上有怪兽存在，自己场上有「冰结界」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81825063,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,81825063)
	e1:SetCondition(c81825063.spcon)
	e1:SetTarget(c81825063.sptg)
	e1:SetOperation(c81825063.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「冰结界」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81825063,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,81825064)
	e2:SetTarget(c81825063.thtg)
	e2:SetOperation(c81825063.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：只要这张卡在怪兽区域存在，从场上送去对方墓地的魔法·陷阱卡不去墓地而除外。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(c81825063.rmtarget)
	e4:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e4:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e4)
end
-- 过滤条件：场上表侧表示的「冰结界」怪兽
function c81825063.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 效果①的发动条件：对方场上有怪兽存在，且自己场上有「冰结界」怪兽存在
function c81825063.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方怪兽区域的卡片数量是否大于0（对方场上有怪兽存在）
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张表侧表示的「冰结界」怪兽
		and Duel.IsExistingMatchingCard(c81825063.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的靶向处理：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c81825063.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示准备将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将自身从手卡特殊召唤到场上
function c81825063.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：卡组中可以加入手牌的「冰结界」魔法·陷阱卡
function c81825063.thfilter(c)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的靶向处理：检查卡组中是否存在可检索的「冰结界」魔陷，并设置检索的操作信息
function c81825063.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查卡组中是否存在满足条件的「冰结界」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c81825063.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手牌的操作信息，表示准备从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组选择1张「冰结界」魔法·陷阱卡加入手牌并给对方确认
function c81825063.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「冰结界」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c81825063.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果③的过滤条件：原本卡片类型为魔法·陷阱卡，且持有者为对方玩家的卡片
function c81825063.rmtarget(e,c)
	return c:GetOriginalType()&(TYPE_SPELL+TYPE_TRAP)~=0 and c:GetOwner()~=e:GetHandlerPlayer()
end
