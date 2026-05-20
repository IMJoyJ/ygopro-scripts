--トイ・ソルジャー
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
-- ②：魔法与陷阱区域盖放的这张卡被送去墓地的场合才能发动。这张卡特殊召唤。
-- ③：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「玩具箱子」加入手卡。自己场上有「玩具箱子」存在的场合，也能作为代替把1只光属性·4星怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果：①手卡盖放为魔法卡、②魔陷区盖放送墓特召、③召唤/特召检索「玩具箱子」或光属性4星怪兽。
function s.initial_effect(c)
	-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- ②：魔法与陷阱区域盖放的这张卡被送去墓地的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「玩具箱子」加入手卡。自己场上有「玩具箱子」存在的场合，也能作为代替把1只光属性·4星怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
s.set_as_spell=true
-- 效果②发动条件：此卡此前存在于魔法与陷阱区域且为背面表示。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 效果②发动准备：检查怪兽区域是否有空位，以及此卡是否能特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息：包含特殊召唤自身的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②处理：若此卡仍存在于原本位置，则将其在自己场上表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检索过滤条件：可以加入手牌，且为「玩具箱子」（若满足check条件，也可以是光属性4星怪兽）。
function s.thfilter(c,check)
	return c:IsAbleToHand()
		and (c:IsCode(24878656) or (check and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4)))
end
-- 检查过滤条件：自己场上表侧表示存在的「玩具箱子」。
function s.checkfilter(c)
	return c:IsFaceup() and c:IsCode(24878656)
end
-- 效果③发动准备：检查自己场上是否存在「玩具箱子」，并确认卡组中是否有可检索的卡，设置检索操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否存在表侧表示的「玩具箱子」。
		local check=Duel.IsExistingMatchingCard(s.checkfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查卡组中是否存在满足检索条件的卡。
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,check)
	end
	-- 设置连锁处理信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③处理：根据场上是否存在「玩具箱子」，从卡组选择1张「玩具箱子」或光属性4星怪兽加入手牌并展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次检查自己场上是否存在表侧表示的「玩具箱子」。
	local check=Duel.IsExistingMatchingCard(s.checkfilter,tp,LOCATION_ONFIELD,0,1,nil)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,check)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
