--幻獣機メガラプター
-- 效果：
-- 自己场上有衍生物特殊召唤时，把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。「幻兽机 猛禽大盗龙」的这个效果1回合只能使用1次。这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。此外，1回合1次，把1只衍生物解放才能发动。从卡组把1只名字带有「幻兽机」的怪兽加入手卡。
function c31533704.initial_effect(c)
	-- 自己场上有衍生物特殊召唤时，把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
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
	-- 判断场上是否存在衍生物的条件辅助函数，用于实现只要自己场上存在衍生物，此卡便获得某种抗性或持续性效果的机制。
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- 1回合1次，把1只衍生物解放才能发动。从卡组把1只名字带有「幻兽机」的怪兽加入手卡。
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
	-- 检索满足条件的卡片组，将目标怪兽特殊召唤。
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
-- 计算自己场上所有「幻兽机衍生物」的等级总和。
function c31533704.lvval(e,c)
	local tp=c:GetControler()
	-- 获取自己场上所有「幻兽机衍生物」的等级总和。
	return Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705):GetSum(Card.GetLevel)
end
-- 用于过滤场上满足条件的衍生物。
function c31533704.spfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_TOKEN)
end
-- 判断是否有衍生物被特殊召唤成功。
function c31533704.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31533704.spfilter,1,nil,tp)
end
-- 设置操作信息，确定要处理的效果分类。
function c31533704.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，确定要处理的效果分类为衍生物特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，确定要处理的效果分类为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 执行特殊召唤衍生物的操作。
function c31533704.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的空间进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否可以特殊召唤指定的衍生物。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 创建一个指定编号的衍生物。
		local token=Duel.CreateToken(tp,31533705)
		-- 将创建的衍生物特殊召唤到场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置检索效果的消耗条件。
function c31533704.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可解放的衍生物。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsType,1,nil,TYPE_TOKEN) end
	-- 选择要解放的衍生物。
	local g=Duel.SelectReleaseGroup(tp,Card.IsType,1,1,nil,TYPE_TOKEN)
	-- 将选中的衍生物解放作为效果的消耗。
	Duel.Release(g,REASON_COST)
end
-- 用于过滤卡组中满足条件的怪兽。
function c31533704.filter(c)
	return c:IsSetCard(0x101b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索效果的目标。
function c31533704.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c31533704.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，确定要处理的效果分类为加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果的操作。
function c31533704.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,c31533704.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选中的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
