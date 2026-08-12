--ディメンジョン・ダイス
-- 效果：
-- ①：持有掷骰子效果的卡在自己场上存在的场合，把自己场上1只怪兽解放才能发动。把持有掷骰子的怪兽效果的1只怪兽从手卡·卡组特殊召唤。
function c47292920.initial_effect(c)
	-- 创建效果，设置为发动时点，可以自由连锁，条件为场上存在持有掷骰子效果的怪兽，支付代价为解放场上一只怪兽，目标为从手卡或卡组特殊召唤持有掷骰子效果的怪兽，效果处理为特殊召唤符合条件的怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c47292920.spcon)
	e1:SetCost(c47292920.cost)
	e1:SetTarget(c47292920.target)
	e1:SetOperation(c47292920.activate)
	c:RegisterEffect(e1)
end
-- 过滤器函数：检查场上正面表示的怪兽是否具有掷骰子效果
function c47292920.cfilter(c)
	-- 返回值：该怪兽正面表示且拥有掷骰子效果
	return c:IsFaceup() and c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_DICE))
end
-- 发动条件函数：判断自己场上是否存在持有掷骰子效果的怪兽
function c47292920.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回值：自己场上存在至少1张正面表示且具有掷骰子效果的怪兽
	return Duel.IsExistingMatchingCard(c47292920.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 解放过滤器函数：检查玩家场上是否有可用的怪兽区域
function c47292920.costfilter(c,tp)
	-- 返回值：该卡所在位置有可用的怪兽区域
	return Duel.GetMZoneCount(tp,c)>0
end
-- 支付代价函数：设置标签为1，若检查阶段则检查是否能解放满足条件的怪兽，若能则选择并解放一张
function c47292920.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查阶段：判断是否能从场上选择满足条件的怪兽进行解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,c47292920.costfilter,1,nil,tp) end
	-- 选择满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c47292920.costfilter,1,1,nil,tp)
	-- 将选中的怪兽进行解放，原因设为支付代价
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤过滤器函数：检查手卡或卡组中是否具有掷骰子效果且可特殊召唤的怪兽
function c47292920.spfilter(c,e,tp)
	-- 返回值：该卡为怪兽类型且拥有掷骰子效果
	return c:IsType(TYPE_MONSTER) and c:IsEffectProperty(aux.MonsterEffectPropertyFilter(EFFECT_FLAG_DICE))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置目标函数：若检查阶段则判断是否有满足条件的怪兽可特殊召唤，否则设置操作信息
function c47292920.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 判断是否满足特殊召唤条件：标签为1或场上存在可用怪兽区域
		local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		e:SetLabel(0)
		-- 返回值：满足条件且手卡或卡组中存在至少1张符合条件的怪兽
		return res and Duel.IsExistingMatchingCard(c47292920.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- 设置操作信息：准备特殊召唤一张手卡或卡组中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理函数：若场上存在可用怪兽区域则提示选择并特殊召唤符合条件的怪兽
function c47292920.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有可用怪兽区域，若无则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组中选择一张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c47292920.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以正面表示方式特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
