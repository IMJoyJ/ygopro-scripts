--マイクロ・コーダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上的电子界族怪兽作为「码语者」怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
-- ②：这张卡作为「码语者」怪兽的连接素材从手卡·场上送去墓地的场合才能发动。从卡组把1张「电脑网」魔法·陷阱卡加入手卡。场上的这张卡为素材的场合可以把那1张改成1只电子界族·4星怪兽。
function c2347477.initial_effect(c)
	-- 效果原文：①：把自己场上的电子界族怪兽作为「码语者」怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,2347477)
	e1:SetValue(c2347477.matval)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡作为「码语者」怪兽的连接素材从手卡·场上送去墓地的场合才能发动。从卡组把1张「电脑网」魔法·陷阱卡加入手卡。场上的这张卡为素材的场合可以把那1张改成1只电子界族·4星怪兽。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2347477,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,2347478)
	e3:SetCondition(c2347477.thcon)
	e3:SetTarget(c2347477.thtg)
	e3:SetOperation(c2347477.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查场上是否存在电子界族怪兽
function c2347477.mfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_CYBERSE) and c:IsControler(tp)
end
-- 过滤函数：检查手牌中是否存在微码编码员
function c2347477.exmfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsCode(2347477)
end
-- 连接素材判断函数：判断是否可以将手牌的微码编码员作为连接素材
function c2347477.matval(e,lc,mg,c,tp)
	if not lc:IsSetCard(0x101) then return false,nil end
	return true,not mg or mg:IsExists(c2347477.mfilter,1,nil,tp) and not mg:IsExists(c2347477.exmfilter,1,nil)
end
-- 发动条件判断函数：判断是否满足作为码语者怪兽连接素材被送去墓地的条件
function c2347477.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	e:SetLabel(0)
	if c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0x101) then
		if c:IsPreviousLocation(LOCATION_ONFIELD) then
			e:SetLabel(1)
			c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(2347477,1))  --"从场上送去墓地"
		end
		return true
	else
		return false
	end
end
-- 检索过滤函数：判断卡组中是否存在电脑网魔法/陷阱卡或电子界族4星怪兽
function c2347477.thfilter(c,chk)
	return ((c:IsSetCard(0x118) and c:IsType(TYPE_SPELL+TYPE_TRAP)) or (chk==1 and c:IsRace(RACE_CYBERSE) and c:IsLevel(4))) and c:IsAbleToHand()
end
-- 效果处理准备函数：设置效果处理时需要检索的卡组中的卡
function c2347477.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果处理准备函数：判断是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c2347477.thfilter,tp,LOCATION_DECK,0,1,nil,e:GetLabel()) end
	-- 效果处理准备函数：设置效果处理时的卡组检索操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：执行从卡组检索并加入手牌的操作
function c2347477.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示函数：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择函数：从卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c2347477.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		-- 操作函数：将选中的卡加入手牌
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		-- 操作函数：确认对方手牌中被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
