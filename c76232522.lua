--リカバリー・ソーサラー
-- 效果：
-- 电子界族怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：以这个回合被破坏的自己墓地1只电子界族连接怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。这个效果在对方回合也能发动。
function c76232522.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，需要2只电子界族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	-- ①：以这个回合被破坏的自己墓地1只电子界族连接怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76232522,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,76232522)
	e1:SetTarget(c76232522.sptg)
	e1:SetOperation(c76232522.spop)
	c:RegisterEffect(e1)
end
-- 过滤满足“本回合被破坏的自己墓地的电子界族连接怪兽，且可以特殊召唤”条件的卡片
function c76232522.spfilter(c,e,tp,tid)
	return c:GetTurnID()==tid and bit.band(c:GetReason(),REASON_DESTROY)~=0
		and c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与目标选择
function c76232522.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合数，用于后续判断卡片是否在当前回合被破坏
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c76232522.spfilter(chkc,e,tp,tid) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的、可作为效果对象的卡片
		and Duel.IsExistingTarget(c76232522.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,tid) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1张满足条件的卡片作为效果对象
	local g=Duel.SelectTarget(tp,c76232522.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tid)
	-- 设置效果处理信息为“特殊召唤选中的卡片”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理逻辑（特殊召唤、无效化效果、注册结束阶段破坏的延迟效果）
function c76232522.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的效果对象
	local tc=Duel.GetFirstTarget()
	-- 如果对象卡片仍与效果相关，则将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 结束阶段破坏
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCountLimit(1)
		e3:SetCondition(c76232522.descon)
		e3:SetOperation(c76232522.desop)
		e3:SetLabelObject(tc)
		-- 注册在结束阶段触发的全局效果，用于破坏该怪兽
		Duel.RegisterEffect(e3,tp)
		tc:RegisterFlagEffect(76232522,RESET_EVENT+RESETS_STANDARD,0,1)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 结束阶段破坏效果的触发条件判定（检查怪兽是否仍带有标记，若无则重置该效果）
function c76232522.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(76232522)==0 then
		e:Reset()
		return false
	end
	return true
end
-- 结束阶段破坏效果的具体执行
function c76232522.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 因效果将目标怪兽破坏
	Duel.Destroy(tc,REASON_EFFECT)
end
