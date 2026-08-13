--マイクロ・コーダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上的电子界族怪兽作为「码语者」怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
-- ②：这张卡作为「码语者」怪兽的连接素材从手卡·场上送去墓地的场合才能发动。从卡组把1张「电脑网」魔法·陷阱卡加入手卡。场上的这张卡为素材的场合可以把那1张改成1只电子界族·4星怪兽。
function c2347477.initial_effect(c)
	-- ①：把自己场上的电子界族怪兽作为「码语者」怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,2347477)
	e1:SetValue(c2347477.matval)
	c:RegisterEffect(e1)
	-- ②：这张卡作为「码语者」怪兽的连接素材从手卡·场上送去墓地的场合才能发动。从卡组把1张「电脑网」魔法·陷阱卡加入手卡。场上的这张卡为素材的场合可以把那1张改成1只电子界族·4星怪兽。
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
-- 筛选并检查是否存在我方场上的电子界族怪兽，用于判断手卡的这张卡能否作为「码语者」的连接素材。
function c2347477.mfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_CYBERSE) and c:IsControler(tp)
end
-- 检查当前连接素材中是否已经包含手卡的这张卡，用于防止重复使用同名卡作为素材。
function c2347477.exmfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsCode(2347477)
end
-- 判定手卡的这张卡是否可作为「码语者」怪兽的连接素材：连接怪兽需为「码语者」，素材中存在我方场上的电子界族怪兽，且不重复使用手卡的这张卡。
function c2347477.matval(e,lc,mg,c,tp)
	if not lc:IsSetCard(0x101) then return false,nil end
	return true,not mg or mg:IsExists(c2347477.mfilter,1,nil,tp) and not mg:IsExists(c2347477.exmfilter,1,nil)
end
-- 触发条件判定：这张卡作为「码语者」怪兽的连接素材从手卡或场上送去墓地；若从场上送去墓地则标记Label为1并注册‘从场上送去墓地’的客户端提示。
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
-- 筛选检索对象：chk为0时选择「电脑网」魔法·陷阱卡，chk为1时选择电子界族·4星怪兽，且目标必须能够加入手牌。
function c2347477.thfilter(c,chk)
	return ((c:IsSetCard(0x118) and c:IsType(TYPE_SPELL+TYPE_TRAP)) or (chk==1 and c:IsRace(RACE_CYBERSE) and c:IsLevel(4))) and c:IsAbleToHand()
end
-- 效果发动时检查卡组是否存在对应的检索对象，并设置‘从卡组加入手牌’的操作信息。
function c2347477.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查卡组是否存在1张满足检索条件的卡片，作为发动合法性判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c2347477.thfilter,tp,LOCATION_DECK,0,1,nil,e:GetLabel()) end
	-- 设置本次效果将执行从卡组把1张卡加入手牌的操作信息，供相关卡片和时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：提示选择后从卡组选择1张符合条件的卡加入手牌，并展示给对方玩家确认。
function c2347477.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择卡片的提示消息，内容为‘请选择要加入手牌的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 以检索选择模式从卡组中选择1张满足条件的卡，具体条件由e:GetLabel()区分是「电脑网」魔陷还是电子界·4星怪兽。
	local g=Duel.SelectMatchingCard(tp,c2347477.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选择的卡片以效果原因加入玩家tp的手牌。
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		-- 将加入手牌的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
