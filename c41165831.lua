--破械神シャバラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，自己·对方的主要阶段，以自己场上1只恶魔族怪兽或1张里侧表示卡为对象才能发动。那张卡破坏，这张卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是恶魔族怪兽不能特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把1张「破械」魔法·陷阱卡在自己场上盖放。
function c41165831.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，自己·对方的主要阶段，以自己场上1只恶魔族怪兽或1张里侧表示卡为对象才能发动。那张卡破坏，这张卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是恶魔族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,41165831)
	e1:SetCondition(c41165831.spdcon)
	e1:SetTarget(c41165831.spdtg)
	e1:SetOperation(c41165831.spdop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。从卡组把1张「破械」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,41165832)
	e2:SetTarget(c41165831.settg)
	e2:SetOperation(c41165831.setop)
	c:RegisterEffect(e2)
end
-- 判断当前是否为自己的主要阶段1或主要阶段2
function c41165831.spdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己的主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤函数，用于判断目标是否为自己的场上怪兽且为恶魔族或自己的里侧表示卡，并且自己场上存在可用怪兽区
function c41165831.desfilter(c,tp)
	return (c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_FIEND) or c:IsFacedown())
		-- 判断自己场上是否存在可用怪兽区
		and Duel.GetMZoneCount(tp,c)>0
end
-- 设置效果的目标选择函数，用于选择满足条件的目标卡
function c41165831.spdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c41165831.desfilter(chkc,tp) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断是否满足发动条件，即自己场上存在满足条件的目标卡且自身可以特殊召唤
		and Duel.IsExistingTarget(c41165831.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的目标卡
	local g=Duel.SelectTarget(tp,c41165831.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置操作信息，记录将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，记录将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理函数，执行破坏和特殊召唤操作，并设置后续限制
function c41165831.spdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然存在于场上并成功破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 判断自身是否仍然存在于场上并成功特殊召唤
		and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 创建一个永续效果，限制自己不能特殊召唤非恶魔族怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c41165831.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
end
-- 限制效果的目标函数，限制非恶魔族怪兽不能特殊召唤
function c41165831.splimit(e,c)
	return not c:IsRace(RACE_FIEND)
end
-- 过滤函数，用于判断卡组中是否存在满足条件的「破械」魔法或陷阱卡
function c41165831.setfilter(c)
	return c:IsSetCard(0x130) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 设置效果的目标选择函数，用于选择满足条件的「破械」魔法或陷阱卡
function c41165831.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即自己卡组中存在满足条件的「破械」魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c41165831.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理函数，从卡组选择一张「破械」魔法或陷阱卡并盖放
function c41165831.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择一张满足条件的「破械」魔法或陷阱卡
	local g=Duel.SelectMatchingCard(tp,c41165831.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡盖放到场上
		Duel.SSet(tp,g)
	end
end
