--隅烏賊
-- 效果：
-- ①：1回合1次，这张卡被选择作为对方怪兽的攻击对象时才能发动。自己场上的这张卡的位置向其他的自己的主要怪兽区域移动。那之后，在自己场上把1只「乌贼墨衍生物」（水族·水·2星·攻?/守0）特殊召唤。这衍生物的攻击力变成和那只对方怪兽的攻击力相同。
-- ②：持有这张卡的守备力以下的攻击力的对方怪兽不能选择主要怪兽区域的右端或左端存在的这张卡作为攻击对象。
function c65500515.initial_effect(c)
	-- ①：1回合1次，这张卡被选择作为对方怪兽的攻击对象时才能发动。自己场上的这张卡的位置向其他的自己的主要怪兽区域移动。那之后，在自己场上把1只「乌贼墨衍生物」（水族·水·2星·攻?/守0）特殊召唤。这衍生物的攻击力变成和那只对方怪兽的攻击力相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65500515,0))
	e1:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c65500515.seqtg)
	e1:SetOperation(c65500515.seqop)
	c:RegisterEffect(e1)
	-- ②：持有这张卡的守备力以下的攻击力的对方怪兽不能选择主要怪兽区域的右端或左端存在的这张卡作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c65500515.atcon)
	e2:SetValue(c65500515.atlimit)
	c:RegisterEffect(e2)
end
-- 效果①的发动准备，检查自己场上是否有可移动的空余主要怪兽区域，以及是否可以特殊召唤衍生物。
function c65500515.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前进行攻击的对方怪兽。
	local a=Duel.GetAttacker()
	-- 检查自己场上是否有其他可用的主要怪兽区域（用于自身移动）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
		-- 检查自己场上是否有可用的主要怪兽区域（用于特殊召唤衍生物）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤「乌贼墨衍生物」。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,65500516,0,TYPES_TOKEN_MONSTER,a:GetAttack(),0,2,RACE_AQUA,ATTRIBUTE_WATER) end
	-- 将攻击怪兽设为效果处理的对象。
	Duel.SetTargetCard(a)
	-- 设置在效果处理时会产生衍生物的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置在效果处理时会进行特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果①的处理开始，检查此卡是否仍在场、是否受效果影响，以及自己场上是否有可移动的空余主要怪兽区域。
function c65500515.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e)
		-- 若自己场上没有其他可用的主要怪兽区域，则效果不处理。
		or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	-- 提示玩家选择要移动到的主要怪兽区域。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家选择1个自己场上可用的主要怪兽区域。
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=math.log(s,2)
	-- 将这张卡移动到玩家选择的主要怪兽区域。
	Duel.MoveSequence(c,nseq)
	-- 获取当前进行攻击的对方怪兽。
	local a=Duel.GetAttacker()
	local atk=a:IsRelateToEffect(e) and a:GetAttack() or 0
	-- 检查自己场上是否还有空余的主要怪兽区域以进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查是否可以特殊召唤「乌贼墨衍生物」，若不能则结束效果处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,65500516,0,TYPES_TOKEN_MONSTER,atk,0,2,RACE_AQUA,ATTRIBUTE_WATER) then return end
	-- 中断当前效果处理，使后续的特殊召唤处理不与移动位置同时进行。
	Duel.BreakEffect()
	-- 在数据库中创建「乌贼墨衍生物」卡片。
	local token=Duel.CreateToken(tp,65500516)
	-- 尝试将衍生物以表侧表示特殊召唤到自己场上。
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
		-- 这衍生物的攻击力变成和那只对方怪兽的攻击力相同。持有这张卡的守备力以下的攻击力的对方怪兽不能选择主要怪兽区域的右端或左端存在的这张卡作为攻击对象。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤的最终处理。
	Duel.SpecialSummonComplete()
end
-- 检查这张卡是否处于主要怪兽区域的右端（序号4）或左端（序号0）。
function c65500515.atcon(e)
	local seq=e:GetHandler():GetSequence()
	return seq==0 or seq==4
end
-- 限制持有这张卡守备力以下攻击力的对方怪兽不能选择这张卡作为攻击对象。
function c65500515.atlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(1-tp) and c:IsAttackBelow(e:GetHandler():GetDefense()) and not c:IsImmuneToEffect(e)
end
