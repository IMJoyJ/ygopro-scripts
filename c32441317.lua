--シンクロキャンセル
-- 效果：
-- ①：以场上1只同调怪兽为对象才能发动。那只同调怪兽回到额外卡组。那之后，若作为回到额外卡组的那只怪兽的同调召唤的素材用过的一组怪兽在自己墓地齐集，可以把那一组特殊召唤。
function c32441317.initial_effect(c)
	-- 效果原文内容：①：以场上1只同调怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c32441317.target)
	e1:SetOperation(c32441317.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：过滤场上正面表示的同调怪兽，且能送入额外卡组
function c32441317.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- 规则层面作用：设置效果目标为场上正面表示的同调怪兽
function c32441317.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c32441317.filter(chkc) end
	-- 规则层面作用：判断是否场上存在正面表示的同调怪兽作为效果目标
	if chk==0 then return Duel.IsExistingTarget(c32441317.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 规则层面作用：向玩家提示选择要送入卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 规则层面作用：选择场上一只正面表示的同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c32441317.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 规则层面作用：设置效果处理信息，表示将把目标怪兽送入额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 规则层面作用：过滤墓地中的怪兽，满足其为同调召唤的素材且能特殊召唤
function c32441317.mgfilter(c,e,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and bit.band(c:GetReason(),0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：处理效果发动后的主要逻辑，包括将目标怪兽送回额外卡组并判断是否能特殊召唤素材
function c32441317.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local mg=tc:GetMaterial()
	local ct=mg:GetCount()
	-- 规则层面作用：将目标怪兽送回额外卡组，若成功则继续判断后续条件
	if Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA)
		and tc:IsSummonType(SUMMON_TYPE_SYNCHRO)
		-- 规则层面作用：判断送回额外卡组的怪兽的同调素材数量是否在场上可用区域范围内
		and ct>0 and ct<=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and (not Duel.IsPlayerAffectedByEffect(tp,59822133) or ct==1)
		-- 规则层面作用：判断墓地中满足条件的怪兽数量是否等于同调素材数量
		and mg:FilterCount(aux.NecroValleyFilter(c32441317.mgfilter),nil,e,tp,tc)==ct
		-- 规则层面作用：询问玩家是否要将同调素材特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(32441317,0)) then  --"是否要把素材特殊召唤？"
		-- 规则层面作用：中断当前效果处理，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 规则层面作用：将满足条件的同调素材特殊召唤到场上
		Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)
	end
end
