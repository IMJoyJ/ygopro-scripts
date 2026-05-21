--Evil★Twin チャレンジ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「姬丝基勒」怪兽或「璃拉」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，以下效果可以适用。
-- ●进行1只「邪恶★双子」连接怪兽的连接召唤。
function c98360333.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只「姬丝基勒」怪兽或「璃拉」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,98360333+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c98360333.target)
	e1:SetOperation(c98360333.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中满足条件的「姬丝基勒」或「璃拉」怪兽，且该怪兽可以被特殊召唤
function c98360333.tgfilter(c,e,tp)
	return c:IsSetCard(0x152,0x153) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象合法性检查（必须是自己墓地中满足过滤条件的卡）
function c98360333.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)
		and c98360333.tgfilter(chkc,e,tp) end
	-- 检查当前玩家场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		-- 检查自己墓地是否存在至少1只可以成为效果对象的「姬丝基勒」或「璃拉」怪兽
		and Duel.IsExistingTarget(c98360333.tgfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「姬丝基勒」或「璃拉」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c98360333.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前处理的连锁的操作信息，包含特殊召唤选定对象的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤额外卡组中可以进行连接召唤的「邪恶★双子」连接怪兽
function c98360333.linkfilter(c)
	return c:IsLinkSummonable(nil) and c:IsSetCard(0x2151)
end
-- 效果处理：获取对象怪兽，若其仍存在于墓地且怪兽区域足够，则将其特殊召唤
function c98360333.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关联，以及当前玩家场上是否有可用的怪兽区域
	if not tc:IsRelateToEffect(e) or Duel.GetMZoneCount(tp)<1
		-- 将对象怪兽以表侧表示特殊召唤，若特殊召唤失败则结束效果处理
		or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 获取额外卡组中当前可以进行连接召唤的「邪恶★双子」连接怪兽组
	local g=Duel.GetMatchingGroup(c98360333.linkfilter,tp,LOCATION_EXTRA,0,nil)
	-- 若存在可连接召唤的怪兽，询问玩家是否选择适用连接召唤的效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(98360333,0)) then  --"是否连接召唤？"
		-- 中断当前效果处理，使后续的连接召唤与特殊召唤不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要进行连接召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		-- 让玩家使用场上的怪兽作为素材，对选定的怪兽进行连接召唤
		Duel.LinkSummon(tp,tc,nil)
	end
end
