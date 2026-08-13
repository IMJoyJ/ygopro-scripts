--ヴァンパイア・グリムゾン
-- 效果：
-- ①：自己场上的怪兽被战斗或者对方的效果破坏的场合，可以作为代替而支付那些破坏的怪兽数量×1000基本分。
-- ②：这张卡战斗破坏怪兽的战斗阶段结束时才能发动。那些怪兽从墓地尽可能往自己场上特殊召唤。
function c33438666.initial_effect(c)
	-- ①：自己场上的怪兽被战斗或者对方的效果破坏的场合，可以作为代替而支付那些破坏的怪兽数量×1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c33438666.reptg)
	e1:SetValue(c33438666.repval)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽的
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetOperation(c33438666.regop)
	c:RegisterEffect(e2)
	-- 战斗阶段结束时才能发动。那些怪兽从墓地尽可能往自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33438666,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c33438666.spcon)
	e3:SetTarget(c33438666.sptg)
	e3:SetOperation(c33438666.spop)
	c:RegisterEffect(e3)
end
-- 定义过滤条件：判定怪兽是否为本方场上被战斗或对方效果破坏且未被代替的正面怪兽（满足表侧、控制者为自己、位于怪兽区、破坏原因为战斗或对方效果且非代替破坏）。
function c33438666.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
		and not c:IsReason(REASON_REPLACE)
end
-- ①效果的代替破坏处理入口：计算被破坏怪兽数量并获得支付确认，若玩家同意则支付LP并允许代替破坏。
function c33438666.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(c33438666.repfilter,nil,tp)
	-- 检查是否存在符合条件的破坏怪兽且己方足够支付对应数量×1000LP，作为代替破坏发动是否合法的前提。
	if chk==0 then return ct>0 and Duel.CheckLPCost(tp,1000*ct) end
	-- 弹出确认框，让己方玩家决定是否支付LP来发动代替破坏效果。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 实际支付对应数量×1000的基本分，完成代替破坏的代价。
		Duel.PayLPCost(tp,1000*ct)
		return true
	else return false end
end
-- 代替破坏效果的Value判定：对每只将被破坏的怪兽，返回是否满足代替破坏条件，满足则其破坏被代替。
function c33438666.repval(e,c)
	return c33438666.repfilter(c,e:GetHandlerPlayer())
end
-- 在红死神战斗破坏怪兽时，为该卡注册一个flag标记，标记在战斗阶段结束时清除，用于记录本回合发生过战斗破坏。
function c33438666.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(33438666,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- ②效果的发动条件：红死神身上存在33438666号flag，即本回合它战斗破坏过怪兽。
function c33438666.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(33438666)~=0
end
-- 定义②效果可选的特殊召唤对象条件：墓地中由红死神战斗破坏、破坏回合为当前回合、且可以合法特殊召唤的怪兽。
function c33438666.spfilter(c,e,tp,rc,tid)
	return c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc and c:GetTurnID()==tid
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时的目标检查与操作信息登记：确认场上空位和墓地候选，并将候选组写入连锁信息，供后续处理。
function c33438666.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否留有可用的怪兽区域空格，无空位则不能发动特殊召唤效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只由红死神战斗破坏且可特殊召唤的怪兽，满足发动条件。
		and Duel.IsExistingMatchingCard(c33438666.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,e:GetHandler(),Duel.GetTurnCount()) end
	-- 效果发动后，从双方墓地中检索全部符合【由红死神战斗破坏、本回合被破坏且可特殊召唤】条件的怪兽，作为候选组。
	local g=Duel.GetMatchingGroup(c33438666.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	-- 为本次连锁登记特殊召唤的操作信息，将候选组g标记为可能被特殊召唤的对象，供相关卡（如星尘龙）判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的实际处理：根据空位数量尽可能多地从墓地特殊召唤符合条件的怪兽；若候选数量超过空位则由玩家选择，最终将选择对象表侧特殊召唤到自己场上。
function c33438666.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方可用的怪兽区空格数ft，决定本次特殊召唤的数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 检索墓地所有满足②条件的怪兽，并用王家长眠之谷效果进行过滤，得到可特殊召唤的完整候选组tg。
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c33438666.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	local g=nil
	if tg:GetCount()>ft then
		-- 显示选择提示文字，要求玩家从候选组中选出要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=tg:Select(tp,ft,ft,nil)
	else
		g=tg
	end
	if g:GetCount()>0 then
		-- 将最终确定的怪兽组g以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
