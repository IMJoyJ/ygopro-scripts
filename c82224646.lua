--EMオッドアイズ・シンクロン
-- 效果：
-- ←6 【灵摆】 6→
-- ①：1回合1次，以自己场上1只「娱乐伙伴」怪兽或者「异色眼」怪兽为对象才能发动。这个回合，那只表侧表示怪兽当作调整使用，等级变成1星。
-- 【怪兽效果】
-- 从额外卡组特殊召唤的这张卡被同调召唤使用的场合除外。
-- ①：这张卡召唤成功时，以自己墓地的3星以下的1只「娱乐伙伴」怪兽或者「异色眼」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：1回合1次，以自己的灵摆区域1张卡为对象才能发动。那张卡效果无效特殊召唤，只用那张卡和这张卡为素材把1只同调怪兽同调召唤。
function c82224646.initial_effect(c)
	-- 添加灵摆怪兽属性与灵摆效果规则
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
	-- ②：1回合1次，以自己的灵摆区域1张卡为对象才能发动。那张卡效果无效特殊召唤，只用那张卡和这张卡为素材把1只同调怪兽同调召唤。
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
-- 过滤条件：场上表侧表示的「娱乐伙伴」或「异色眼」怪兽（非调整或等级2以上）
function c82224646.tnfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f,0x99) and c:IsLevelAbove(0) and (not c:IsType(TYPE_TUNER) or c:IsLevelAbove(2))
end
-- 灵摆效果①目标选择：以场上1只「娱乐伙伴」或「异色眼」怪兽为对象
function c82224646.tntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c82224646.tnfilter(chkc) end
	-- 检查自己场上是否存在满足条件的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c82224646.tnfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只「娱乐伙伴」或「异色眼」怪兽作为对象
	Duel.SelectTarget(tp,c82224646.tnfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 灵摆效果①处理：使对象怪兽当作调整使用且等级变成1星
function c82224646.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的对象怪兽
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
-- 除外条件：从额外卡组特殊召唤且作为同调素材
function c82224646.rmcon(e)
	local c=e:GetHandler()
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsReason(REASON_MATERIAL) and c:IsReason(REASON_SYNCHRO)
end
-- 过滤条件：墓地3星以下的「娱乐伙伴」或「异色眼」怪兽
function c82224646.spfilter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsSetCard(0x9f,0x99) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果①目标选择及操作信息设置：以墓地3星以下的「娱乐伙伴」或「异色眼」怪兽为对象
function c82224646.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c82224646.spfilter(chkc,e,tp) end
	-- 判断自己场上是否有可用的怪兽区空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的怪兽作为对象
		and Duel.IsExistingTarget(c82224646.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只3星以下的「娱乐伙伴」或「异色眼」怪兽作为对象
	local g=Duel.SelectTarget(tp,c82224646.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将选中的对象怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 怪兽效果①处理：特殊召唤对象怪兽并使其效果无效化
function c82224646.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否与效果有联系，并执行特殊召唤的第一步
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 过滤条件：可作为同调素材且能特殊召唤，并能与这张卡一起同调召唤额外怪兽的灵摆卡
function c82224646.scfilter1(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return c:IsCanBeSynchroMaterial() and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_SYNCHRO_MATERIAL,tp,false,false)
		-- 检查额外卡组是否存在可以以这两张卡为素材同调召唤的怪兽
		and Duel.IsExistingMatchingCard(c82224646.scfilter2,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
end
-- 过滤条件：能以指定卡片组为素材同调召唤且有额外卡组可用空格的同调怪兽
function c82224646.scfilter2(c,tp,mg)
	-- 判断怪兽是否可同调召唤且在素材离场后存在可出场的额外卡组空格
	return c:IsSynchroSummonable(nil,mg) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
-- 怪兽效果②目标选择及操作信息设置：以灵摆区域的卡为对象
function c82224646.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c82224646.scfilter1(chkc,e,tp,c) end
	-- 判断自己是否能进行至少2次特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 判断自己场上是否有可用的主要怪兽区空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的灵摆区域是否存在满足条件的卡作为对象
		and Duel.IsExistingTarget(c82224646.scfilter1,tp,LOCATION_PZONE,0,1,nil,e,tp,c) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己灵摆区域的1张卡作为对象
	local g=Duel.SelectTarget(tp,c82224646.scfilter1,tp,LOCATION_PZONE,0,1,1,nil,e,tp,c)
	-- 设置操作信息：将选中的对象卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 怪兽效果②处理：特殊召唤灵摆区域的对象卡并进行同调召唤
function c82224646.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否与效果有联系，并作为同调素材执行特殊召唤的第一步
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
	-- 完成特殊召唤流程，若无卡片特殊召唤成功则中断处理
	if Duel.SpecialSummonComplete()==0 then return end
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 立刻刷新场地信息
	Duel.AdjustAll()
	local mg=Group.FromCards(c,tc)
	if mg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 获取额外卡组中能以这2张卡为素材同调召唤的怪兽
	local g=Duel.GetMatchingGroup(c82224646.scfilter2,tp,LOCATION_EXTRA,0,nil,tp,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的同调怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以这2张卡为素材进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
