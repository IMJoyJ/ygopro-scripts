--ホールティアの蟲惑魔
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。这张卡也能从手卡丢弃1张通常陷阱卡，在盖放的回合发动。
-- ①：这张卡发动后变成通常怪兽（植物族·地·4星·攻400/守2400）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。
-- ②：把墓地的这张卡除外，以自己墓地1只「虫惑魔」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册①效果（陷阱怪兽特殊召唤）、在盖放回合发动的效果、以及②效果（墓地除外特招墓地「虫惑魔」怪兽）。
function s.initial_effect(c)
	-- ①：这张卡发动后变成通常怪兽（植物族·地·4星·攻400/守2400）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这张卡也能从手卡丢弃1张通常陷阱卡，在盖放的回合发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetDescription(aux.Stringid(id,2))  --"适用「破洞露蒂亚之虫惑魔」的效果来发动"
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCost(s.cost)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以自己墓地1只「虫惑魔」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 设置效果②的发动代价为将墓地的这张卡除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：手牌中可丢弃的通常陷阱卡。
function s.cfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsDiscardable()
end
-- 盖放回合发动效果的代价：从手牌丢弃1张通常陷阱卡。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可丢弃的通常陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并以丢弃和代价为原因将1张手牌中的通常陷阱卡送入墓地。
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_DISCARD+REASON_COST,nil)
end
-- 效果①的发动准备：检查是否满足特殊召唤陷阱怪兽的条件。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己的怪兽区域是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能将此卡作为特定属性、种族、攻防、等级的通常怪兽在守备表示特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x108a,TYPES_NORMAL_TRAP_MONSTER,400,2400,4,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,tp) end
	-- 设置当前连锁的操作信息为特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将此卡作为通常怪兽特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与效果相关，且玩家是否仍能特殊召唤该陷阱怪兽。
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x108a,TYPES_NORMAL_TRAP_MONSTER,400,2400,4,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,tp) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 将此卡在自己场上守备表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤条件：自己墓地可以特殊召唤的「虫惑魔」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x108a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查并选择自己墓地1只「虫惑魔」怪兽作为对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「虫惑魔」怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送选择特殊召唤卡片的消息提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「虫惑魔」怪兽作为效果对象并将其设为效果目标。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为特殊召唤选中的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的「虫惑魔」怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将目标怪兽在自己场上表侧表示特殊召唤。
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
end
