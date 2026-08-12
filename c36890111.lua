--地獄人形の館
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「机关傀儡」怪兽加入手卡。
-- ②：自己场上的「机关傀儡」怪兽不会被战斗破坏，不受超量怪兽以外的对方怪兽发动的效果影响。
-- ③：1回合1次，把自己场上1个超量素材取除，以自己墓地1只「机关傀儡」怪兽为对象才能发动。那只怪兽在对方场上守备表示特殊召唤。
local s,id,o=GetID()
-- 创建并注册该卡的3个效果：①检索效果、②怪兽不被战斗破坏且不受非超量怪兽效果影响、③特殊召唤效果
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「机关傀儡」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「机关傀儡」怪兽不会被战斗破坏，不受超量怪兽以外的对方怪兽发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	-- ③：1回合1次，把自己场上1个超量素材取除，以自己墓地1只「机关傀儡」怪兽为对象才能发动。那只怪兽在对方场上守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 定义过滤函数，用于筛选「机关傀儡」怪兽
function s.filter(c)
	return c:IsSetCard(0x1083) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动效果时，从卡组检索1只「机关傀儡」怪兽加入手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家卡组中所有满足条件的「机关傀儡」怪兽
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 判断是否有满足条件的怪兽且玩家选择发动效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组把「机关傀儡」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 定义目标过滤函数，用于筛选场上「机关傀儡」怪兽
function s.indtg(e,c)
	return c:IsSetCard(0x1083) and c:IsFaceup()
end
-- 定义效果过滤函数，用于判断是否免疫对方怪兽效果
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated() and re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsType(TYPE_XYZ)
end
-- 定义特殊召唤过滤函数，用于筛选可特殊召唤的「机关傀儡」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1083) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
-- 特殊召唤效果的费用处理：移除1个超量素材
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除1个超量素材作为费用
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	-- 执行移除1个超量素材的操作
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- 特殊召唤效果的目标选择处理
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 判断对方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 判断玩家墓地是否有满足条件的怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽在对方场上守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
