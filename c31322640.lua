--魅惑の宮殿
-- 效果：
-- 这个卡名的③的效果1回合可以使用最多3次。
-- ①：自己场上的魔法师族怪兽的攻击力·守备力上升500。
-- ②：自己场上的「魅惑的女王」效果怪兽得到以下效果。
-- ●把用自身的效果把卡装备的这张卡送去墓地才能发动。从手卡·卡组把1只攻击力1500以下的魔法师族怪兽特殊召唤。
-- ③：把1张手卡送去墓地才能发动。从卡组选1只「魅惑的女王」怪兽加入手卡或在对方场上特殊召唤。
local s,id,o=GetID()
-- 注册场地魔法卡的通用发动效果，使卡能被正常发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上的魔法师族怪兽的攻击力上升500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 筛选目标为魔法师族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_SPELLCASTER))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 自己场上的「魅惑的女王」效果怪兽得到以下效果
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"特殊召唤（魅惑的宫殿）"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	-- 使「魅惑的女王」效果怪兽获得特殊召唤效果
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(s.eftg)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	-- 把1张手卡送去墓地才能发动。从卡组选1只「魅惑的女王」怪兽加入手卡或在对方场上特殊召唤
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))  --"选卡组「魅惑的女王」怪兽"
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(3,id)
	e6:SetCost(s.thcost)
	e6:SetTarget(s.thtg)
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6)
end
-- 检查指定卡是否具有特定Flag ID的效果
function s.costfilter(c,code)
	return c:GetFlagEffect(code)~=0
end
-- 支付特殊召唤的代价，将自身送去墓地并确认是否装备了由自身效果装备的卡
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤的发动条件，包括自身能送去墓地且装备了由自身效果装备的卡
	if chk==0 then return c:IsAbleToGraveAsCost() and aux.IsSelfEquip(c,FLAG_ID_ALLURE_QUEEN) end
	-- 将自身送去墓地作为特殊召唤的代价
	Duel.SendtoGrave(c,REASON_COST)
end
-- 筛选攻击力不超过1500的魔法师族怪兽，用于特殊召唤
function s.spfilter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤的发动条件，包括场上存在可用区域和满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否存在可用的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0
		-- 判断手卡或卡组中是否存在满足条件的魔法师族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,e:GetHandler():GetCode()) end
	-- 提示对方玩家选择了特殊召唤效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 执行特殊召唤操作，选择并特殊召唤符合条件的怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的怪兽用于特殊召唤
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 筛选「魅惑的女王」效果怪兽，用于获得特殊召唤效果
function s.eftg(e,c)
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(0x3)
end
-- 支付③效果的代价，将手卡中的一张卡送去墓地
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手卡中是否存在可送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择一张手卡送去墓地
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 筛选「魅惑的女王」怪兽，用于加入手卡或特殊召唤
function s.thfilter(c,e,tp)
	if not (c:IsSetCard(0x3) and c:IsType(TYPE_MONSTER)) then return false end
	-- 获取对方场上的可用怪兽区域数量
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp))
end
-- 判断是否满足③效果的发动条件，包括卡组中存在符合条件的怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的「魅惑的女王」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 执行③效果的操作，选择怪兽加入手卡或特殊召唤到对方场上
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的「魅惑的女王」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择一张符合条件的「魅惑的女王」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取对方场上的可用怪兽区域数量
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否选择将怪兽加入手卡，或是否满足特殊召唤条件
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 确认对方玩家看到该怪兽加入手卡
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将怪兽特殊召唤到对方场上
			Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
