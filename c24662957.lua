--デモンズ・ゴーレム
-- 效果：
-- ①：以场上1只攻击力2000以上的怪兽为对象才能发动。那只怪兽直到下个回合的结束阶段除外。自己场上有着「红莲魔龙」或者有那个卡名记述的同调怪兽存在的状态把这张卡发动的场合，可以再从自己的卡组·墓地把1张「魔族之链」在自己场上盖放。
function c24662957.initial_effect(c)
	-- 记录此卡效果文本中记载了「红莲魔龙」的卡名
	aux.AddCodeList(c,70902743)
	-- ①：以场上1只攻击力2000以上的怪兽为对象才能发动。那只怪兽直到下个回合的结束阶段除外。自己场上有着「红莲魔龙」或者有那个卡名记述的同调怪兽存在的状态把这张卡发动的场合，可以再从自己的卡组·墓地把1张「魔族之链」在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c24662957.target)
	e1:SetOperation(c24662957.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断目标怪兽是否为攻击力2000以上且正面表示且可以除外
function c24662957.rmfilter(c)
	return c:IsAttackAbove(2000) and c:IsFaceup() and c:IsAbleToRemove()
end
-- 过滤函数：判断目标卡是否为「红莲魔龙」或为含有「红莲魔龙」卡名记述的同调怪兽且正面表示
function c24662957.cfilter(c)
	-- 判断目标卡是否为「红莲魔龙」或为含有「红莲魔龙」卡名记述的同调怪兽
	return (c:IsCode(70902743) or (aux.IsCodeListed(c,70902743) and c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_MZONE)))
		and c:IsFaceup()
end
-- 设置效果目标：选择场上1只攻击力2000以上的正面表示怪兽作为对象
function c24662957.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c24662957.rmfilter(chkc) end
	-- 检查是否满足发动条件：场上是否存在1只攻击力2000以上的正面表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c24662957.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1只攻击力2000以上的正面表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c24662957.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：将该怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 统计自己场上是否存在「红莲魔龙」或含有其卡名记述的同调怪兽
	local ct=Duel.GetMatchingGroupCount(c24662957.cfilter,tp,LOCATION_ONFIELD,0,nil)
	e:SetLabel(ct)
end
-- 过滤函数：判断目标卡是否为「魔族之链」且可以盖放
function c24662957.stfilter(c)
	return c:IsCode(50078509) and c:IsSSetable()
end
-- 效果处理函数：将目标怪兽除外并设置返回效果，若满足条件则可选择盖放「魔族之链」
function c24662957.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效且为怪兽卡并将其除外
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(24662957,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
		-- 创建一个在结束阶段触发的效果，用于将目标怪兽返回场上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c24662957.retcon)
		e1:SetOperation(c24662957.retop)
		-- 记录当前回合数用于后续判断
		e1:SetLabel(Duel.GetTurnCount())
		-- 将创建的效果注册到场上
		Duel.RegisterEffect(e1,tp)
		-- 获取自己卡组与墓地中所有可盖放的「魔族之链」
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c24662957.stfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		-- 判断是否满足盖放「魔族之链」的条件：自己场上存在「红莲魔龙」或其同调怪兽且有可盖放的「魔族之链」
		if e:GetLabel()>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(24662957,0)) then  --"是否盖放「魔族之链」？"
			-- 中断当前效果处理流程，使后续处理不与当前效果同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要盖放的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sc=g:Select(tp,1,1,nil)
			-- 将选择的「魔族之链」盖放
			Duel.SSet(tp,sc)
		end
	end
end
-- 判断是否到结束阶段且目标怪兽仍处于除外状态
function c24662957.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 判断当前回合数与记录的回合数不同且目标怪兽仍处于除外状态
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(24662957)~=0
end
-- 将目标怪兽返回场上
function c24662957.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽以除外前的表示形式返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
