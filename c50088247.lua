--氷結界の伝道師
-- 效果：
-- ①：自己场上有「冰结界」怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的回合，自己不能把5星以上的怪兽特殊召唤。
-- ②：把这张卡解放，以「冰结界的传道师」以外的自己墓地1只「冰结界」怪兽为对象才能发动。那只怪兽特殊召唤。
function c50088247.initial_effect(c)
	-- ①：自己场上有「冰结界」怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的回合，自己不能把5星以上的怪兽特殊召唤。
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
	-- 注册本卡专用的特殊召唤活动计数器（counter_id=50088247），用于记录本回合是否进行过5星以上怪兽的特殊召唤，以便①效果的自肃进行限制。
	Duel.AddCustomActivityCounter(50088247,ACTIVITY_SPSUMMON,c50088247.counterfilter)
end
-- 计数器过滤函数：当被特殊召唤的怪兽是5星以上时，该特殊召唤会计入计数器（返回false）；返回true表示不计数，即5星以下的特殊召唤不受限制。
function c50088247.counterfilter(c)
	return not c:IsLevelAbove(5)
end
-- 判断怪兽是否表侧表示且卡名属于「冰结界」系列（setcode 0x2f），用于检查己方场上是否存在「冰结界」怪兽。
function c50088247.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- ①规则特殊召唤（EFFECT_SPSUMMON_PROC）的条件：若查询特殊召唤手续本身则直接允许；否则需满足：本回合未特殊召唤过5星以上怪兽、己方主要怪兽区有空位、且己方场上有表侧表示的「冰结界」怪兽。
function c50088247.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自定义计数器中本回合己方进行5星以上特殊召唤的次数为0（尚未进行过5星以上特殊召唤）。
	return Duel.GetCustomActivityCount(50088247,tp,ACTIVITY_SPSUMMON)==0
		-- 检查己方主要怪兽区存在可用空格，确保有位置特殊召唤此卡。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方场上有至少1张表侧表示的「冰结界」怪兽（不取对象，仅作为条件判定）。
		and Duel.IsExistingMatchingCard(c50088247.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的特殊召唤成功后的处理：给自己施加一个自肃效果，该效果在结束阶段重置，限制本回合不能特殊召唤5星以上的怪兽。
function c50088247.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法特殊召唤的回合，自己不能把5星以上的怪兽特殊召唤。②：把这张卡解放，以「冰结界的传道师」以外的自己墓地1只「冰结界」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c50088247.sumlimit)
	-- 将自肃效果 e1 注册到玩家 tp，使该效果对 tp 生效。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃过滤函数：若特殊召唤的怪兽等级为5星以上，则禁止该特殊召唤。
function c50088247.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLevelAbove(5)
end
-- ②效果发动代价的判定：check时确认这张卡是否可以被解放，若可以则返回 true 以允许发动。
function c50088247.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放作为发动②效果的代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 墓地对象过滤：对象必须是「冰结界」怪兽、不是「冰结界的传道师」自身、并且可以被当前效果特殊召唤。
function c50088247.filter(c,e,tp)
	return c:IsSetCard(0x2f) and not c:IsCode(50088247) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件与对象选择：若 chkc 指定了对象则校验该对象是否合法；发动时需确认己方主要怪兽区可用空格数>-1（解放此卡后必定有空格）且墓地存在符合条件的「冰结界」怪兽。
function c50088247.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c50088247.filter(chkc,e,tp) end
	-- 检查己方主要怪兽区可用空格数大于-1（这张卡解放后必然空出一个位置，因此允许满场时发动）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查墓地是否存在满足 c50088247.filter 条件的「冰结界」怪兽，且能成为效果对象。
		and Duel.IsExistingTarget(c50088247.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作者显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1张符合条件的「冰结界」怪兽作为效果对象（取对象），并建立该对象与当前连锁的关联。
	local g=Duel.SelectTarget(tp,c50088247.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本次效果处理将把对象 g 特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：取出对象怪兽，若对象仍与效果关联，则将其以表侧表示特殊召唤到自己场上。
function c50088247.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中第一个效果对象（墓地中选择的「冰结界」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上，规则上不视为正规召唤（苏生限制已由 filter 中的 IsCanBeSpecialSummoned 检查）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
