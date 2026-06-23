--再世記
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组选1只「再世」怪兽加入手卡或送去墓地。自己场上有「再世」怪兽存在的场合，也能作为代替把1只攻击力和守备力是2500的怪兽从卡组加入手卡。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己墓地1只「再世」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册两个效果：①卡组操作效果和②特殊召唤效果
function s.initial_effect(c)
	-- ①：从卡组选1只「再世」怪兽加入手卡或送去墓地。自己场上有「再世」怪兽存在的场合，也能作为代替把1只攻击力和守备力是2500的怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组操作"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己墓地1只「再世」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 效果发动条件：这张卡不是在送去墓地的回合发动
	e2:SetCondition(aux.exccon)
	-- 效果发动费用：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：满足条件的卡为「再世」怪兽或攻击力守备力均为2500的怪兽，且能加入手卡或送去墓地
function s.thfilter(c,tp)
	return c:IsSetCard(0x1c5) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsAbleToGrave())
		-- 当自己场上存在「再世」怪兽时，可选择将攻击力守备力均为2500的怪兽加入手卡
		or Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x1c5)
		and c:IsAttack(2500) and c:IsDefense(2500) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的处理：检查卡组是否存在满足条件的卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 效果发动时的处理：选择一张满足条件的卡，决定将其加入手卡或送去墓地
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	-- 判断是否将卡加入手卡：若不是「再世」怪兽或无法送去墓地，则选择加入手卡
	if tc:IsAbleToHand() and (not tc:IsSetCard(0x1c5) or not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 确认对方查看该卡
		Duel.ConfirmCards(1-tp,tc)
	elseif tc:IsAbleToGrave() then
		-- 将卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 过滤函数：满足条件的卡为「再世」怪兽且能特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1c5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理：选择满足条件的墓地怪兽作为对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果发动时的处理：将对象怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否有效且未受王家长眠之谷影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
