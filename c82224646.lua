--EMオッドアイズ・シンクロン
-- 效果：
-- ←6 【灵摆】 6→
-- ①：1回合1次，以自己场上1只「娱乐伙伴」怪兽或者「异色眼」怪兽为对象才能发动。这个回合，那只表侧表示怪兽当作调整使用，等级变成1星。
-- 【怪兽效果】
-- 从额外卡组特殊召唤的这张卡被同调召唤使用的场合除外。
-- ①：这张卡召唤成功时，以自己墓地的3星以下的1只「娱乐伙伴」怪兽或者「异色眼」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：1回合1次，以自己的灵摆区域1张卡为对象才能发动。那张卡效果无效特殊召唤，只用那张卡和这张卡为素材把1只同调怪兽同调召唤。
function c82224646.initial_effect(c)
	-- 注册灵摆怪兽的灵摆属性（灵摆召唤、灵摆卡的发动）。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只「娱乐伙伴」怪兽或者「异色眼」怪兽为对象才能发动。这个回合，那只表侧表示怪兽当作调整使用，等级变成1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82224646,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c82224646.tntg)
	e1:SetOperation(c82224646.tnop)
	c:RegisterEffect(e1)
	-- 从额外卡组特殊召唤的这张卡被同调召唤使用的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetCondition(c82224646.rmcon)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤成功时，以自己墓地的3星以下的1只「娱乐伙伴」怪兽或者「异色眼」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(82224646,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c82224646.sptg)
	e3:SetOperation(c82224646.spop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，以自己的灵摆区域1张卡为对象才能发动。那张卡效果无效特殊召唤，只用那张卡 and 这张卡为素材把1只同调怪兽同调召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(82224646,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c82224646.sctg)
	e4:SetOperation(c82224646.scop)
	c:RegisterEffect(e4)
end
-- 过滤自己场上表侧表示的「娱乐伙伴」怪兽或「异色眼」怪兽（且等级大于等于0，若已是调整则等级需大于等于2以使其等级能变为1星）。
function c82224646.tnfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f,0x99) and c:IsLevelAbove(0) and (not c:IsType(TYPE_TUNER) or c:IsLevelAbove(2))
end
-- 灵摆效果的发动条件判定与对象选择。
function c82224646.tntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c82224646.tnfilter(chkc) end
	-- 检查自己场上是否存在满足条件的表侧表示「娱乐伙伴」或「异色眼」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c82224646.tnfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只满足条件的怪兽作为效果对象。
	Duel.SelectTarget(tp,c82224646.tnfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 灵摆效果的处理：使选择的怪兽当作调整使用，且等级变成1星。
function c82224646.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只表侧表示怪兽当作调整使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 等级变成1星
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_LEVEL)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 判定这张卡是否是从额外卡组特殊召唤且作为同调素材送去墓地。
function c82224646.rmcon(e)
	local c=e:GetHandler()
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsReason(REASON_MATERIAL) and c:IsReason(REASON_SYNCHRO)
end
-- 过滤自己墓地3星以下的「娱乐伙伴」怪兽或「异色眼」怪兽。
function c82224646.spfilter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsSetCard(0x9f,0x99) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果①的发动条件判定与对象选择。
function c82224646.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c82224646.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的3星以下「娱乐伙伴」或「异色眼」怪兽。
		and Duel.IsExistingTarget(c82224646.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c82224646.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明该效果包含特殊召唤1张目标卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 怪兽效果①的处理：将选择的墓地怪兽特殊召唤，并将其效果无效化。
function c82224646.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取要特殊召唤的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于墓地，则将其以表侧表示特殊召唤（分步处理）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的最终处理。
	Duel.SpecialSummonComplete()
end
-- 过滤自己灵摆区域中可以作为同调素材、可以特殊召唤，且能与这张卡一起作为素材同调召唤额外卡组某只同调怪兽的卡。
function c82224646.scfilter1(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return c:IsCanBeSynchroMaterial() and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_SYNCHRO_MATERIAL,tp,false,false)
		-- 检查额外卡组是否存在能以这两张卡为素材进行同调召唤的同调怪兽。
		and Duel.IsExistingMatchingCard(c82224646.scfilter2,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
end
-- 过滤额外卡组中能以指定素材组进行同调召唤，且召唤时有可用怪兽区域的同调怪兽。
function c82224646.scfilter2(c,tp,mg)
	-- 判定该同调怪兽是否能以指定素材进行同调召唤，且额外怪兽区域或有连接端指向的区域有空位。
	return c:IsSynchroSummonable(nil,mg) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
-- 怪兽效果②的发动条件判定与对象选择。
function c82224646.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c82224646.scfilter1(chkc,e,tp,c) end
	-- 检查玩家是否能进行至少2次特殊召唤（特召灵摆卡和同调召唤）。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查自己场上是否有空余的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的灵摆区域是否存在满足条件的卡。
		and Duel.IsExistingTarget(c82224646.scfilter1,tp,LOCATION_PZONE,0,1,nil,e,tp,c) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己灵摆区域的1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,c82224646.scfilter1,tp,LOCATION_PZONE,0,1,1,nil,e,tp,c)
	-- 设置连锁信息，表明该效果包含特殊召唤1张目标卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 怪兽效果②的处理：将选择的灵摆卡效果无效特殊召唤，并仅用那张卡和这张卡为素材进行同调召唤。
function c82224646.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为对象的灵摆区域的卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍存在，则将其以表侧表示特殊召唤（作为同调素材用途）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,SUMMON_VALUE_SYNCHRO_MATERIAL,tp,tp,false,false,POS_FACEUP) then
		-- 那张卡效果无效特殊召唤
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的最终处理，若特殊召唤失败则结束效果。
	if Duel.SpecialSummonComplete()==0 then return end
	if not c:IsRelateToEffect(e) then return end
	-- 立即刷新场上卡片状态信息，以确保后续同调召唤判定准确。
	Duel.AdjustAll()
	local mg=Group.FromCards(c,tc)
	if mg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 获取额外卡组中能以这两张卡为素材进行同调召唤的怪兽。
	local g=Duel.GetMatchingGroup(c82224646.scfilter2,tp,LOCATION_EXTRA,0,nil,tp,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要同调召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 进行同调召唤，将选定的同调怪兽特殊召唤。
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
