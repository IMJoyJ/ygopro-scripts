--応身の機械天使
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，自己的「电子化天使」仪式怪兽不会被战斗破坏。
-- ②：战斗或者对方的效果让自己受到伤害时，把自己的手卡·场上1只「电子化天使」仪式怪兽解放才能发动。从手卡把1只「电子化天使」仪式怪兽当作仪式召唤作特殊召唤。
function c91946859.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己的「电子化天使」仪式怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c91946859.indfilter)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：战斗或者对方的效果让自己受到伤害时，把自己的手卡·场上1只「电子化天使」仪式怪兽解放才能发动。从手卡把1只「电子化天使」仪式怪兽当作仪式召唤作特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetCountLimit(1,91946859)
	e3:SetCondition(c91946859.spcondition)
	e3:SetCost(c91946859.spcost)
	e3:SetTarget(c91946859.sptg)
	e3:SetOperation(c91946859.spop)
	c:RegisterEffect(e3)
end
-- 过滤属于「电子化天使」的仪式怪兽
function c91946859.indfilter(e,c)
	return c:GetType()&0x81==0x81 and c:IsSetCard(0x2093)
end
-- 检查受到伤害的玩家是否为自己，且伤害来源是否为战斗或对方的效果
function c91946859.spcondition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and (bit.band(r,REASON_BATTLE)~=0 or (bit.band(r,REASON_EFFECT)~=0 and rp==1-tp))
end
-- 过滤可作为解放代价的「电子化天使」仪式怪兽，要求其解放后手卡存在可特殊召唤的「电子化天使」仪式怪兽，且有可用的怪兽区域
function c91946859.cfilter(c,e,tp)
	-- 检查该卡是否为「电子化天使」仪式怪兽，且手卡中存在除该卡以外的、可特殊召唤的「电子化天使」仪式怪兽
	return c:GetType()&0x81==0x81 and c:IsSetCard(0x2093) and Duel.IsExistingMatchingCard(c91946859.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
		-- 检查将该卡解放后，自己场上是否有可用于特殊召唤怪兽的空余怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤手卡中可以当作仪式召唤特殊召唤的「电子化天使」仪式怪兽
function c91946859.spfilter(c,e,tp)
	return c:GetType()&0x81==0x81 and c:IsSetCard(0x2093) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false)
end
-- 效果发动的代价：检查并从手卡或场上选择1只「电子化天使」仪式怪兽解放
function c91946859.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在至少1只满足解放条件的「电子化天使」仪式怪兽
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c91946859.cfilter,1,REASON_COST,true,nil,e,tp) end
	-- 让玩家从手卡或场上选择1只满足条件的「电子化天使」仪式怪兽
	local g=Duel.SelectReleaseGroupEx(tp,c91946859.cfilter,1,1,REASON_COST,true,nil,e,tp)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(g,REASON_COST)
end
-- 效果发动的目标：检查手卡中是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c91946859.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只可以当作仪式召唤特殊召唤的「电子化天使」仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91946859.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手卡选择1只「电子化天使」仪式怪兽，当作仪式召唤特殊召唤，并完成正规召唤程序
function c91946859.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足特殊召唤条件的「电子化天使」仪式怪兽
	local g=Duel.SelectMatchingCard(tp,c91946859.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选中的怪兽以仪式召唤的方式、表侧表示特殊召唤到自己场上，并检查是否特殊召唤成功
		if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
