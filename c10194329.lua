--RR－アベンジ・ヴァルチャー
-- 效果：
-- ①：自己因战斗·效果受到伤害的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是「急袭猛禽」怪兽不能从额外卡组特殊召唤。
function c10194329.initial_effect(c)
	-- ①：自己因战斗·效果受到伤害的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是「急袭猛禽」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c10194329.condition)
	e1:SetTarget(c10194329.target)
	e1:SetOperation(c10194329.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：当前玩家因战斗或效果受到伤害时才可发动
function c10194329.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 检查是否可以特殊召唤：确认场上是否有空位且此卡可以被特殊召唤
function c10194329.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认怪兽区域是否有空位以供特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表明将要进行一次特殊召唤操作，对象为此卡本身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行效果处理：注册限制特殊召唤的效果并特殊召唤此卡
function c10194329.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个效果的发动后，直到回合结束时自己不是「急袭猛禽」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c10194329.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制特殊召唤的效果注册给当前玩家，在回合结束前生效
	Duel.RegisterEffect(e1,tp)
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡从手牌以表侧攻击表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 定义特殊召唤限制条件：非「急袭猛禽」怪兽且位于额外卡组时不可特殊召唤
function c10194329.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xba) and c:IsLocation(LOCATION_EXTRA)
end
