--シンクロキャンセル
-- 效果：
-- ①：以场上1只同调怪兽为对象才能发动。那只同调怪兽回到额外卡组。那之后，若作为回到额外卡组的那只怪兽的同调召唤的素材用过的一组怪兽在自己墓地齐集，可以把那一组特殊召唤。
function c32441317.initial_effect(c)
	-- ①：以场上1只同调怪兽为对象才能发动。那只同调怪兽回到额外卡组。那之后，若作为回到额外卡组的那只怪兽的同调召唤的素材用过的一组怪兽在自己墓地齐集，可以把那一组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c32441317.target)
	e1:SetOperation(c32441317.activate)
	c:RegisterEffect(e1)
end
-- 定义对象过滤函数：筛选场上表侧表示、属于同调怪兽且可以返回额外卡组的卡。
function c32441317.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- 效果的目标处理函数：发动时确认存在可选择的同调怪兽，然后选择场上1只同调怪兽作为对象，并设置回额外卡组的操作信息。
function c32441317.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c32441317.filter(chkc) end
	-- 合法性检查：若场上不存在1只以上满足条件的同调怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c32441317.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，让玩家选择要返回额外卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从双方场上选择1只表侧表示的同调怪兽作为效果对象，并自动关联到当前连锁。
	local g=Duel.SelectTarget(tp,c32441317.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果将使对象怪兽返回额外卡组（CATEGORY_TOEXTRA），供其他卡片连锁时参考。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 定义素材过滤函数：检查墓地中的卡是否属于本回合同调召唤该怪兽时使用过的素材（因该同调召唤被送去墓地，原因卡为那只怪兽），且当前可被特殊召唤。
function c32441317.mgfilter(c,e,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and bit.band(c:GetReason(),0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数：将目标同调怪兽送回额外卡组；成功后，若其同调素材一组均在自己的墓地且满足可特殊召唤条件，且玩家选择是，则把那组素材特殊召唤。
function c32441317.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local mg=tc:GetMaterial()
	local ct=mg:GetCount()
	-- 将目标怪兽送回持有者额外卡组；若送回成功且该怪兽确实位于额外卡组，则继续后续判断。
	if Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA)
		and tc:IsSummonType(SUMMON_TYPE_SYNCHRO)
		-- 检查素材数量大于0且自己场上有足够空格来特殊召唤全部素材。
		and ct>0 and ct<=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and (not Duel.IsPlayerAffectedByEffect(tp,59822133) or ct==1)
		-- 过滤并统计墓地中的素材：必须所有素材都满足可特殊召唤条件（且不受王家长眠之谷影响），其数量等于完整素材数。
		and mg:FilterCount(aux.NecroValleyFilter(c32441317.mgfilter),nil,e,tp,tc)==ct
		-- 询问玩家是否将那一组素材特殊召唤，只有选择‘是’才继续。
		and Duel.SelectYesNo(tp,aux.Stringid(32441317,0)) then  --"是否要把素材特殊召唤？"
		-- 中断当前效果处理，使后续特殊召唤作为独立效果处理，避免错过时点。
		Duel.BreakEffect()
		-- 将那一组素材以表侧表示特殊召唤到自己场上，不检查苏生限制。
		Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)
	end
end
