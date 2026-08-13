--死霊操りしパペットマスター
-- 效果：
-- ①：这张卡上级召唤成功时，支付2000基本分，以自己墓地2只恶魔族怪兽为对象才能发动。那些恶魔族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c41442341.initial_effect(c)
	-- ①：这张卡上级召唤成功时，支付2000基本分，以自己墓地2只恶魔族怪兽为对象才能发动。那些恶魔族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41442341,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c41442341.spcon)
	e1:SetCost(c41442341.spcost)
	e1:SetTarget(c41442341.sptg)
	e1:SetOperation(c41442341.spop)
	c:RegisterEffect(e1)
end
-- 发动条件：这张卡以表侧表示上级召唤成功时（召唤类型为上级召唤）才可发动。
function c41442341.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 发动代价处理：先检查能否支付2000基本分，可以则支付2000基本分作为发动代价。
function c41442341.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认当前玩家能否支付2000LP，若不能则效果无法发动。
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 实际支付：扣除当前玩家2000LP作为发动代价。
	Duel.PayLPCost(tp,2000)
end
-- 对象过滤：选择自己墓地中种族为恶魔族且可以被效果特殊召唤的怪兽作为对象。
function c41442341.filter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择与发动条件判定：从自己墓地选择2只恶魔族怪兽作为取对象目标，同时需满足场上空位足够且不受【青眼精灵龙】限制。
function c41442341.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c41442341.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 场地检测：自己的主要怪兽区域空位数必须大于1，才能同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 对象存在性检查：确认自己墓地存在至少2只符合过滤条件的恶魔族怪兽可选择。
		and Duel.IsExistingTarget(c41442341.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 显示选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择2只恶魔族怪兽，并将其设为这次效果的取对象目标。
	local g=Duel.SelectTarget(tp,c41442341.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设置操作信息：声明本次效果将特殊召唤2只对象怪兽，用于连锁处理和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果处理：筛选仍与效果关联的对象，在场地空位及【青眼精灵龙】限制允许的条件下逐只特殊召唤，并赋予本回合不能攻击的效果，最后完成特殊召唤。
function c41442341.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的主要怪兽区域空格数，用于判断能否特殊召唤及可召唤数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 取得当前连锁的对象卡组，即发动时选择作为对象的墓地怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local fg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if fg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 如果可用空格不足导致只能特殊召唤1只时，让玩家选择具体要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	if fg:GetCount()>1 and ft==1 then fg=fg:Select(tp,1,1,nil) end
	local tc=fg:GetFirst()
	while tc do
		-- 进行特殊召唤步骤：将一只对象怪兽以表侧表示特殊召唤到自己的主要怪兽区域。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=fg:GetNext()
	end
	-- 结束特殊召唤步骤，触发特殊召唤成功后的时点处理。
	Duel.SpecialSummonComplete()
end
