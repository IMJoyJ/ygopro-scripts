--タクティカル・エクスチェンバー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏，从自己的卡组·墓地选原本卡名和那只怪兽不同的1只「弹丸」怪兽特殊召唤。
function c58421530.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏，从自己的卡组·墓地选原本卡名和那只怪兽不同的1只「弹丸」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,58421530+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c58421530.target)
	e1:SetOperation(c58421530.activate)
	c:RegisterEffect(e1)
end
-- 过滤作为破坏对象的怪兽（必须是表侧表示，且该怪兽离开后自己场上有空余怪兽区域，且卡组·墓地存在可特殊召唤的原本卡名不同的「弹丸」怪兽）
function c58421530.desfilter1(c,e,tp)
	-- 过滤条件：卡片必须表侧表示，且该卡离开场上后，自己场上必须有可用的怪兽区域
	return c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
	-- 过滤条件：自己的卡组或墓地中必须存在至少1只满足特殊召唤条件的「弹丸」怪兽
	and Duel.IsExistingMatchingCard(c58421530.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,c)
end
-- 过滤作为特殊召唤对象的「弹丸」怪兽（属于「弹丸」系列，原本卡名与作为破坏对象的怪兽不同，且可以特殊召唤）
function c58421530.spfilter(c,e,tp,tc)
	return c:IsSetCard(0x102) and not c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与处理（检查发动条件、选择破坏对象、设置操作信息）
function c58421530.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c58421530.desfilter1(chkc,e,tp) end
	-- 在发动效果的准备阶段，检查自己场上是否存在至少1个满足条件的表侧表示怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c58421530.desfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c58421530.desfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：包含破坏效果，对象为选择的怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置当前连锁的操作信息：包含特殊召唤效果，数量为1，来源为卡组或墓地
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理的执行函数（破坏对象怪兽，并从卡组或墓地特殊召唤原本卡名不同的「弹丸」怪兽）
function c58421530.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关，若成功将其破坏，且此时自己场上有可用的怪兽区域，则继续处理
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组或墓地选择1只原本卡名与被破坏怪兽不同且满足条件的「弹丸」怪兽（受王家长眠之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c58421530.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,tc)
		if g:GetCount()>0 then
			-- 将选择的「弹丸」怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
