--エネミーコントローラー
-- 效果：
-- ①：可以从以下效果选择1个发动。
-- ●以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽的表示形式变更。
-- ●把自己场上1只怪兽解放，以对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽的控制权直到结束阶段得到。
function c98045062.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。●以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽的表示形式变更。●把自己场上1只怪兽解放，以对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽的控制权直到结束阶段得到。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE+TIMING_STANDBY_PHASE,TIMING_BATTLE_PHASE)
	e1:SetCost(c98045062.cost)
	e1:SetTarget(c98045062.target)
	e1:SetOperation(c98045062.activate)
	c:RegisterEffect(e1)
end
-- 暂存发动代价标记（由于在target中才决定是否解放怪兽，因此在cost中先设置Label为9，用于在target中区分是否需要检测/支付解放怪兽的代价）
function c98045062.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(9)
	return true
end
-- 过滤条件：对方场上表侧表示且可以变更表示形式的怪兽
function c98045062.filter1(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 过滤条件：对方场上表侧表示且可以转移控制权的怪兽
function c98045062.filter2(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged(true)
end
-- 过滤条件：作为解放代价的怪兽（解放该怪兽后，自身场上必须有空位容纳夺取控制权的怪兽，且对方场上存在可夺取控制权的怪兽）
function c98045062.cfilter(c,tp)
	-- 检查将该怪兽解放后，自身场上是否有可用于放置夺取控制权怪兽的怪兽区域
	return Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
		-- 检查对方场上是否存在除被解放怪兽以外的、可作为夺取控制权对象的表侧表示怪兽
		and Duel.IsExistingTarget(c98045062.filter2,tp,0,LOCATION_MZONE,1,c)
end
-- 效果发动时的对象选择与效果分支选择处理
function c98045062.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c98045062.filter1(chkc)
		else
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c98045062.filter2(chkc)
		end
	end
	-- 检查是否满足发动效果1（变更表示形式）的条件
	local b1=Duel.IsExistingTarget(c98045062.filter1,tp,0,LOCATION_MZONE,1,nil)
	local b2=nil
	if e:GetLabel()==9 then
		-- 检查是否满足发动效果2（解放怪兽夺取控制权）的条件（在发动阶段，需要检查可解放的怪兽）
		b2=Duel.CheckReleaseGroup(tp,c98045062.cfilter,1,nil,tp)
	else
		-- 在非发动阶段（如效果处理或不支付代价的特殊情况）检查自身场上是否有空余怪兽区域
		b2=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>0
			-- 检查对方场上是否存在可作为夺取控制权对象的表侧表示怪兽
			and Duel.IsExistingTarget(c98045062.filter2,tp,0,LOCATION_MZONE,1,nil)
	end
	if chk==0 then
		e:SetLabel(0)
		return b1 or b2
	end
	local sel=0
	-- 提示玩家选择要发动的效果
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	if b1 and b2 then
		-- 玩家可从“变更表示形式”和“夺取控制权”中选择一个效果发动
		sel=Duel.SelectOption(tp,aux.Stringid(98045062,0),aux.Stringid(98045062,1))  --"变更对方场上1只表侧表示怪兽的表示形式/获得对方场上1只表侧表示的怪兽的控制权"
	elseif b1 then
		-- 玩家只能选择“变更表示形式”效果发动
		sel=Duel.SelectOption(tp,aux.Stringid(98045062,0))  --"变更对方场上1只表侧表示怪兽的表示形式"
	else
		-- 玩家只能选择“夺取控制权”效果发动（返回值加1以匹配分支索引）
		sel=Duel.SelectOption(tp,aux.Stringid(98045062,1))+1  --"获得对方场上1只表侧表示的怪兽的控制权"
	end
	if sel==0 then
		-- 提示玩家选择要改变表示形式的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 选择对方场上1只表侧表示怪兽作为变更表示形式的对象
		local g=Duel.SelectTarget(tp,c98045062.filter1,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置当前连锁的操作信息为改变表示形式
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	else
		if e:GetLabel()==9 then
			-- 玩家选择自己场上1只怪兽作为解放的代价
			local rg=Duel.SelectReleaseGroup(tp,c98045062.cfilter,1,1,nil,tp)
			-- 将选择的怪兽解放
			Duel.Release(rg,REASON_COST)
		end
		-- 提示玩家选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 选择对方场上1只表侧表示怪兽作为夺取控制权的对象
		local g=Duel.SelectTarget(tp,c98045062.filter2,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置当前连锁的操作信息为夺取控制权
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	end
	e:SetLabel(sel)
end
-- 效果处理的执行函数
function c98045062.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if e:GetLabel()==0 then
			-- 将对象怪兽的表示形式变更（表侧攻击表示变成表侧守备表示，表侧守备表示变成表侧攻击表示）
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
		else
			-- 得到对象怪兽的控制权，直到结束阶段
			Duel.GetControl(tc,tp,PHASE_END,1)
		end
	end
end
