--DDD烈火大王エグゼクティブ・テムジン
-- 效果：
-- 5星以上的「DD」怪兽＋「DD」怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在怪兽区域存在的状态，自己场上有「DD」怪兽召唤·特殊召唤的场合，以自己墓地1只「DD」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：自己回合1次，魔法·陷阱卡的效果发动时才能发动。那个发动无效。
function c16006416.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加融合召唤手续：融合素材需要1只5星以上且可作为「DD」怪兽的素材和1只可作为「DD」怪兽的素材，实现效果原文的“5星以上的「DD」怪兽＋「DD」怪兽”。
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
-- 定义融合素材过滤器matfilter：返回满足“5星以上且作为融合素材时可当作「DD」怪兽”的卡片，用于筛选“5星以上的「DD」怪兽”。
function c16006416.matfilter(c)
	return c:IsFusionSetCard(0xaf) and c:IsLevelAbove(5)
end
-- 定义触发器过滤器cfilter：判断一张怪兽是否为表侧表示、卡名含「DD」字段且由tp控制，用于检测自己场上是否有「DD」怪兽召唤·特殊召唤成功。
function c16006416.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsControler(tp)
end
-- ①效果的发动条件：召唤·特殊召唤成功的怪兽中不包含这张卡自身，且包含至少1只满足cfilter的自己场上表侧表示「DD」怪兽，即符合“自己场上有「DD」怪兽召唤·特殊召唤的场合”。
function c16006416.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c16006416.cfilter,1,nil,tp)
end
-- 定义特殊召唤对象过滤器spfilter：对象在自己墓地、卡名含「DD」字段，并且能够被当前效果特殊召唤，保证墓地中的「DD」怪兽可以被特殊召唤。
function c16006416.spfilter(c,e,tp)
	return c:IsSetCard(0xaf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择函数sptg的前半部分：若已指定对象chkc，则验证该卡是否在自己墓地且满足spfilter；否则在发动确认chk==0时，检查主要怪兽区是否还有空位，以及墓地是否存在至少1只满足spfilter的「DD」怪兽可作为对象，从而判断能否发动。
function c16006416.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c16006416.spfilter(chkc,e,tp) end
	-- 发动确认时先检查自己主要怪兽区域是否存在空位，因为后续特殊召唤需要主要怪兽区的格子；若无空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 接着检查墓地是否存在至少1只满足spfilter且能够成为效果对象的「DD」怪兽，确保有对象可供选择，满足取对象条件。
		and Duel.IsExistingTarget(c16006416.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 进行对象选择时，向玩家显示“请选择要特殊召唤的卡”的提示，引导玩家从候选中选择墓地中的DD怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足spfilter的「DD」怪兽，并将其设置为当前连锁的对象（取对象操作）。
	local g=Duel.SelectTarget(tp,c16006416.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：声明本次效果将进行特殊召唤（CATEGORY_SPECIAL_SUMMON），对象为已选择的怪兽g，数量为1，供其他卡发动时参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的处理函数spop：取出之前选择的对象，若对象仍然与效果关联，则将该怪兽特殊召唤到自己的主要怪兽区。
function c16006416.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的对象卡，即从墓地选出的「DD」怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以表侧表示将对象怪兽特殊召唤到自己场上，完成“那只怪兽特殊召唤”的效果处理。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件函数negcon：判断是否为自己回合、当前发动的是否为魔法·陷阱卡的效果，以及该连锁的发动是否可被无效。
function c16006416.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件具体为：当前回合玩家是自己，且连锁中的效果属于魔法/陷阱卡，并且该连锁的发动能够被无效，三者同时满足才可发动②效果。
	return Duel.GetTurnPlayer()==tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- ②效果的目标选择函数negtg：本效果不需要选择对象，chk==0时直接允许发动；同时设置操作信息，声明本次效果要无效当前连锁。
function c16006416.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将当前连锁的发动（eg）设为要无效的对象，类别为CATEGORY_NEGATE，数量为1，以便相关卡响应此无效效果。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ②效果的处理函数negop：执行无效操作，使那次魔法·陷阱卡的发动无效化，实现“那个发动无效”。
function c16006416.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 调用NegateActivation无效连锁编号ev对应的那次发动，完成实际无效处理。
	Duel.NegateActivation(ev)
end
