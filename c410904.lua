--憑依覚醒－ラセンリュウ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡可以把自己场上的表侧表示的1只魔法师族怪兽和1只4星以下的风属性怪兽送去墓地，从手卡·卡组特殊召唤。
-- ②：这张卡的①的方法特殊召唤时才能发动。对方场上1张卡回到手卡。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「风灵术」卡或「凭依」魔法·陷阱卡加入手卡。
function c410904.initial_effect(c)
	-- ①：这张卡可以把自己场上的表侧表示的1只魔法师族怪兽和1只4星以下的风属性怪兽送去墓地，从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCondition(c410904.spcon)
	e1:SetTarget(c410904.sptg)
	e1:SetOperation(c410904.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 这个卡名的②③的效果1回合各能使用1次。②：这张卡的①的方法特殊召唤时才能发动。对方场上1张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(410904,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,410904)
	e2:SetCondition(c410904.condition)
	e2:SetTarget(c410904.rthtg)
	e2:SetOperation(c410904.rthop)
	c:RegisterEffect(e2)
	-- 这个卡名的②③的效果1回合各能使用1次。③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「风灵术」卡或「凭依」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(410904,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,410905)
	e3:SetCondition(c410904.thcon)
	e3:SetTarget(c410904.thtg)
	e3:SetOperation(c410904.thop)
	c:RegisterEffect(e3)
end
-- spfilter：筛选出表侧表示且可以当作COST送去墓地的怪兽，作为①的特殊召唤候选素材。
function c410904.spfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- spfilter2：筛选出风属性且4星以下的怪兽，作为①所需的另一素材条件。
function c410904.spfilter2(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsLevelBelow(4)
end
-- fselect：检查所选2张素材是否满足：送墓后仍有空位，并且其中1张是魔法师族、另1张是风属性4星以下（顺序不限）。
function c410904.fselect(g,tp)
	-- 返回fselect的判定结果：aux.mzctcheck确认送墓后有空位；aux.gffcheck确认两张素材分别满足两种条件。
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,Card.IsRace,RACE_SPELLCASTER,c410904.spfilter2,nil)
end
-- spcon：特殊召唤规则条件，c为空时视为允许；否则检查我方场上是否存在2张符合条件的素材。
function c410904.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 取得我方场上所有可作为规则召唤素材的怪兽（表侧且可送墓）。
	local g=Duel.GetMatchingGroup(c410904.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c410904.fselect,2,2,tp)
end
-- sptg：选择规则召唤的2张素材，若选择成功则保存到效果标签中，返回true；否则返回false。
function c410904.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得我方场上可作素材的怪兽组，供SelectSubGroup选择。
	local g=Duel.GetMatchingGroup(c410904.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 以提示消息“请选择要送去墓地的卡”让玩家选择素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c410904.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- spop：规则召唤处理时，将选择好的素材送去墓地，并清理保存的引用。
function c410904.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 把作为COST的素材组送去墓地（原因设为REASON_SPSUMMON，表示作为特殊召唤手续）。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- condition：判定此卡是通过①的效果（自身规则特殊召唤）成功特殊召唤，用于②的发动条件。
function c410904.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- rthtg：②效果发动条件与目标登记：对方场上有可回手牌的卡时，登记回手牌操作。
function c410904.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张可以回手牌的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 登记操作信息：本次效果将把对方场上1张卡返回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
end
-- rthop：②效果处理时，选择对方场上1张可回手牌的卡并返回手牌。
function c410904.rthop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上的1张可回手牌的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡返回持有者手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- thcon：③效果的发动条件，判定此卡是从场上区域送去墓地。
function c410904.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- thfilter：检索过滤，目标为「风灵术」卡，或「凭依」魔法·陷阱卡，且能够加入手牌。
function c410904.thfilter(c)
	return ((c:IsSetCard(0xc0) and c:IsType(TYPE_SPELL+TYPE_TRAP)) or c:IsSetCard(0x914c)) and c:IsAbleToHand()
end
-- thtg：③效果发动条件与目标登记：卡组中存在可检索目标时，登记检索加入手牌操作。
function c410904.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c410904.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果将从卡组把1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- thop：③效果处理时，从卡组选择1张符合条件的卡加入手牌，并向对手展示。
function c410904.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,c410904.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手牌的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
