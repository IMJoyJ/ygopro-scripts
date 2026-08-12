--SDロボ・エレファン
-- 效果：
-- 这张卡召唤成功时，可以从手卡把1只名字带有「超级防卫机器人」的怪兽或者「轨道 7」特殊召唤。1回合1次，选择自己场上1只名字带有「超级防卫机器人」的怪兽或者「轨道 7」才能发动。选择的怪兽的等级直到结束阶段时变成8星。此外，把这张卡作为超量召唤的素材的场合，不是机械族怪兽的超量召唤不能使用。
function c45496268.initial_effect(c)
	-- 这张卡召唤成功时，可以从手卡把1只名字带有「超级防卫机器人」的怪兽或者「轨道 7」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45496268,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c45496268.sumtg)
	e1:SetOperation(c45496268.sumop)
	c:RegisterEffect(e1)
	-- 1回合1次，选择自己场上1只名字带有「超级防卫机器人」的怪兽或者「轨道 7」才能发动。选择的怪兽的等级直到结束阶段时变成8星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45496268,1))  --"等级变化"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c45496268.lvtg)
	e2:SetOperation(c45496268.lvop)
	c:RegisterEffect(e2)
	-- 此外，把这张卡作为超量召唤的素材的场合，不是机械族怪兽的超量召唤不能使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(c45496268.xyzlimit)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断手卡中是否满足条件的「超级防卫机器人」怪兽或「轨道 7」
function c45496268.filter(c,e,tp)
	return (c:IsSetCard(0x85) or c:IsCode(71071546)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤条件，包括场上是否有空位和手卡中是否存在符合条件的怪兽
function c45496268.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c45496268.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行特殊召唤操作，选择并特殊召唤符合条件的怪兽
function c45496268.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c45496268.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断场上是否满足条件的「超级防卫机器人」怪兽或「轨道 7」
function c45496268.lvfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x85) or c:IsCode(71071546)) and not c:IsLevel(8) and c:IsLevelAbove(1)
end
-- 设置等级变化效果的目标选择函数，用于选择符合条件的怪兽
function c45496268.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c45496268.lvfilter(chkc) end
	-- 判断场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c45496268.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的怪兽作为等级变化效果的目标
	Duel.SelectTarget(tp,c45496268.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行等级变化效果，将目标怪兽等级变为8星
function c45496268.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 创建等级变化效果，使目标怪兽等级变为8星，并在结束阶段重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 判断是否为机械族怪兽，用于限制非机械族怪兽作为超量素材
function c45496268.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_MACHINE)
end
