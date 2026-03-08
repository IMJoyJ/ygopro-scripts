--ザ・ロック・オブ・ウォークライ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「战吼」怪兽加入手卡。
-- ②：自己场上的怪兽不存在的场合或者只有战士族怪兽的场合，自己·对方的战斗阶段开始时才能发动。同名卡不在自己场上存在的1只「战吼」怪兽从手卡特殊召唤。
-- ③：自己的战士族怪兽被战斗破坏的场合，可以作为代替把这张卡送去墓地。
function c45943516.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「战吼」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,45943516+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c45943516.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的怪兽不存在的场合或者只有战士族怪兽的场合，自己·对方的战斗阶段开始时才能发动。同名卡不在自己场上存在的1只「战吼」怪兽从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45943516,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c45943516.spcon)
	e2:SetTarget(c45943516.sptg)
	e2:SetOperation(c45943516.spop)
	c:RegisterEffect(e2)
	-- ③：自己的战士族怪兽被战斗破坏的场合，可以作为代替把这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(c45943516.reptg)
	e3:SetValue(c45943516.repval)
	e3:SetOperation(c45943516.repop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「战吼」怪兽卡片组
function c45943516.thfilter(c)
	return c:IsSetCard(0x15f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理：从卡组检索1只「战吼」怪兽加入手牌
function c45943516.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「战吼」怪兽卡片组
	local g=Duel.GetMatchingGroup(c45943516.thfilter,tp,LOCATION_DECK,0,nil)
	-- 判断是否发动效果：选择是否从卡组把1只「战吼」怪兽加入手卡
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(45943516,0)) then  --"是否从卡组把1只「战吼」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 确认玩家手牌
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 判断场上是否不存在非战士族怪兽
function c45943516.cfilter1(c)
	return c:IsFacedown() or not c:IsRace(RACE_WARRIOR)
end
-- 判断是否满足特殊召唤条件：自己场上的怪兽不存在或只有战士族怪兽
function c45943516.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否不存在非战士族怪兽
	return not Duel.IsExistingMatchingCard(c45943516.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
-- 判断场上是否存在同名卡
function c45943516.cfilter2(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 检索满足条件的「战吼」怪兽卡片组用于特殊召唤
function c45943516.spfilter(c,e,tp)
	return c:IsSetCard(0x15f) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断同名卡不在自己场上存在
		and not Duel.IsExistingMatchingCard(c45943516.cfilter2,tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
end
-- 设置特殊召唤效果的处理条件
function c45943516.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌中是否存在满足条件的「战吼」怪兽
		and Duel.IsExistingMatchingCard(c45943516.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手牌特殊召唤1只「战吼」怪兽
function c45943516.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「战吼」怪兽用于特殊召唤
	local g=Duel.SelectMatchingCard(tp,c45943516.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否为战士族怪兽且处于战斗破坏状态
function c45943516.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_WARRIOR)
		and c:IsControler(tp) and c:IsReason(REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否满足代替破坏条件：该卡可被送去墓地且有战士族怪兽被战斗破坏
function c45943516.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGrave() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(c45943516.repfilter,1,nil,tp) end
	-- 选择是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 返回代替破坏的判断条件
function c45943516.repval(e,c)
	return c45943516.repfilter(c,e:GetHandlerPlayer())
end
-- 效果处理：将该卡送去墓地
function c45943516.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将该卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
