--サブテラーマリスの妖魔
-- 效果：
-- 反转怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升作为这张卡的连接素材的「地中族」怪兽的原本等级合计×100。
-- ②：自己主要阶段才能发动。从卡组把1只反转怪兽送去墓地，从手卡把1只怪兽在这张卡所连接区里侧守备表示特殊召唤。
-- ③：1回合1次，这张卡所连接区的怪兽反转的场合发动。从自己的卡组·墓地把1只反转怪兽加入手卡。
function c74937659.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤的手续为反转怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_FLIP),2,2)
	-- ①：这张卡的攻击力上升作为这张卡的连接素材的「地中族」怪兽的原本等级合计×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c74937659.matcheck)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从卡组把1只反转怪兽送去墓地，从手卡把1只怪兽在这张卡所连接区里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74937659,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,74937659)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c74937659.tgtg)
	e2:SetOperation(c74937659.tgop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，这张卡所连接区的怪兽反转的场合发动。从自己的卡组·墓地把1只反转怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(74937659,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_FLIP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c74937659.thcon)
	e3:SetTarget(c74937659.thtg)
	e3:SetOperation(c74937659.thop)
	c:RegisterEffect(e3)
end
-- 过滤作为连接素材的「地中族」怪兽
function c74937659.matfilter(c)
	return c:IsSetCard(0xed) and c:GetOriginalLevel()>=0
end
-- 检查连接素材并根据素材中「地中族」怪兽的原本等级合计为这张卡施加攻击力上升的效果
function c74937659.matcheck(e,c)
	local g=c:GetMaterial():Filter(c74937659.matfilter,nil)
	local atk=g:GetSum(Card.GetOriginalLevel)
	-- 这张卡的攻击力上升作为这张卡的连接素材的「地中族」怪兽的原本等级合计×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk*100)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 过滤卡组中可以送去墓地的反转怪兽
function c74937659.tgfilter(c)
	return c:IsType(TYPE_FLIP) and c:IsAbleToGrave()
end
-- 过滤手卡中可以里侧守备表示特殊召唤到指定连接区的怪兽
function c74937659.spfilter(c,e,tp,zone)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,tp,zone)
end
-- 效果②的发动条件检查与操作信息设置
function c74937659.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetLinkedZone(tp)
	-- 检查卡组中是否存在可以送去墓地的反转怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c74937659.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查手卡中是否存在可以特殊召唤到这张卡所连接区的怪兽
		and Duel.IsExistingMatchingCard(c74937659.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,zone) end
	-- 设置将卡组的1张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置从手卡特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的执行：从卡组将1只反转怪兽送去墓地，并从手卡将1只怪兽在这张卡所连接区里侧守备表示特殊召唤
function c74937659.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组选择1只满足条件的反转怪兽
	local g=Duel.SelectMatchingCard(tp,c74937659.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功将选中的怪兽送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0
		and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		local zone=e:GetHandler():GetLinkedZone(tp)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从手卡选择1只满足条件的怪兽
		local sg=Duel.SelectMatchingCard(tp,c74937659.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,zone)
		if zone~=0 and sg:GetCount()>0 then
			local hint=sg:GetFirst():IsPublic()
			-- 将选中的怪兽在所连接区里侧守备表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE,zone)
			if hint then
				-- 让对方玩家确认特殊召唤的里侧表示怪兽
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
end
-- 过滤反转的怪兽是否处于这张卡的所连接区（包括离场前的位置）
function c74937659.cfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return ec:GetLinkedGroup():IsContains(c)
	else
		return bit.extract(ec:GetLinkedZone(c:GetPreviousControler()),c:GetPreviousSequence())~=0
	end
end
-- 效果③的发动条件：检查是否有这张卡所连接区的怪兽反转
function c74937659.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c74937659.cfilter,1,nil,e:GetHandler())
end
-- 过滤可以加入手牌的反转怪兽
function c74937659.thfilter(c)
	return c:IsType(TYPE_FLIP) and c:IsAbleToHand()
end
-- 效果③的发动条件检查与操作信息设置
function c74937659.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置从卡组或墓地将1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果③的执行：从卡组或墓地选择1只反转怪兽加入手牌
function c74937659.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组或墓地选择1只不受王家之谷影响的反转怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c74937659.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
