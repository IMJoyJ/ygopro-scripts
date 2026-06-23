--誘いのΔ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②③的效果1回合各能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只5星以上的不死族怪兽送去墓地。
-- ②：场上有不死族怪兽存在的场合才能发动。在自己场上把1只「Δ衍生物」（不死族·暗·5星·攻/守0）特殊召唤。
-- ③：这张卡在墓地存在的状态，怪兽从墓地加入手卡的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 创建并注册三个效果，分别对应发动、特殊召唤和加入手卡效果
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只5星以上的不死族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：场上有不死族怪兽存在的场合才能发动。在自己场上把1只「Δ衍生物」（不死族·暗·5星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tkcon)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的状态，怪兽从墓地加入手卡的场合才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 定义过滤函数，用于筛选5星以上且为不死族的可送去墓地的怪兽
function s.tgfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevelAbove(5) and c:IsAbleToGrave()
end
-- 发动效果时，从卡组检索符合条件的怪兽并选择是否送去墓地
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组怪兽集合
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	-- 判断是否有满足条件的怪兽且玩家选择将怪兽送去墓地
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把卡送去墓地？"
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的怪兽送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 判断场上有无不死族怪兽的条件函数
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在不死族怪兽
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsRace),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,RACE_ZOMBIE)
end
-- 特殊召唤效果的目标设定函数
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,5,RACE_ZOMBIE,ATTRIBUTE_DARK,POS_FACEUP) end
	-- 设置操作信息为召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息为特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 特殊召唤效果的执行函数
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 判断是否可以特殊召唤衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,5,RACE_ZOMBIE,ATTRIBUTE_DARK,POS_FACEUP) then return end
	-- 创建衍生物
	local token=Duel.CreateToken(tp,id+o)
	-- 将衍生物特殊召唤到场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- 触发效果的过滤函数，用于判断是否为从墓地加入手卡的怪兽
function s.trigfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_GRAVE)
end
-- 判断是否有怪兽从墓地加入手卡
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.trigfilter,1,nil)
end
-- 加入手卡效果的目标设定函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息为将卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 加入手卡效果的执行函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡是否与效果相关且未受王家长眠之谷影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,c)
	end
end
