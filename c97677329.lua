--バックアップ・スーパーバイザー
-- 效果：
-- 怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡是已用「备份秘书」为素材作连接召唤的场合在这张卡所连接区的自己怪兽和对方怪兽进行战斗的伤害步骤结束时才能发动。从手卡把1只电子界族怪兽特殊召唤。
-- ②：这张卡被战斗或者对方的效果破坏的场合才能发动。从自己的手卡·卡组·墓地选1只「备份秘书」特殊召唤。
function c97677329.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：怪兽2只
	aux.AddLinkProcedure(c,nil,2,2)
	-- ①：这张卡是已用「备份秘书」为素材作连接召唤的场合
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c97677329.valcheck)
	c:RegisterEffect(e0)
	-- ①：这张卡是已用「备份秘书」为素材作连接召唤的场合在这张卡所连接区的自己怪兽和对方怪兽进行战斗的伤害步骤结束时才能发动。从手卡把1只电子界族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97677329,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,97677329)
	e1:SetCondition(c97677329.spcon1)
	e1:SetTarget(c97677329.sptg1)
	e1:SetOperation(c97677329.spop1)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗或者对方的效果破坏的场合才能发动。从自己的手卡·卡组·墓地选1只「备份秘书」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97677329,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,97677330)
	e2:SetCondition(c97677329.spcon2)
	e2:SetTarget(c97677329.sptg2)
	e2:SetOperation(c97677329.spop2)
	c:RegisterEffect(e2)
end
-- 检查连接素材中是否存在「备份秘书」，若存在则将效果的Label设为1
function c97677329.valcheck(e,c)
	local g=c:GetMaterial()
	e:SetLabel(0)
	if g:IsExists(Card.IsLinkCode,1,nil,63528891) then
		e:SetLabel(1)
	end
end
-- 确认此卡是用「备份秘书」为素材连接召唤，且进行战斗的自己怪兽在此卡的所连接区
function c97677329.spcon1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=1 then return false end
	local lg=e:GetHandler():GetLinkedGroup()
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	local b=a:GetBattleTarget()
	if not b then return false end
	if a:IsControler(1-tp) then a,b=b,a end
	return lg:IsContains(a)
end
-- 过滤手卡中可以特殊召唤的电子界族怪兽
function c97677329.filter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查自己场上是否有空位以及手卡中是否有可特殊召唤的电子界族怪兽，并设置特殊召唤的操作信息
function c97677329.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动检查时，确认手卡中是否存在至少1只满足特殊召唤条件的电子界族怪兽
		and Duel.IsExistingMatchingCard(c97677329.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的处理：从手卡选择1只电子界族怪兽特殊召唤
function c97677329.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的电子界族怪兽
	local g=Duel.SelectMatchingCard(tp,c97677329.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 确认此卡是被战斗破坏，或者是被对方的效果破坏且原本由自己控制
function c97677329.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- 过滤手卡、卡组、墓地中可以特殊召唤的「备份秘书」
function c97677329.spfilter(c,e,tp)
	return c:IsCode(63528891) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查自己场上是否有空位以及手卡·卡组·墓地中是否有可特殊召唤的「备份秘书」，并设置特殊召唤的操作信息
function c97677329.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动检查时，确认手卡、卡组、墓地中是否存在至少1只满足特殊召唤条件的「备份秘书」
		and Duel.IsExistingMatchingCard(c97677329.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息：从手卡、卡组、墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②的处理：从手卡、卡组、墓地选择1只「备份秘书」特殊召唤
function c97677329.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地选择1只满足条件的「备份秘书」（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c97677329.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
