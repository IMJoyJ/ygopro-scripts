--マジスタリー・アルケミスト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地以及自己场上的表侧表示怪兽之中把4只「英雄」怪兽除外，以自己墓地1只「英雄」怪兽为对象才能发动。那只怪兽无视召唤条件特殊召唤。把「地」「水」「炎」「风」的全部属性除外发动的场合，这个效果特殊召唤的怪兽的原本攻击力变成2倍，对方场上的全部表侧表示的卡的效果无效化。
function c58270977.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己墓地以及自己场上的表侧表示怪兽之中把4只「英雄」怪兽除外，以自己墓地1只「英雄」怪兽为对象才能发动。那只怪兽无视召唤条件特殊召唤。把「地」「水」「炎」「风」的全部属性除外发动的场合，这个效果特殊召唤的怪兽的原本攻击力变成2倍，对方场上的全部表侧表示的卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,58270977+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c58270977.cost)
	e1:SetTarget(c58270977.target)
	e1:SetOperation(c58270977.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示或自己墓地的可以作为代价除外的「英雄」怪兽
function c58270977.cfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 过滤条件：自己墓地中可以无视召唤条件特殊召唤的「英雄」怪兽
function c58270977.spfilter(c,e,tp)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 组选择条件：除外4张卡后，墓地仍存在可特召的「英雄」怪兽，且有可用的怪兽区域
function c58270977.fselect(g,e,tp)
	-- 检查除外这些卡后，墓地是否存在可作为特召对象的怪兽，且是否有可用的怪兽区域
	return Duel.IsExistingTarget(c58270977.spfilter,tp,LOCATION_GRAVE,0,1,g,e,tp) and Duel.GetMZoneCount(tp,g)>0
end
-- 发动代价（Cost）处理：从场上/墓地选择4只「英雄」怪兽除外，并检测是否集齐地水炎风四种属性
function c58270977.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上表侧表示及自己墓地中满足条件的「英雄」怪兽组
	local g=Duel.GetMatchingGroup(c58270977.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return g:CheckSubGroup(c58270977.fselect,4,4,e,tp) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c58270977.fselect,false,4,4,e,tp)
	local b1=sg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_EARTH)
	local b2=sg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER)
	local b3=sg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE)
	local b4=sg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WIND)
	if b1 and b2 and b3 and b4 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	-- 将选中的4只怪兽作为发动代价表侧表示除外
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 效果发动准备（Target）处理：选择自己墓地1只「英雄」怪兽为对象，并设置特殊召唤的操作信息
function c58270977.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c58270977.spfilter(chkc,e,tp) end
	-- 在发动时点检查自己墓地是否存在可特殊召唤的「英雄」怪兽
	if chk==0 then return Duel.IsExistingTarget(c58270977.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「英雄」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c58270977.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的效果分类为特殊召唤，操作对象为选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理（Operation）处理：特殊召唤对象怪兽，若满足四属性除外条件则使其原本攻击力翻倍并无效对方场上所有表侧表示卡片的效果
function c58270977.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于墓地且成功特殊召唤，且发动时除外了地水炎风全部四种属性，则执行追加效果
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) and e:GetLabel()==1 then
		local batk=tc:GetBaseAttack()
		-- 这个效果特殊召唤的怪兽的原本攻击力变成2倍
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(batk*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 获取对方场上所有表侧表示的卡片
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
		local gc=g:GetFirst()
		while gc do
			-- 对方场上的全部表侧表示的卡的效果无效化
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			gc:RegisterEffect(e2)
			-- 对方场上的全部表侧表示的卡的效果无效化
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			gc:RegisterEffect(e3)
			gc=g:GetNext()
		end
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
