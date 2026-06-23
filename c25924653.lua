--剣闘獣ダリウス
-- 效果：
-- ①：这张卡用「剑斗兽」怪兽的效果特殊召唤成功时，以自己墓地1只「剑斗兽」怪兽为对象才能发动。那只怪兽效果无效特殊召唤。这张卡从场上离开时那只怪兽回到持有者卡组。
-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 马斗」以外的1只「剑斗兽」怪兽特殊召唤。
function c25924653.initial_effect(c)
	-- ①：这张卡用「剑斗兽」怪兽的效果特殊召唤成功时，以自己墓地1只「剑斗兽」怪兽为对象才能发动。那只怪兽效果无效特殊召唤。这张卡从场上离开时那只怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25924653,0))  --"墓地特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 判断是否为「剑斗兽」怪兽的效果特殊召唤
	e1:SetCondition(aux.gbspcon)
	e1:SetTarget(c25924653.spgtg)
	e1:SetOperation(c25924653.spgop)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 马斗」以外的1只「剑斗兽」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25924653,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c25924653.spcon)
	e2:SetCost(c25924653.spcost)
	e2:SetTarget(c25924653.sptg)
	e2:SetOperation(c25924653.spop)
	c:RegisterEffect(e2)
	-- 当此卡离开场上的时触发的效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c25924653.leave)
	c:RegisterEffect(e3)
	e1:SetLabelObject(e3)
end
-- 过滤函数：判断墓地的卡是否为剑斗兽卡组且可以特殊召唤
function c25924653.spgfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标：选择墓地的一只剑斗兽怪兽作为对象
function c25924653.spgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c25924653.spgfilter(chkc,e,tp) end
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的剑斗兽怪兽
		and Duel.IsExistingTarget(c25924653.spgfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,c25924653.spgfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果：将目标怪兽特殊召唤并使其效果无效
function c25924653.spgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且执行特殊召唤步骤
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 使目标怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 使目标怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		if c:IsRelateToEffect(e) then
			c:SetCardTarget(tc)
			e:GetLabelObject():SetLabelObject(tc)
			c:CreateRelation(tc,RESET_EVENT+0x5020000)
			tc:CreateRelation(c,RESET_EVENT+0x5fe0000)
		end
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 处理离开场上的效果：将目标怪兽送回卡组
function c25924653.leave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc and c:IsRelateToCard(tc) and tc:IsRelateToCard(c) then
		-- 将目标怪兽送回卡组
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 判断此卡是否参与过战斗
function c25924653.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 支付效果代价：将此卡送入墓地
function c25924653.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 将此卡送入墓地
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤函数：判断卡组中的卡是否为剑斗兽卡组且可以特殊召唤（排除马斗）
function c25924653.filter(c,e,tp)
	return not c:IsCode(25924653) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标：选择卡组的一只剑斗兽怪兽作为对象
function c25924653.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组是否存在满足条件的剑斗兽怪兽
		and Duel.IsExistingMatchingCard(c25924653.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果：从卡组特殊召唤一只剑斗兽怪兽
function c25924653.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡
	local g=Duel.SelectMatchingCard(tp,c25924653.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将目标卡特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
