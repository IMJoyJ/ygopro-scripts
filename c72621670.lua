--ダブルマジックアームバインド
-- 效果：
-- ①：把自己场上2只怪兽解放，以对方场上2只表侧表示怪兽为对象才能发动。那2只表侧表示怪兽的控制权直到自己结束阶段得到。
function c72621670.initial_effect(c)
	-- ①：把自己场上2只怪兽解放，以对方场上2只表侧表示怪兽为对象才能发动。那2只表侧表示怪兽的控制权直到自己结束阶段得到。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c72621670.cost)
	e1:SetTarget(c72621670.target)
	e1:SetOperation(c72621670.activate)
	c:RegisterEffect(e1)
end
-- 暂存代价检查标记，用于在target中区分是chk==0的检查还是实际发动时的代价支付
function c72621670.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤出可以改变控制权的表侧表示怪兽
function c72621670.filter(c,check)
	return c:IsFaceup() and c:IsAbleToChangeControler(check)
end
-- 检查所选的解放怪兽组是否满足怪兽区域数量、可解放性以及对方场上存在足够对象的要求
function c72621670.fselect(g,tp)
	-- 检查解放所选怪兽后，自己场上是否有足够的怪兽区域来放置夺取控制权的怪兽
	return Duel.GetMZoneCount(tp,g,tp,LOCATION_REASON_CONTROL)>1
		-- 检查所选的怪兽组是否可以被解放
		and Duel.CheckReleaseGroup(tp,aux.IsInGroup,g:GetCount(),nil,g)
		-- 检查对方场上是否存在至少2只不属于解放怪兽组的、可作为对象的表侧表示怪兽
		and Duel.IsExistingTarget(c72621670.filter,tp,0,LOCATION_MZONE,2,g,true)
end
-- 效果发动时的对象选择与代价支付处理
function c72621670.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c72621670.filter(chkc,false) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 获取玩家场上所有可解放的怪兽
			local rg=Duel.GetReleaseGroup(tp)
			return rg:CheckSubGroup(c72621670.fselect,2,2,tp)
		else
			-- 检查对方场上是否存在2只可作为对象的表侧表示怪兽
			return Duel.IsExistingTarget(c72621670.filter,tp,0,LOCATION_MZONE,2,nil,false)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 获取玩家场上所有可解放的怪兽
		local rg=Duel.GetReleaseGroup(tp)
		-- 提示玩家选择要解放的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		local sg=rg:SelectSubGroup(tp,c72621670.fselect,false,2,2,tp)
		-- 强制使用代替解放效果的次数（如暗影敌托邦）
		aux.UseExtraReleaseCount(sg,tp)
		-- 解放选择的怪兽以支付发动代价
		Duel.Release(sg,REASON_COST)
	end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上2只表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c72621670.filter,tp,0,LOCATION_MZONE,2,2,nil,false)
	-- 设置效果处理信息为改变2只怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,2,0,0)
end
-- 过滤出仍存在于场上且表侧表示的对象怪兽
function c72621670.tfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFaceup()
end
-- 效果处理的执行函数，用于获得对象怪兽的控制权
function c72621670.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍合法的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c72621670.tfilter,nil,e)
	if g:GetCount()<2 then return end
	local rct=1
	-- 若当前不是自己的回合，则将控制权维持的结束阶段计数设为2（即直到下个自己回合的结束阶段）
	if Duel.GetTurnPlayer()~=tp then rct=2 end
	-- 获得目标怪兽的控制权，直到指定的结束阶段
	Duel.GetControl(g,tp,PHASE_END,rct)
end
