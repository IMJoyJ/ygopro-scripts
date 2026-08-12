--XX－セイバー フラムナイト
-- 效果：
-- ①：只在这张卡在场上表侧表示存在才有1次，对方怪兽的攻击宣言时以那1只怪兽为对象才能发动。那次攻击无效。
-- ②：这张卡战斗破坏对方的守备表示怪兽的场合，以自己墓地1只4星以下的「X-剑士」怪兽为对象才能发动。那只怪兽特殊召唤。
function c78422252.initial_effect(c)
	-- ①：只在这张卡在场上表侧表示存在才有1次，对方怪兽的攻击宣言时以那1只怪兽为对象才能发动。那次攻击无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78422252,0))  --"攻击无效"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c78422252.condition)
	e1:SetTarget(c78422252.target)
	e1:SetOperation(c78422252.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方的守备表示怪兽的场合，以自己墓地1只4星以下的「X-剑士」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78422252,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c78422252.spcon)
	e2:SetTarget(c78422252.sptg)
	e2:SetOperation(c78422252.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数
function c78422252.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击怪兽的控制者是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果①的对象选择与发动准备函数
function c78422252.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行攻击宣言的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将该攻击怪兽设为效果的对象
	Duel.SetTargetCard(tg)
end
-- 效果①的效果处理函数
function c78422252.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该次攻击
	Duel.NegateAttack()
end
-- 效果②的发动条件判定函数
function c78422252.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽（即自身）
	local a=Duel.GetAttacker()
	-- 获取被攻击的怪兽（即对方怪兽）
	local d=Duel.GetAttackTarget()
	-- 判定自身进行攻击且被攻击的怪兽在伤害步骤时为守备表示
	return a==Duel.GetAttacker() and bit.band(d:GetBattlePosition(),POS_DEFENSE)~=0
end
-- 过滤自己墓地4星以下「X-剑士」怪兽的条件函数
function c78422252.filter(c,e,tp)
	return c:IsSetCard(0x100d) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的对象选择与发动准备函数
function c78422252.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c78422252.filter(chkc,e,tp) end
	-- 判定自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在符合条件的怪兽可以作为对象
		and Duel.IsExistingTarget(c78422252.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c78422252.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理（特殊召唤）函数
function c78422252.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
