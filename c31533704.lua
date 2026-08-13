--幻獣機メガラプター
-- 效果：
-- 自己场上有衍生物特殊召唤时，把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。「幻兽机 猛禽大盗龙」的这个效果1回合只能使用1次。这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。此外，1回合1次，把1只衍生物解放才能发动。从卡组把1只名字带有「幻兽机」的怪兽加入手卡。
function c31533704.initial_effect(c)
	-- 这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(c31533704.lvval)
	c:RegisterEffect(e1)
	-- 只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 设定该效果的条件：只有自己场上有衍生物存在时，这张卡才不会被战斗破坏。
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- 自己场上有衍生物特殊召唤时，把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。「幻兽机 猛禽大盗龙」的这个效果1回合只能使用1次。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31533704,0))  --"特殊召唤Token"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,31533704)
	e4:SetCondition(c31533704.spcon)
	e4:SetTarget(c31533704.sptg)
	e4:SetOperation(c31533704.spop)
	c:RegisterEffect(e4)
	-- 此外，1回合1次，把1只衍生物解放才能发动。从卡组把1只名字带有「幻兽机」的怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(31533704,1))  --"检索"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(c31533704.thcost)
	e5:SetTarget(c31533704.thtg)
	e5:SetOperation(c31533704.thop)
	c:RegisterEffect(e5)
end
-- 计算等级上升量的函数：取自己场上所有「幻兽机衍生物」的等级合计作为上升数值。
function c31533704.lvval(e,c)
	local tp=c:GetControler()
	-- 获取自己场上所有卡号31533705（幻兽机衍生物）的怪兽，并将它们的等级求和。
	return Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705):GetSum(Card.GetLevel)
end
-- 判断一张卡是否是自己场上的衍生物（用于筛选特殊召唤成功的衍生物）。
function c31533704.spfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_TOKEN)
end
-- 触发条件：本次特殊召唤成功的怪兽中存在至少1只自己场上的衍生物。
function c31533704.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31533704.spfilter,1,nil,tp)
end
-- 效果发动时的目标设定：无需选择对象，同时设置本连锁会特殊召唤1只衍生物的操作信息。
function c31533704.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统登记本连锁将生成1只衍生物，供其他卡的效果判定。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 向系统登记本连锁将进行1只怪兽的特殊召唤，供其他卡的效果判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：若主怪兽区有空位且允许特招该衍生物，则生成1只「幻兽机衍生物」并特殊召唤。
function c31533704.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的主怪兽区是否有空余位置，若无空位则特殊召唤不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否能够将参数指定的「幻兽机衍生物」（机械族·风·3星·攻/守0）以表侧表示特殊召唤到自己场上。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 生成1只卡号为31533705的「幻兽机衍生物」。
		local token=Duel.CreateToken(tp,31533705)
		-- 把生成的衍生物以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 发动代价处理：解放自己场上1只衍生物；先检查是否有可解放的衍生物，然后选择并解放。
function c31533704.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只衍生物可以作为解放代价。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsType,1,nil,TYPE_TOKEN) end
	-- 选择1只衍生物作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsType,1,1,nil,TYPE_TOKEN)
	-- 将选择的衍生物解放（作为COST处理）。
	Duel.Release(g,REASON_COST)
end
-- 检索过滤：卡名包含「幻兽机」（0x101b）的怪兽卡且能被加入手卡。
function c31533704.filter(c)
	return c:IsSetCard(0x101b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果目标设定：若卡组中存在符合条件的怪兽，则登记本次连锁的操作信息为从卡组将1张卡加入手卡。
function c31533704.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认卡组中是否存在至少1只符合条件的「幻兽机」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c31533704.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统登记本连锁将从卡组把1张卡加入手卡，供其他卡的效果判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的「幻兽机」怪兽加入手卡，并给对方确认。
function c31533704.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡片（显示选择消息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合条件的「幻兽机」怪兽。
	local g=Duel.SelectMatchingCard(tp,c31533704.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「幻兽机」怪兽加入其持有者的手卡（不指定玩家表示回到持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的那张卡展示给对手确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
