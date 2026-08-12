--クラリアの蟲惑魔
-- 效果：
-- 昆虫族·植物族怪兽2只
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：连接召唤的这张卡不受陷阱卡的效果影响。
-- ②：只要这张卡在怪兽区域存在，自己发动的「洞」通常陷阱卡以及「落穴」通常陷阱卡在发动后可以不送去墓地直接盖放。
-- ③：自己结束阶段，以自己墓地1只「虫惑魔」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c952523.initial_effect(c)
	-- 设置连接召唤的手续，需要2只昆虫族或植物族怪兽作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_INSECT+RACE_PLANT),2,2)
	c:EnableReviveLimit()
	-- ①：连接召唤的这张卡不受陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c952523.imcon)
	e1:SetValue(c952523.efilter)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己发动的「洞」通常陷阱卡以及「落穴」通常陷阱卡在发动后可以不送去墓地直接盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c952523.setcon)
	e2:SetOperation(c952523.setop)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段，以自己墓地1只「虫惑魔」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(952523,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,952523)
	e3:SetCondition(c952523.spcon)
	e3:SetTarget(c952523.sptg)
	e3:SetOperation(c952523.spop)
	c:RegisterEffect(e3)
end
-- 判定自身是否为连接召唤，用于不受陷阱效果影响的条件判定
function c952523.imcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤不受影响的效果类型，此处为陷阱卡的效果
function c952523.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
-- 判定是否满足将发动的「洞」或「落穴」通常陷阱卡直接盖放的条件
function c952523.setcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 判定本回合是否未使用过该效果，且当前处理的连锁是由自己发动的陷阱卡
	return Duel.GetFlagEffect(tp,952523)==0 and rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
		and rc:GetType()==TYPE_TRAP and rc:IsRelateToEffect(re) and rc:IsCanTurnSet() and rc:IsStatus(STATUS_LEAVE_CONFIRMED) and rc:IsSetCard(0x4c,0x89)
end
-- 执行将发动的「洞」或「落穴」通常陷阱卡不送去墓地直接盖放的处理
function c952523.setop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 询问玩家是否选择不送去墓地而直接盖放
	if Duel.SelectEffectYesNo(tp,rc,aux.Stringid(952523,1)) then  --"是否不送去墓地而盖放？"
		rc:CancelToGrave()
		-- 将该陷阱卡转为里侧表示（盖放）
		Duel.ChangePosition(rc,POS_FACEDOWN)
		-- 触发“卡片被盖放”的时点事件
		Duel.RaiseEvent(rc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
		-- 为玩家注册本回合已使用该效果的标识，确保一回合只能使用一次
		Duel.RegisterFlagEffect(tp,952523,RESET_PHASE+PHASE_END,0,0)
	end
end
-- 判定是否为自己的结束阶段，用于特殊召唤效果的发动条件判定
function c952523.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 过滤墓地中可以特殊召唤的「虫惑魔」怪兽
function c952523.spfilter(c,e,tp)
	return c:IsSetCard(0x108a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的靶向选择与发动准备
function c952523.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c952523.spfilter(chkc,e,tp) end
	-- 判定自己场上是否有空位，且墓地中是否存在合法的「虫惑魔」怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c952523.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中1只「虫惑魔」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c952523.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息，表示该效果包含特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行将墓地的「虫惑魔」怪兽守备表示特殊召唤的处理
function c952523.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选定的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
