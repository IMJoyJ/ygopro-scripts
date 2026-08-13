--剣闘獣ディカエリィ
-- 效果：
-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功的场合，这张卡在同1次的战斗阶段中可以作2次攻击。这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 双斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
function c31247589.initial_effect(c)
	-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功的场合，这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetCondition(c31247589.dacon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 双斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31247589,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c31247589.spcon)
	e2:SetCost(c31247589.spcost)
	e2:SetTarget(c31247589.sptg)
	e2:SetOperation(c31247589.spop)
	c:RegisterEffect(e2)
end
-- 作为追加攻击效果的条件：检查这张卡是否带有编号31247589的标识，即是否已经通过名字带有「剑斗兽」的怪兽的效果特殊召唤成功。
function c31247589.dacon(e)
	return e:GetHandler():GetFlagEffect(31247589)>0
end
-- 作为战斗阶段结束时发动效果的条件：检查这张卡在本回合是否进行过战斗（与任何怪兽进行过战斗的次数大于0）。
function c31247589.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 发动代价的检测与执行：确认这张卡可以作为代价返回卡组，然后将这张卡返回持有者卡组并洗切，作为发动后续特殊召唤效果的费用。
function c31247589.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 执行代价操作：将这张卡送入卡组并洗牌（以REASON_COST作为代价送去卡组）。
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 筛选特殊召唤对象：要求卡名不是「剑斗兽 双斗」、是名字带有「剑斗兽」的怪兽，并且可以被玩家tp以当前效果特殊召唤。
function c31247589.filter(c,e,tp)
	return not c:IsCode(31247589) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件检查：由于代价会将自身送回卡组，因此不强制发动时已有空位；同时确认卡组中存在至少1只符合条件的「剑斗兽」怪兽可供特殊召唤。
function c31247589.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检查（chk==0时）自己场上是否有可供特殊召唤的区域；因自身会作为代价离开场上，所以允许当前可用区域为0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 在发动前检查卡组中是否存在至少1张满足filter条件的「剑斗兽」怪兽，作为效果能否发动的必要条件。
		and Duel.IsExistingMatchingCard(c31247589.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：声明本次效果包含特殊召唤，预期从卡组特殊召唤1只怪兽，具体对象在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果处理：若自己场上没有可用区域则终止；否则提示玩家选择卡组中符合条件的1只「剑斗兽」怪兽，将其表侧表示特殊召唤，并给该怪兽注册“通过剑斗兽效果特殊召唤成功”的标识，以便其追加攻击等效果使用。
function c31247589.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时检查：如果自己场上没有可用的怪兽区域，则特殊召唤不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家发送选择提示消息，提示其正在选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的卡组中选择1张满足filter条件的「剑斗兽 双斗」以外的剑斗兽怪兽，作为特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c31247589.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的主要怪兽区，并正常检查该怪兽的召唤限制和苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
