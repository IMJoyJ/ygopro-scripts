--DDD烈火大王エグゼクティブ・テムジン
-- 效果：
-- 5星以上的「DD」怪兽＋「DD」怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在怪兽区域存在的状态，自己场上有「DD」怪兽召唤·特殊召唤的场合，以自己墓地1只「DD」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：自己回合1次，魔法·陷阱卡的效果发动时才能发动。那个发动无效。
function c16006416.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用满足matfilter条件和DD怪兽的怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,c16006416.matfilter,aux.FilterBoolFunction(Card.IsFusionSetCard,0xaf),true)
	-- ①：这张卡在怪兽区域存在的状态，自己场上有「DD」怪兽召唤·特殊召唤的场合，以自己墓地1只「DD」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16006416,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,16006416)
	e1:SetCondition(c16006416.spcon)
	e1:SetTarget(c16006416.sptg)
	e1:SetOperation(c16006416.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己回合1次，魔法·陷阱卡的效果发动时才能发动。那个发动无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16006416,1))  --"发动无效"
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c16006416.negcon)
	e3:SetTarget(c16006416.negtg)
	e3:SetOperation(c16006416.negop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤器，筛选等级5以上的DD怪兽
function c16006416.matfilter(c)
	return c:IsFusionSetCard(0xaf) and c:IsLevelAbove(5)
end
-- 场上的DD怪兽过滤器，筛选正面表示的己方DD怪兽
function c16006416.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsControler(tp)
end
-- 效果发动条件判断，确保不是自己召唤/特殊召唤的怪兽，并且有己方场上的DD怪兽
function c16006416.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c16006416.cfilter,1,nil,tp)
end
-- 墓地特殊召唤过滤器，筛选可以特殊召唤的DD怪兽
function c16006416.spfilter(c,e,tp)
	return c:IsSetCard(0xaf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选择目标阶段，判断是否满足特殊召唤条件
function c16006416.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c16006416.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的DD怪兽
		and Duel.IsExistingTarget(c16006416.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡，从己方墓地选择一只满足条件的DD怪兽
	local g=Duel.SelectTarget(tp,c16006416.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，确定特殊召唤的卡和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段，将选中的卡特殊召唤
function c16006416.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 无效效果发动条件判断，确保是己方回合且发动的是魔法或陷阱卡
function c16006416.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确保是己方回合且发动的是魔法或陷阱卡，并且该发动可以被无效
	return Duel.GetTurnPlayer()==tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 设置无效效果的目标信息
function c16006416.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，确定无效效果的目标数量
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果处理阶段，使发动无效
function c16006416.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁的发动无效
	Duel.NegateActivation(ev)
end
