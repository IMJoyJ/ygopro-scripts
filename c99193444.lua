--轟海皇 ポセイドラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·场上（表侧表示）把1只其他的水属性怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合，从卡组把1只「海皇」怪兽或「水精鳞」怪兽送去墓地，以对方场上1张卡为对象才能发动。那张卡回到手卡。
-- ③：只要自己场上有「轰海皇 波塞德拉」以外的怪兽存在，对方怪兽不能选择这张卡作为攻击对象。
local s,id,o=GetID()
-- 注册全部效果：e1为①起动效果，以手牌/场上表侧表示的其他水属性怪兽为COST特招自己；e2/e3为②诱发选发效果，召唤/特殊召唤成功时，从卡组送墓「海皇」或「水精鳞」怪兽并取对象将对方场上1张卡返回手牌；e4为③永续效果，有其他怪兽存在时对方怪兽不能选择此卡为攻击对象。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从自己的手卡·场上（表侧表示）把1只其他的水属性怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡召唤·特殊召唤的场合，从卡组把1只「海皇」怪兽或「水精鳞」怪兽送去墓地，以对方场上1张卡为对象才能发动。那张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：只要自己场上有「轰海皇 波塞德拉」以外的怪兽存在，对方怪兽不能选择这张卡作为攻击对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.atcon)
	-- 设置效果的值为aux.imval1，表示对方怪兽不能选择此卡为攻击对象；如果对方怪兽免疫此效果，则不受限制。
	e4:SetValue(aux.imval1)
	c:RegisterEffect(e4)
end
-- ①效果的COST过滤：从手卡或场上表侧表示的水属性怪兽中选择可作为COST送去墓地，并确认送墓后仍有空余的怪兽区域用于特殊召唤。
function s.costfilter(c,tp)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_WATER)
		-- 限定该水属性怪兽能被当作COST送去墓地，且送墓后自己场上的可用怪兽区数量大于0（为后续特殊召唤做准备）。
		and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- ①效果支付COST：先检查是否存在符合条件的怪兽；若有，让玩家选择1张手卡或场上表侧表示的水属性怪兽并送去墓地作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足COST条件：从手卡·场上表侧表示中存在1张除自身外可送去墓地的水属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,e:GetHandler(),tp) end
	-- 给玩家显示‘请选择要送去墓地的卡’的提示信息，并缓存用于选择卡片时的显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡和怪兽区域选择1张满足costfilter的水属性怪兽作为COST，不能选择将要特殊召唤的这张卡自身。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,e:GetHandler(),tp)
	-- 将玩家选择的水属性怪兽作为发动COST送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果的目标/发动条件：确认这张卡可以进行特殊召唤，并将特招操作登记到当前连锁的处理信息中。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 记录本次效果处理包含‘特殊召唤’分类，目标为这张卡，数量1，供其他卡连锁时判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍然在手牌且与效果相关，则把它特殊召唤；否则不处理。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上（不检查召唤条件/苏生限制，无特殊召唤类型）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的COST过滤：从卡组中选择1只「海皇」或「水精鳞」怪兽且能够作为COST送入墓地。
function s.dcfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsSetCard(0x77,0x74)
		and c:IsType(TYPE_MONSTER)
end
-- ②效果支付COST：从卡组选择1只「海皇」或「水精鳞」怪兽送去墓地作为发动代价；先检查是否存在符合条件的卡。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在1只可作为COST送去墓地的「海皇」或「水精鳞」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.dcfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 给玩家显示‘请选择要送去墓地的卡’的提示信息，用于选择卡组中的怪兽作为COST。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只满足dcfilter的「海皇」或「水精鳞」怪兽送入墓地作为COST。
	local g=Duel.SelectMatchingCard(tp,s.dcfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选出的卡从卡组送去墓地作为发动COST。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果的目标：选择对方场上1张能够返回手牌的卡作为对象；在连锁中校验对象合法性，并设置回手牌的处理信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查对方场上是否存在1张可作为效果对象并能够返回手牌的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示‘请选择要返回手牌的卡’的提示信息，用于选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张能返回手牌的卡，并将其设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 记录本次处理包含‘返回手牌’分类，目标为选择的那张卡，供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：获取对象卡，若它仍与该效果相关，则将其返回持有者手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第1个对象卡（即②效果选择返回手牌的那张卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡返回其持有者手牌（原因：效果）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ③条件过滤：匹配非「轰海皇 波塞德拉」的怪兽或里侧表示的怪兽（里侧表示时没有卡名，不被视为「轰海皇 波塞德拉」）。
function s.cfilter(c)
	return not c:IsCode(id) or c:IsFacedown()
end
-- ③攻击限制的适用条件：自己场上有「轰海皇 波塞德拉」以外的怪兽存在时，返回true。
function s.atcon(e)
	-- 检查自己场上（主要怪兽区/额外怪兽区）是否存在1只除这张卡以外的怪兽，若存在则③效果适用。
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
