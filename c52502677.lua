--剣闘獣アトリクス
-- 效果：
-- ①：这张卡用「剑斗兽」怪兽的效果特殊召唤成功的场合，从卡组·额外卡组把「剑斗兽 女斗」以外的1只「剑斗兽」怪兽送去墓地才能发动。直到结束阶段，这张卡变成和送去墓地的怪兽相同等级，当作同名卡使用。
-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 女斗」以外的1只「剑斗兽」怪兽特殊召唤。
function c52502677.initial_effect(c)
	-- ①：这张卡用「剑斗兽」怪兽的效果特殊召唤成功的场合，从卡组·额外卡组把「剑斗兽 女斗」以外的1只「剑斗兽」怪兽送去墓地才能发动。直到结束阶段，这张卡变成和送去墓地的怪兽相同等级，当作同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52502677,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	-- 设置效果1的发动条件：使用剑斗兽通用判定函数，要求这张卡是通过「剑斗兽」怪兽的效果特殊召唤成功的场合。
	e1:SetCondition(aux.gbspcon)
	e1:SetCost(c52502677.cost)
	e1:SetOperation(c52502677.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 女斗」以外的1只「剑斗兽」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52502677,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c52502677.spcon)
	e2:SetCost(c52502677.spcost)
	e2:SetTarget(c52502677.sptg)
	e2:SetOperation(c52502677.spop)
	c:RegisterEffect(e2)
end
-- cost的筛选函数：从卡组·额外卡组中选择「剑斗兽」怪兽，要求不是「剑斗兽 女斗」、不是发动效果者自身、是怪兽且等级1以上、并可以作为代价送去墓地。
function c52502677.costfilter(c,ec)
	return c:IsSetCard(0x1019) and not c:IsCode(52502677) and not c:IsCode(ec:GetCode()) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(1) and c:IsAbleToGraveAsCost()
end
-- 效果1的cost判定与执行：先确认存在可选择的代价卡，然后让玩家选择1张符合条件的「剑斗兽」怪兽作为代价送去墓地，并将其保存到效果的LabelObject中，供处理阶段使用。
function c52502677.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在cost检测阶段，检查卡组·额外卡组中是否存在至少1张满足costfilter条件的「剑斗兽」怪兽，以判定能否支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c52502677.costfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,c) end
	-- 显示“请选择要送去墓地的卡”的选择提示，引导玩家选择要作为代价的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让当前玩家从自己的卡组·额外卡组中选出1张满足costfilter条件的「剑斗兽」怪兽，作为将要送去墓地的代价。
	local cg=Duel.SelectMatchingCard(tp,c52502677.costfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,c)
	-- 将选中的卡以代价原因送去墓地，完成cost支付。
	Duel.SendtoGrave(cg,REASON_COST)
	e:SetLabelObject(cg:GetFirst())
end
-- 效果1处理：读取cost阶段保存的怪兽的卡名与等级；若发动效果的本体仍与效果关联且表侧表示，则给它附加两个持续到结束阶段的效果：卡名变为与送去墓地的怪兽相同、等级变为与该怪兽相同。
function c52502677.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	local code=tc:GetCode()
	local lv=tc:GetLevel()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 当作同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(code)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_LEVEL)
	e2:SetValue(lv)
	c:RegisterEffect(e2)
end
-- 效果2的发动条件：判断这张卡在本战斗阶段是否进行过战斗（与其他怪兽进行过战斗）。
function c52502677.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 效果2的cost判定与执行：确认这张卡可以作为代价返回卡组，然后将它返回持有者卡组并洗牌。
function c52502677.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 以代价原因将这张卡弹回持有者卡组，并触发洗牌（返回卡组后洗牌）。
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 特殊召唤对象的筛选函数：不是「剑斗兽 女斗」、是「剑斗兽」怪兽，并且可以被当前效果特殊召唤。
function c52502677.filter(c,e,tp)
	return not c:IsCode(52502677) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的发动目标判定：需要自己场上有空余怪兽区，且卡组中存在至少1只符合filter条件的「剑斗兽」怪兽。
function c52502677.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在cost检测阶段确认自己场上存在可用的怪兽区（发动时需保证处理时能特殊召唤）。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 同时确认卡组中存在至少1只可以特殊召唤的「剑斗兽」怪兽。
		and Duel.IsExistingMatchingCard(c52502677.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：声明本效果将进行1只怪兽从卡组的特殊召唤，供相关卡片（如星尘龙等）进行发动/无效判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果2的解决处理：若场上仍有空位，让玩家从卡组选择1只符合条件的「剑斗兽」怪兽并表侧表示特殊召唤，同时给该怪兽注册一个以原卡号为编号的flag标记。
function c52502677.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上已没有可用怪兽区，则不执行特殊召唤处理，直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示，引导玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让当前玩家从自己的卡组中选出1张满足filter条件的「剑斗兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c52502677.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上，该特殊召唤遵循召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
