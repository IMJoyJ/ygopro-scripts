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
-- 筛选素材集合中位于自己场上、由自己控制且为电子界族的怪兽，用于确认存在可作为「码语者」连接素材的对象。
function c30114823.mfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_CYBERSE) and c:IsControler(tp)
end
-- 筛选素材集合中位于手卡且卡名为代码生成员（30114823）的卡，用于防止同名手卡被重复作为额外素材计入。
function c30114823.exmfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsCode(30114823)
end
-- 判定手卡的这张卡能否作为「码语者」怪兽的额外连接素材：目标连接怪兽必须是「码语者」，且素材集合中至少包含己方场上的电子界族怪兽，同时素材集合中不存在另一张手卡的同名卡。
function c30114823.matval(e,lc,mg,c,tp)
	if not lc:IsSetCard(0x101) then return false,nil end
	return true,not mg or mg:IsExists(c30114823.mfilter,1,nil,tp) and not mg:IsExists(c30114823.exmfilter,1,nil)
end
-- ②效果的发动条件：这张卡作为「码语者」怪兽的连接素材从手卡或场上送去墓地的场合才能发动；若从场上送去墓地，则设置标签并给对方显示“从场上送去墓地”的提示信息。
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
-- 筛选卡组中符合条件的卡：电子界族、攻击力1200以下，并且根据chk判断是否能送去墓地或加入手卡。
function c30114823.tdfilter(c,chk)
	return c:IsRace(RACE_CYBERSE) and c:IsAttackBelow(1200) and (c:IsAbleToGrave() or (chk==1 and c:IsAbleToHand()))
end
-- ②效果的发动时点处理：先确认卡组中存在符合条件的卡片，然后登记本次操作包含从卡组把卡送去墓地的信息。
function c30114823.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组中是否存在至少1张符合条件的电子界族怪兽，若不存在则②效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c30114823.tdfilter,tp,LOCATION_DECK,0,1,nil,e:GetLabel()) end
	-- 设置操作信息，向系统声明本次连锁处理可能涉及“从卡组将卡送去墓地”这一效果分类。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果的实际处理：从卡组选出1只符合条件的电子界族怪兽，再根据这张卡是否从场上作为素材以及玩家选择，决定将其送去墓地还是加入手卡；若加入手卡则让对方确认。
function c30114823.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 给操作玩家显示“请选择要送去墓地的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从己方卡组选择1张满足条件的电子界族怪兽（攻击力1200以下）。
	local g=Duel.SelectMatchingCard(tp,c30114823.tdfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	local tc=g:GetFirst()
	if not tc then return end
	-- 判断选中的卡是送去墓地还是加入手卡：若这张卡不是从场上作为素材（e:GetLabel()==0），或所选卡不能加入手卡，则直接送去墓地；否则由玩家在“送去墓地”和“加入手卡”中二选一。
	if tc:IsAbleToGrave() and (e:GetLabel()==0 or not tc:IsAbleToHand() or Duel.SelectOption(tp,1191,1190)==0) then
		-- 将选中的卡以效果原因送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	else
		-- 将选中的卡加入持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对手确认加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
