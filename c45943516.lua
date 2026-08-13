--ザ・ロック・オブ・ウォークライ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「战吼」怪兽加入手卡。
-- ②：自己场上的怪兽不存在的场合或者只有战士族怪兽的场合，自己·对方的战斗阶段开始时才能发动。同名卡不在自己场上存在的1只「战吼」怪兽从手卡特殊召唤。
-- ③：自己的战士族怪兽被战斗破坏的场合，可以作为代替把这张卡送去墓地。
function c45943516.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只「战吼」怪兽加入手卡。
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
-- 判定一张卡是否为卡组中可加入手卡的「战吼」怪兽（用于①的检索条件）。
function c45943516.thfilter(c)
	return c:IsSetCard(0x15f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①的效果处理：从卡组中检索「战吼」怪兽，由玩家选择是否加入手卡；若选择是，则选1张加入手牌并向对方展示。
function c45943516.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方卡组中所有满足「战吼」怪兽且可加入手卡的卡。
	local g=Duel.GetMatchingGroup(c45943516.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若存在符合条件的卡且玩家同意将卡加入手卡，则继续执行加入手卡的处理。
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(45943516,0)) then  --"是否从卡组把1只「战吼」怪兽加入手卡？"
		-- 显示选择提示，请玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将选中的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 判定怪兽是否为里侧表示或非战士族（用于②发动条件中“只有战士族怪兽”的检查）。
function c45943516.cfilter1(c)
	return c:IsFacedown() or not c:IsRace(RACE_WARRIOR)
end
-- ②的发动条件判定：自己场上不存在里侧表示或非战士族的怪兽，即没有怪兽或所有怪兽均为表侧战士族。
function c45943516.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查我方怪兽区是否存在满足 cfilter1 的卡；不存在时返回真，允许②在战斗阶段开始时发动。
	return not Duel.IsExistingMatchingCard(c45943516.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
-- 判定一张表侧表示怪兽的卡名是否与指定卡相同（用于检查同名卡是否在自己场上存在）。
function c45943516.cfilter2(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 判定手牌中的「战吼」怪兽是否可被特殊召唤，并且自己场上不存在同名卡（用于②选择特殊召唤对象）。
function c45943516.spfilter(c,e,tp)
	return c:IsSetCard(0x15f) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 追加检查：自己场上不存在与候选卡同名的表侧表示怪兽。
		and not Duel.IsExistingMatchingCard(c45943516.cfilter2,tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
end
-- ②的发动目标判定：我方主要怪兽区有空位，且手牌中存在满足 spfilter 的「战吼」怪兽。
function c45943516.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动的合法性检查时，首先确认我方主要怪兽区有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认手牌中存在一只满足 spfilter 的「战吼」怪兽（可特殊召唤且场上无同名卡）。
		and Duel.IsExistingMatchingCard(c45943516.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向系统登记本次效果将进行特殊召唤（来源手牌，数量1），供效果处理及连锁时点判断使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②的效果处理：从手牌选择1只满足条件的「战吼」怪兽，以表侧表示特殊召唤到自己场上。
function c45943516.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认我方主要怪兽区有空位；若没有，则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，请玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1张满足 spfilter 的「战吼」怪兽（可特殊召唤且场上无同名卡）。
	local g=Duel.SelectMatchingCard(tp,c45943516.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到当前玩家场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判定一只怪兽是否为表侧表示、我方场上的战士族怪兽，且正要被战斗破坏（且不是已被代替破坏处理过的目标）。
function c45943516.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_WARRIOR)
		and c:IsControler(tp) and c:IsReason(REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- ③的代替破坏触发判定：这张卡可送去墓地，且本次战斗破坏的怪兽中存在满足 repfilter 的战士族怪兽，并且这张卡尚未被确认破坏。
function c45943516.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGrave() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(c45943516.repfilter,1,nil,tp) end
	-- 让玩家选择是否发动③的代替破坏效果。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏效果的值函数：判断被战斗破坏的怪兽是否为我方战士族，以决定是否用这张卡代替其破坏。
function c45943516.repval(e,c)
	return c45943516.repfilter(c,e:GetHandlerPlayer())
end
-- ③的代替破坏处理：将被战斗破坏的战士族怪兽的破坏，改为把这张场地魔法卡送去墓地。
function c45943516.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡以“效果+代替”的原因送入墓地，完成代替破坏。
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
