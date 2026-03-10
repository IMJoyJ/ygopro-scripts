--氷結界の伝道師
-- 效果：
-- ①：自己场上有「冰结界」怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的回合，自己不能把5星以上的怪兽特殊召唤。
-- ②：把这张卡解放，以「冰结界的传道师」以外的自己墓地1只「冰结界」怪兽为对象才能发动。那只怪兽特殊召唤。
function c50088247.initial_effect(c)
	-- ①：自己场上有「冰结界」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c50088247.spcon)
	e1:SetOperation(c50088247.spop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放，以「冰结界的传道师」以外的自己墓地1只「冰结界」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50088247,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(c50088247.spcost2)
	e2:SetTarget(c50088247.sptg2)
	e2:SetOperation(c50088247.spop2)
	c:RegisterEffect(e2)
	-- 创建一个计数器，用于记录玩家在该回合中特殊召唤的怪兽数量，且不计入5星以上的怪兽。
	Duel.AddCustomActivityCounter(50088247,ACTIVITY_SPSUMMON,c50088247.counterfilter)
end
-- 过滤函数：判断卡片是否等级低于5，用于计数器的条件判断。
function c50088247.counterfilter(c)
	return not c:IsLevelAbove(5)
end
-- 过滤函数：判断场上是否有「冰结界」卡面朝上存在。
function c50088247.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 特殊召唤条件函数：检查玩家在该回合未进行过特殊召唤，并且场上存在空位和「冰结界」怪兽。
function c50088247.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家在该回合是否已经进行过特殊召唤（若为0则表示未进行）。
	return Duel.GetCustomActivityCount(50088247,tp,ACTIVITY_SPSUMMON)==0
		-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家场上是否存在至少1只「冰结界」怪兽。
		and Duel.IsExistingMatchingCard(c50088247.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 创建并注册一个效果，使玩家在该回合不能特殊召唤5星以上的怪兽。
function c50088247.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 设置效果目标范围为对方玩家（1），表示该效果影响的是对方玩家的召唤行为。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c50088247.sumlimit)
	-- 将效果e1注册到玩家tp的场上。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤效果的目标函数：判断目标怪兽是否等级高于等于5。
function c50088247.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLevelAbove(5)
end
-- 起动效果的费用函数：检查并解放自身作为发动代价。
function c50088247.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 执行解放操作，将自身从游戏中移除作为发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数：判断墓地中的卡是否为「冰结界」且不是此卡本身，并可被特殊召唤。
function c50088247.filter(c,e,tp)
	return c:IsSetCard(0x2f) and not c:IsCode(50088247) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 起动效果的目标选择函数：检查玩家墓地中是否存在满足条件的「冰结界」怪兽。
function c50088247.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c50088247.filter(chkc,e,tp) end
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查玩家墓地是否存在至少1只符合条件的「冰结界」怪兽。
		and Duel.IsExistingTarget(c50088247.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从玩家墓地中选择一只满足条件的「冰结界」怪兽作为目标。
	local g=Duel.SelectTarget(tp,c50088247.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，表示本次效果将特殊召唤一只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 起动效果的处理函数：将选中的目标怪兽特殊召唤到场上。
function c50088247.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以特殊召唤方式送入场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
