--転生炎獣の超転生
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「转生炎兽」连接怪兽为对象才能发动。只用那1只自己怪兽为素材把1只同名「转生炎兽」连接怪兽当作连接召唤从额外卡组特殊召唤。
function c54529134.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只「转生炎兽」连接怪兽为对象才能发动。只用那1只自己怪兽为素材把1只同名「转生炎兽」连接怪兽当作连接召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,54529134+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c54529134.target)
	e1:SetOperation(c54529134.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的「转生炎兽」连接怪兽，且额外卡组存在可对其进行同名连接召唤的怪兽，并满足连接素材限制
function c54529134.filter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x119) and c:IsType(TYPE_LINK)
		-- 检查额外卡组是否存在满足特殊召唤条件的同名「转生炎兽」连接怪兽
		and Duel.IsExistingMatchingCard(c54529134.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
		-- 检查该怪兽是否满足必须作为连接素材的限制
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_LMATERIAL)
end
-- 过滤额外卡组中与作为素材的怪兽同名、可作为连接素材、可进行连接召唤，且额外卡组怪兽区域有空位的「转生炎兽」连接怪兽
function c54529134.filter2(c,e,tp,mc)
	return c:IsSetCard(0x119) and c:IsType(TYPE_LINK) and c:IsCode(mc:GetCode()) and mc:IsCanBeLinkMaterial(c)
		-- 检查该怪兽是否可以当作连接召唤特殊召唤，且在将素材怪兽送去墓地后额外卡组怪兽区域有可用的空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动时的对象选择与操作准备
function c54529134.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c54529134.filter1(chkc,e,tp) end
	-- 检查自己场上是否存在可以作为此效果对象的「转生炎兽」连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c54529134.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只「转生炎兽」连接怪兽作为效果的对象并进行确认
	local g=Duel.SelectTarget(tp,c54529134.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的执行函数
function c54529134.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查作为对象的怪兽是否满足必须作为连接素材的限制，若不满足则不处理后续效果
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_LMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的同名「转生炎兽」连接怪兽
	local g=Duel.SelectMatchingCard(tp,c54529134.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		sc:SetMaterial(Group.FromCards(tc))
		-- 将作为对象的怪兽作为连接素材送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_MATERIAL+REASON_LINK)
		-- 中断当前效果，使后续的特殊召唤处理与送去墓地不视为同时进行（防止错时点）
		Duel.BreakEffect()
		-- 将选择的同名「转生炎兽」连接怪兽当作连接召唤特殊召唤
		Duel.SpecialSummon(sc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
