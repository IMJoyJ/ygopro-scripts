--RR－ラスト・ストリクス
-- 效果：
-- 「急袭猛禽-残存林鸮」的②的效果1回合只能使用1次。
-- ①：自己的「急袭猛禽」怪兽进行战斗的伤害计算时才能发动。这张卡从手卡特殊召唤。那之后，自己回复自己的场上·墓地的魔法·陷阱卡数量×100基本分。
-- ②：把这张卡解放才能发动。从额外卡组把1只「急袭猛禽」超量怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段回到额外卡组。这个回合对方受到的战斗伤害变成0。
function c97219708.initial_effect(c)
	-- ①：自己的「急袭猛禽」怪兽进行战斗的伤害计算时才能发动。这张卡从手卡特殊召唤。那之后，自己回复自己的场上·墓地的魔法·陷阱卡数量×100基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97219708,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c97219708.reccon)
	e1:SetTarget(c97219708.rectg)
	e1:SetOperation(c97219708.recop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。从额外卡组把1只「急袭猛禽」超量怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段回到额外卡组。这个回合对方受到的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97219708,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,97219708)
	e2:SetCost(c97219708.spcost)
	e2:SetTarget(c97219708.sptg)
	e2:SetOperation(c97219708.spop)
	c:RegisterEffect(e2)
end
-- 判断进行战斗的怪兽是否为自己场上的「急袭猛禽」怪兽
function c97219708.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local at=Duel.GetAttackTarget()
	return (tc:IsControler(tp) and tc:IsSetCard(0xba)) or (at and at:IsControler(tp) and at:IsSetCard(0xba))
end
-- 检查自身是否能特殊召唤，以及场上或墓地是否存在魔法·陷阱卡
function c97219708.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果的准备阶段，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and not e:GetHandler():IsStatus(STATUS_CHAINING) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己的场上或墓地是否存在至少1张魔法或陷阱卡
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 计算自己的场上以及墓地的魔法·陷阱卡的总数量
	local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置连锁处理中的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置连锁处理中的操作信息：自己回复数量×100的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*100)
end
-- 执行将自身特殊召唤，并根据场上·墓地的魔陷数量回复基本分的效果处理
function c97219708.recop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡在自己场上表侧表示特殊召唤，若特殊召唤成功则继续处理
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 重新计算自己场上和墓地的魔法·陷阱卡数量
		local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,TYPE_SPELL+TYPE_TRAP)
		if ct>0 then
			-- 中断当前效果处理，使后续的回复基本分处理与特殊召唤不视为同时进行
			Duel.BreakEffect()
			-- 使自己回复计算出的基本分数值
			Duel.Recover(tp,ct*100,REASON_EFFECT)
		end
	end
end
-- 过滤额外卡组中可以守备表示特殊召唤的「急袭猛禽」超量怪兽
function c97219708.spfilter(c,e,tp,mc)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0xba) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查将该怪兽解放后，额外卡组的怪兽是否有可用的出场区域
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 检查并执行将这张卡解放的发动代价
function c97219708.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 检查额外卡组是否存在可特殊召唤的「急袭猛禽」超量怪兽，并设置特殊召唤的操作信息
function c97219708.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果的准备阶段，检查额外卡组是否存在满足条件的「急袭猛禽」超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c97219708.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置连锁处理中的操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行从额外卡组特殊召唤「急袭猛禽」超量怪兽，并适用效果无效化、结束阶段回到额外卡组以及对方战斗伤害变0的后续处理
function c97219708.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家发送选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「急袭猛禽」超量怪兽
	local g=Duel.SelectMatchingCard(tp,c97219708.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	-- 若存在选择的怪兽，则将其以守备表示特殊召唤（分解步骤），成功则继续注册后续效果
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(97219708,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 结束阶段回到额外卡组。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(c97219708.tdcon)
		e3:SetOperation(c97219708.tdop)
		-- 注册在结束阶段将该怪兽送回额外卡组的全局效果
		Duel.RegisterEffect(e3,tp)
	end
	-- 完成特殊召唤的最终处理，触发特殊召唤成功的时点
	Duel.SpecialSummonComplete()
	-- 这个回合对方受到的战斗伤害变成0。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	e4:SetValue(1)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 注册本回合对方受到的战斗伤害变成0的全局效果
	Duel.RegisterEffect(e4,tp)
end
-- 检查结束阶段时，被特殊召唤的怪兽是否仍在场上且标记未改变
function c97219708.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(97219708)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 在结束阶段将该怪兽送回额外卡组
function c97219708.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽送回持有者的额外卡组
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
