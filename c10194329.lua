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
-- 触发条件：自己因战斗或效果受到伤害
function c10194329.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 效果发动准备：检查自己怪兽区域是否有空格，以及此卡是否可以特殊召唤
function c10194329.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：给玩家施加从额外卡组特殊召唤怪兽的限制，并将手牌中的此卡特殊召唤
function c10194329.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是「急袭猛禽」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c10194329.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给自身施加直到回合结束时不是「急袭猛禽」怪兽不能从额外卡组特殊召唤的限制
	Duel.RegisterEffect(e1,tp)
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 限制不能特殊召唤「急袭猛禽」怪兽以外的额外卡组怪兽
function c10194329.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xba) and c:IsLocation(LOCATION_EXTRA)
end
