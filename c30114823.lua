--コード・ジェネレーター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上的电子界族怪兽作为「码语者」怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
-- ②：这张卡作为「码语者」怪兽的连接素材从手卡·场上送去墓地的场合才能发动。从卡组把1只攻击力1200以下的电子界族怪兽送去墓地。场上的这张卡为素材的场合也能不送去墓地加入手卡。
function c30114823.initial_effect(c)
	-- ①：把自己场上的电子界族怪兽作为「码语者」怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,30114823)
	e1:SetValue(c30114823.matval)
	c:RegisterEffect(e1)
	-- ②：这张卡作为「码语者」怪兽的连接素材从手卡·场上送去墓地的场合才能发动。从卡组把1只攻击力1200以下的电子界族怪兽送去墓地。场上的这张卡为素材的场合也能不送去墓地加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30114823,0))
	e3:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,30114824)
	e3:SetCondition(c30114823.tdcon)
	e3:SetTarget(c30114823.tdtg)
	e3:SetOperation(c30114823.tdop)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查以玩家来看的场上是否存在电子界族怪兽
function c30114823.mfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_CYBERSE) and c:IsControler(tp)
end
-- 过滤函数，检查以玩家来看的手卡是否存在代码生成员
function c30114823.exmfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsCode(30114823)
end
-- 连接素材验证函数，用于判断是否可以将手卡的代码生成员作为连接素材
function c30114823.matval(e,lc,mg,c,tp)
	if not lc:IsSetCard(0x101) then return false,nil end
	return true,not mg or mg:IsExists(c30114823.mfilter,1,nil,tp) and not mg:IsExists(c30114823.exmfilter,1,nil)
end
-- 效果发动条件判断函数，用于判断是否满足作为码语者怪兽连接素材被送去墓地的条件
function c30114823.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	e:SetLabel(0)
	if c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0x101) then
		if c:IsPreviousLocation(LOCATION_ONFIELD) then
			e:SetLabel(1)
			c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(30114823,1))  --"从场上送去墓地"
		end
		return true
	else
		return false
	end
end
-- 检索过滤函数，用于筛选攻击力1200以下的电子界族怪兽
function c30114823.tdfilter(c,chk)
	return c:IsRace(RACE_CYBERSE) and c:IsAttackBelow(1200) and (c:IsAbleToGrave() or (chk==1 and c:IsAbleToHand()))
end
-- 效果处理目标设定函数，用于设置效果处理的目标为卡组中符合条件的怪兽
function c30114823.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果处理条件，即卡组中是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c30114823.tdfilter,tp,LOCATION_DECK,0,1,nil,e:GetLabel()) end
	-- 设置效果处理信息，指定将要处理的卡为卡组中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，用于执行将怪兽从卡组送去墓地或加入手卡的操作
function c30114823.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c30114823.tdfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	local tc=g:GetFirst()
	if not tc then return end
	-- 判断是否选择将怪兽送去墓地，否则将怪兽加入手卡
	if tc:IsAbleToGrave() and (e:GetLabel()==0 or not tc:IsAbleToHand() or Duel.SelectOption(tp,1191,1190)==0) then
		-- 将选定的怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	else
		-- 将选定的怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
