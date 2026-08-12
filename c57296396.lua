--ネムレリア・ルーヴ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡·卡组把1只「妮穆蕾莉娅」怪兽或兽族·10星怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
-- ②：把墓地的这张卡除外，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时下降自己的除外状态的里侧的卡数量×100。
local s,id,o=GetID()
-- 初始化卡片效果：注册①手卡·卡组特召怪兽及结束阶段回手效果，以及②墓地除外自身使对方怪兽攻防下降效果。
function s.initial_effect(c)
	-- ①：从手卡·卡组把1只「妮穆蕾莉娅」怪兽或兽族·10星怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时下降自己的除外状态的里侧的卡数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+o)
	-- 限制效果2在伤害步骤中，仅在伤害计算前可以发动。
	e2:SetCondition(aux.dscon)
	-- 将墓地的这张卡除外作为效果2的发动代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.stattg)
	e2:SetOperation(s.statop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡·卡组中可以守备表示特殊召唤的「妮穆蕾莉娅」怪兽或10星兽族怪兽。
function s.spfilter(c,e,tp)
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) then return false end
	return c:IsSetCard(0x191) or (c:IsLevel(10) and c:IsRace(RACE_BEAST))
end
-- 效果1的发动准备：检查己方怪兽区域是否有空位，以及手卡·卡组是否存在可特召的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在至少1只满足特召条件的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息：从手卡或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果1的效果处理：从手卡·卡组选择1只符合条件的怪兽守备表示特殊召唤，并注册在结束阶段回到手卡的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时己方场上没有可用的怪兽区域空格，则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡或卡组选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	-- 若成功选择怪兽，则将其以表侧守备表示特殊召唤。
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		local tc=g:GetFirst()
		if not tc:IsLocation(LOCATION_MZONE) then return end
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段回到手卡。②：把墓地的这张卡除外，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时下降自己的除外状态的里侧的卡数量×100。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.thcon)
		e1:SetOperation(s.thop)
		-- 注册全局延迟效果，用于在结束阶段将特召的怪兽送回手卡。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 延迟效果的触发条件：检查目标怪兽是否仍带有对应的标记，若标记不符则重置该效果。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else
		return true
	end
end
-- 延迟效果的处理：将目标怪兽送回持有者手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽因效果送回手卡。
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
-- 过滤条件：对方场上表侧表示且攻击力或守备力大于0的怪兽。
function s.atkfilter(c)
	return c:IsFaceup() and (c:GetAttack()>0 or c:GetDefense()>0)
end
-- 效果2的发动准备：检查自身除外状态的里侧卡数量，并选择对方场上1只表侧表示怪兽作为对象。
function s.stattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查己方除外状态的卡中是否存在至少1张里侧表示的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_REMOVED,0,1,nil)
		-- 检查对方场上是否存在至少1只满足条件的表侧表示怪兽。
		and Duel.IsExistingTarget(s.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择对方场上1只表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,s.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果2的效果处理：计算己方里侧除外卡数量，使作为对象的怪兽的攻击力·守备力直到回合结束时下降该数量×100。
function s.statop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 获取己方除外状态的里侧表示的卡片数量。
		local ct=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)
		if ct==0 then return end
		local val=ct*-100
		-- 那只怪兽的攻击力直到回合结束时下降自己的除外状态的里侧的卡数量×100。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
