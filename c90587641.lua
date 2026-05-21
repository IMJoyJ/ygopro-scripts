--超重神将シャナ－O
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。这张卡特殊召唤。自己墓地没有魔法·陷阱卡存在的场合，再让那只对方怪兽攻击力变成0，效果无效化。
-- 【怪兽效果】
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名在规则上也当作「超重武者」卡使用。
-- ①：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
-- ②：这张卡是已同调召唤的场合，1回合1次，自己·对方的战斗阶段才能发动。从自己墓地以及自己的魔法与陷阱区域的表侧表示的卡之中选1张「超重武者」怪兽卡特殊召唤。那之后，可以把这张卡在自己的灵摆区域放置。
function c90587641.initial_effect(c)
	-- 为卡片添加同调召唤手续（调整＋调整以外的怪兽1只以上）
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 为卡片启用灵摆怪兽属性，但不注册默认的灵摆卡发动效果
	aux.EnablePendulumAttribute(c,false)
	-- ①：对方怪兽的攻击宣言时才能发动。这张卡特殊召唤。自己墓地没有魔法·陷阱卡存在的场合，再让那只对方怪兽攻击力变成0，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90587641,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,90587641)
	e1:SetCondition(c90587641.spdcon)
	e1:SetTarget(c90587641.spdtg)
	e1:SetOperation(c90587641.spdop)
	c:RegisterEffect(e1)
	-- ①：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DEFENSE_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：这张卡是已同调召唤的场合，1回合1次，自己·对方的战斗阶段才能发动。从自己墓地以及自己的魔法与陷阱区域的表侧表示的卡之中选1张「超重武者」怪兽卡特殊召唤。那之后，可以把这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(90587641,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMING_BATTLE_START+TIMING_BATTLE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(c90587641.spcon)
	e3:SetTarget(c90587641.sptg)
	e3:SetOperation(c90587641.spop)
	c:RegisterEffect(e3)
end
-- 定义灵摆效果①的发动条件函数
function c90587641.spdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 定义灵摆效果①的发动准备（target）函数
function c90587641.spdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取当前宣告攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 在发动效果时，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 检查自己墓地是否存在魔法·陷阱卡
	if not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP) then
		-- 设置使攻击怪兽效果无效的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
	end
end
-- 定义灵摆效果①的效果处理（operation）函数
function c90587641.spdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前宣告攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 若此卡已不关联此效果，或特殊召唤自身失败，则结束处理
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	if tc and tc:IsRelateToBattle()
		-- 且自己墓地没有魔法·陷阱卡存在
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
		and tc:IsControler(1-tp) and tc:IsFaceup()
		-- 且攻击怪兽的攻击力大于0，或者其效果未被无效化
		and (tc:GetAttack()>0 or aux.NegateMonsterFilter(tc)) then
		-- 中断当前效果处理，使后续处理与特殊召唤不视为同时处理
		Duel.BreakEffect()
		-- 使与攻击怪兽相关的连锁效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 那只对方怪兽攻击力变成0
		local e3=Effect.CreateEffect(c)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(0)
		tc:RegisterEffect(e3)
	end
end
-- 定义怪兽效果②的发动条件函数
function c90587641.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段
	local ph=Duel.GetCurrentPhase()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
-- 定义用于过滤满足特殊召唤条件的「超重武者」怪兽卡的条件函数
function c90587641.spfilter(c,e,tp)
	return c:IsSetCard(0x9a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsFaceupEx()
end
-- 定义怪兽效果②的发动准备（target）函数
function c90587641.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取自己墓地以及魔法与陷阱区域表侧表示的满足条件的「超重武者」怪兽卡组
	local g=Duel.GetMatchingGroup(c90587641.spfilter,tp,LOCATION_SZONE+LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return ft>0 and #g>0 end
	-- 设置从魔法与陷阱区域或墓地特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE+LOCATION_GRAVE)
end
-- 定义怪兽效果②的效果处理（operation）函数
function c90587641.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取自己墓地以及魔法与陷阱区域表侧表示的、且不受王家长眠之谷影响的满足条件的「超重武者」怪兽卡组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c90587641.spfilter),tp,LOCATION_SZONE+LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 or #g==0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,1,1,nil)
	-- 将选中的怪兽特殊召唤，并检查是否特殊召唤成功
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查此卡是否仍关联此效果，且自己的灵摆区域是否有空位
		and c:IsRelateToEffect(e) and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 询问玩家是否选择将此卡在自己的灵摆区域放置
		and Duel.SelectYesNo(tp,aux.Stringid(90587641,2)) then  --"是否把这张卡在灵摆区域放置？"
		-- 中断当前效果处理，使后续处理与特殊召唤不视为同时处理
		Duel.BreakEffect()
		-- 将此卡移动到自己的灵摆区域放置
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
