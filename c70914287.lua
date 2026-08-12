--クリバビロン
-- 效果：
-- 这个卡名的①③的效果1回合只能有1次使用其中任意1个。
-- ①：自己墓地的怪兽数量比对方墓地的怪兽多的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的攻击力·守备力上升自己的场上·墓地的「栗子球」怪兽数量×300。
-- ③：自己的主要阶段以及战斗阶段才能发动。这张卡回到持有者手卡，从自己的手卡·墓地选「栗子丸」「栗子团」「栗子圆」「栗子珠」「栗子球」各1只攻击表示特殊召唤。
function c70914287.initial_effect(c)
	-- 注册卡片效果中记载的特定卡片密码（栗子丸、栗子团、栗子圆、栗子珠、栗子球）。
	aux.AddCodeList(c,44632120,71036835,7021574,34419588,40640057)
	-- ①：自己墓地的怪兽数量比对方墓地的怪兽多的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70914287,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,70914287)
	e1:SetCondition(c70914287.spcon1)
	e1:SetTarget(c70914287.sptg1)
	e1:SetOperation(c70914287.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力·守备力上升自己的场上·墓地的「栗子球」怪兽数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(c70914287.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：自己的主要阶段以及战斗阶段才能发动。这张卡回到持有者手卡，从自己的手卡·墓地选「栗子丸」「栗子团」「栗子圆」「栗子珠」「栗子球」各1只攻击表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(70914287,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,70914287)
	e4:SetTarget(c70914287.sptg2)
	e4:SetOperation(c70914287.spop2)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetCondition(c70914287.spcon2)
	c:RegisterEffect(e5)
end
-- 创建用于检查是否包含「栗子丸」「栗子团」「栗子圆」「栗子珠」「栗子球」各1张的条件检查函数数组。
c70914287.spchecks=aux.CreateChecks(Card.IsCode,{44632120,71036835,7021574,34419588,40640057})
-- 效果①的特殊召唤发动条件函数。
function c70914287.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己墓地的怪兽数量是否比对方墓地的怪兽数量多。
	return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)>Duel.GetMatchingGroupCount(Card.IsType,1-tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
end
-- 效果①的特殊召唤发动准备与目标检查函数。
function c70914287.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息，表示将特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的特殊召唤处理执行函数。
function c70914287.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤场上表侧表示及墓地中「栗子球」怪兽的条件函数。
function c70914287.atkfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0xa4) and c:IsType(TYPE_MONSTER)
end
-- 计算攻击力·守备力上升数值的函数。
function c70914287.atkval(e)
	-- 返回自己场上·墓地的「栗子球」怪兽数量乘以300的数值。
	return Duel.GetMatchingGroupCount(c70914287.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,0,nil)*300
end
-- 效果③在战斗阶段作为诱发即时效果发动的条件函数。
function c70914287.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 限制必须在自己的回合且不在连锁中（自由时点）才能发动。
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentChain()==0
		and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 过滤手卡·墓地中可以攻击表示特殊召唤的「栗子丸」「栗子团」「栗子圆」「栗子珠」「栗子球」的条件函数。
function c70914287.spfilter(c,e,tp)
	return c:IsCode(44632120,71036835,7021574,34419588,40640057) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果③的发动准备与目标检查函数。
function c70914287.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己手卡·墓地中满足特殊召唤条件的特定怪兽卡组。
	local g=Duel.GetMatchingGroup(c70914287.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return c:IsAbleToHand() and Duel.GetMZoneCount(tp,c)>=5 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and g:CheckSubGroupEach(c70914287.spchecks) end
	-- 设置连锁处理中的操作信息，表示将这张卡回到手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置连锁处理中的操作信息，表示将从手卡·墓地特殊召唤5只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,5,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果③的处理执行函数。
function c70914287.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍适用效果，并将其送回手卡，确认成功回到手卡。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=5 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 获取手卡·墓地中满足条件且不受「王家长眠之谷」影响的特定怪兽卡组。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c70914287.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
		-- 给玩家发送选择特殊召唤卡片的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:SelectSubGroupEach(tp,c70914287.spchecks,false)
		if sg then
			-- 将选出的5只怪兽以攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		end
	end
end
