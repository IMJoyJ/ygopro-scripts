--魔神儀の創造主－クリオルター
-- 效果：
-- 「魔神仪的祝诞」降临。这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，把手卡的这张卡给对方观看才能发动。选1张手卡丢弃，那之后，等级合计直到10星为止选自己墓地的「魔神仪」怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到持有者卡组。
-- ②：只要这张卡在怪兽区域存在，仪式怪兽以外的自己场上的「魔神仪」怪兽攻击力上升2000，效果无效化。
function c96915510.initial_effect(c)
	aux.AddCodeList(c,86758915)
	c:EnableReviveLimit()
	-- ①：自己·对方的主要阶段，把手卡的这张卡给对方观看才能发动。选1张手卡丢弃，那之后，等级合计直到10星为止选自己墓地的「魔神仪」怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,96915510)
	e1:SetCondition(c96915510.spcon)
	e1:SetCost(c96915510.spcost)
	e1:SetTarget(c96915510.sptg)
	e1:SetOperation(c96915510.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，仪式怪兽以外的自己场上的「魔神仪」怪兽攻击力上升2000，效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c96915510.atktg)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(2000)
	c:RegisterEffect(e3)
end
-- 判断当前是否为自己或对方的主要阶段
function c96915510.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 发动代价：确认手卡的这张卡未给对方观看（用于展示手卡的这张卡）
function c96915510.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤函数：筛选自己墓地中可以特殊召唤的「魔神仪」怪兽
function c96915510.spfilter(c,e,tp)
	return c:IsSetCard(0x117) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检测函数：所选怪兽的等级合计是否等于10
function c96915510.spcheck(g)
	return g:GetSum(Card.GetLevel)==10
end
-- 效果发动时的可行性检测与目标选择，并设置特殊召唤的操作信息
function c96915510.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上可用的怪兽区域空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 若怪兽区域无空位，或手卡数量小于1（无法丢弃手卡），则不能发动
		if ft<=0 or Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<1 then return false end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 获取自己墓地中所有满足特殊召唤条件的「魔神仪」怪兽
		local g=Duel.GetMatchingGroup(c96915510.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		return g:CheckSubGroup(c96915510.spcheck,1,ft)
	end
	-- 设置连锁操作信息：从墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：丢弃1张手卡，并特殊召唤等级合计为10的墓地「魔神仪」怪兽，注册结束阶段回到卡组的效果
function c96915510.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家选择并丢弃1张手卡，若成功丢弃则继续处理
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
		-- 重新获取自己场上可用的怪兽区域空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 then return end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 重新获取自己墓地中所有满足特殊召唤条件的「魔神仪」怪兽
		local g=Duel.GetMatchingGroup(c96915510.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 向玩家提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:SelectSubGroup(tp,c96915510.spcheck,false,1,ft)
		if sg then
			local c=e:GetHandler()
			local fid=c:GetFieldID()
			local tc=sg:GetFirst()
			while tc do
				-- 将目标怪兽以表侧表示特殊召唤（分解步骤）
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				tc:RegisterFlagEffect(96915510,RESET_EVENT+RESETS_STANDARD,0,1,fid)
				tc=sg:GetNext()
			end
			-- 完成所有怪兽的特殊召唤处理
			Duel.SpecialSummonComplete()
			sg:KeepAlive()
			-- 这个效果特殊召唤的怪兽在结束阶段回到持有者卡组。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(sg)
			e1:SetCondition(c96915510.retcon)
			e1:SetOperation(c96915510.retop)
			-- 注册全局的结束阶段回到卡组的延迟触发效果
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 过滤函数：筛选出带有本次特殊召唤标记的怪兽
function c96915510.retfilter(c,fid)
	return c:GetFlagEffectLabel(96915510)==fid
end
-- 回到卡组效果的触发条件：若不存在带有标记的怪兽，则清理并重置该效果
function c96915510.retcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c96915510.retfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 回到卡组效果的处理：将所有带有标记的怪兽送回持有者卡组
function c96915510.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c96915510.retfilter,nil,e:GetLabel())
	-- 将目标怪兽群送回卡组并洗牌
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 过滤函数：筛选仪式怪兽以外的自己场上的「魔神仪」怪兽
function c96915510.atktg(e,c)
	return c:IsSetCard(0x117) and not c:IsType(TYPE_RITUAL)
end
