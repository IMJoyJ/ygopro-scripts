--ヴァンパイア・スカージレット
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，支付1000基本分，以「吸血鬼·红灾星」以外的自己墓地1只「吸血鬼」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
-- ②：这张卡战斗破坏怪兽的战斗阶段结束时才能发动。那些怪兽从墓地尽可能往自己场上特殊召唤。
function c79523365.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，支付1000基本分，以「吸血鬼·红灾星」以外的自己墓地1只「吸血鬼」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79523365,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,79523365)
	e1:SetCost(c79523365.spcost1)
	e1:SetTarget(c79523365.sptg1)
	e1:SetOperation(c79523365.spop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏怪兽的战斗阶段结束时才能发动。那些怪兽从墓地尽可能往自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetOperation(c79523365.regop)
	c:RegisterEffect(e3)
	-- ②：这张卡战斗破坏怪兽的战斗阶段结束时才能发动。那些怪兽从墓地尽可能往自己场上特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(79523365,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c79523365.spcon2)
	e4:SetTarget(c79523365.sptg2)
	e4:SetOperation(c79523365.spop2)
	c:RegisterEffect(e4)
end
-- ①效果的Cost（支付1000基本分）判定与执行函数
function c79523365.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤自己墓地中「吸血鬼·红灾星」以外且可以特殊召唤的「吸血鬼」怪兽
function c79523365.spfilter1(c,e,tp)
	return c:IsSetCard(0x8e) and not c:IsCode(79523365) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与目标选择函数
function c79523365.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c79523365.spfilter1(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的「吸血鬼」怪兽
		and Duel.IsExistingTarget(c79523365.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「吸血鬼」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c79523365.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表示该效果包含特殊召唤该目标怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的效果处理（特殊召唤并施加不能攻击的限制）
function c79523365.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于墓地，则将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 战斗破坏怪兽时，为自身注册一个持续到战斗阶段结束的Flag，用于记录战斗破坏事件
function c79523365.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(79523365,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- ②效果的发动条件（检查自身是否注册了战斗破坏怪兽的Flag）
function c79523365.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(79523365)~=0
end
-- 过滤本回合被这张卡战斗破坏并送去墓地、且可以特殊召唤的怪兽
function c79523365.spfilter2(c,e,tp,rc,tid)
	return c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc and c:GetTurnID()==tid
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备与目标检查函数
function c79523365.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地是否存在至少1只被这张卡战斗破坏的怪兽
		and Duel.IsExistingMatchingCard(c79523365.spfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,e:GetHandler(),Duel.GetTurnCount()) end
	-- 获取双方墓地中所有被这张卡战斗破坏的怪兽
	local g=Duel.GetMatchingGroup(c79523365.spfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	-- 设置连锁信息，表示该效果包含特殊召唤这些怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的效果处理（尽可能特殊召唤被战斗破坏的怪兽）
function c79523365.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取双方墓地中不受「王家长眠之谷」影响的、被这张卡战斗破坏的怪兽
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c79523365.spfilter2),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	local g=nil
	if tg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=tg:Select(tp,ft,ft,nil)
	else
		g=tg
	end
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
