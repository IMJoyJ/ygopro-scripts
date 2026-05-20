--ヌメロン・ダイレクト
-- 效果：
-- ①：自己的场地区域有「源数网络」存在，自己场上没有怪兽存在的场合才能发动。从额外卡组把最多4只「源数之门」超量怪兽特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽在结束阶段除外。这个效果的发动后，直到回合结束时自己只能有1次把怪兽召唤·特殊召唤。
function c77402960.initial_effect(c)
	-- 注册卡片记有「源数网络」的卡名信息
	aux.AddCodeList(c,41418852)
	-- 开启全局特殊召唤次数限制标记
	Duel.EnableGlobalFlag(GLOBALFLAG_SPSUMMON_COUNT)
	-- ①：自己的场地区域有「源数网络」存在，自己场上没有怪兽存在的场合才能发动。从额外卡组把最多4只「源数之门」超量怪兽特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽在结束阶段除外。这个效果的发动后，直到回合结束时自己只能有1次把怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c77402960.condition)
	e1:SetTarget(c77402960.target)
	e1:SetOperation(c77402960.activate)
	c:RegisterEffect(e1)
end
-- 判定发动条件是否满足的函数
function c77402960.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的场地区域是否有「源数网络」存在，且自己场上没有怪兽存在
	return Duel.IsEnvironment(41418852,tp,LOCATION_FZONE) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤额外卡组中可以特殊召唤的「源数之门」超量怪兽的辅助函数
function c77402960.spfilter(c,e,tp)
	-- 检查卡片是否为「源数之门」超量怪兽、能否特殊召唤，且额外怪兽区域有可用位置
	return c:IsSetCard(0x114a) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动时的目标选择与操作信息设置函数
function c77402960.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1只满足条件的「源数之门」超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c77402960.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤里侧表示超量怪兽的辅助函数
function c77402960.exfilter1(c)
	return c:IsFacedown() and c:IsType(TYPE_XYZ)
end
-- 过滤表侧表示灵摆怪兽的辅助函数
function c77402960.exfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 筛选要特殊召唤的怪兽组合的辅助函数
function c77402960.fselect(g,ft1,ft2,ect,ft)
	-- 检查所选卡片组是否卡名各不相同，且数量不超过可用怪兽区域和特殊召唤次数限制
	return aux.dncheck(g) and #g<=ft and #g<=ect
		and g:FilterCount(c77402960.exfilter1,nil)<=ft1
		and g:FilterCount(c77402960.exfilter2,nil)<=ft2
end
-- 效果处理函数
function c77402960.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取额外卡组中超量怪兽可特殊召唤的区域数量
	local ft1=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ)
	-- 获取额外卡组中灵摆怪兽可特殊召唤的区域数量
	local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetUsableMZoneCount(tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		if ft>0 then ft=1 end
	end
	-- 计算受特殊召唤次数限制影响后的最大可召唤数量
	local ect=(c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or ft
	if ect>0 and (ft1>0 or ft2>0) then
		-- 获取额外卡组中所有满足条件的「源数之门」超量怪兽
		local sg=Duel.GetMatchingGroup(c77402960.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
		if sg:GetCount()>0 then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local rg=sg:SelectSubGroup(tp,c77402960.fselect,false,1,4,ft1,ft2,ect,ft)
			if rg:GetCount()>0 then
				local fid=c:GetFieldID()
				local tc=rg:GetFirst()
				while tc do
					-- 逐步将选中的怪兽以表侧表示特殊召唤
					Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
					tc:RegisterFlagEffect(77402960,RESET_EVENT+RESETS_STANDARD,0,1,fid)
					tc=rg:GetNext()
				end
				-- 完成特殊召唤的处理
				Duel.SpecialSummonComplete()
				rg:KeepAlive()
				-- 这个效果特殊召唤的怪兽在结束阶段除外。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetCountLimit(1)
				e1:SetLabel(fid)
				e1:SetLabelObject(rg)
				e1:SetCondition(c77402960.rmcon)
				e1:SetOperation(c77402960.rmop)
				-- 注册在结束阶段将特殊召唤的怪兽除外的效果
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
	-- 这个效果的发动后，直到回合结束时自己只能有1次把怪兽召唤·特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetLabel(c77402960.getsummoncount(tp))
	e2:SetTarget(c77402960.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制玩家召唤怪兽的效果
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 注册限制玩家特殊召唤怪兽的效果
	Duel.RegisterEffect(e3,tp)
	-- 这个效果的发动后，直到回合结束时自己只能有1次把怪兽召唤·特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,0)
	e6:SetLabel(c77402960.getsummoncount(tp))
	e6:SetValue(c77402960.countval)
	e6:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制玩家剩余特殊召唤次数的效果
	Duel.RegisterEffect(e6,tp)
end
-- 获取玩家在本回合已经进行的召唤和特殊召唤的总次数
function c77402960.getsummoncount(tp)
	-- 计算并返回召唤次数与特殊召唤次数之和
	return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)+Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
end
-- 过滤出带有当前效果标识的怪兽
function c77402960.rmfilter(c,fid)
	return c:GetFlagEffectLabel(77402960)==fid
end
-- 结束阶段除外效果的发动条件判定函数
function c77402960.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c77402960.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段除外效果的执行函数
function c77402960.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c77402960.rmfilter,nil,e:GetLabel())
	-- 以效果原因将目标怪兽表侧表示除外
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
-- 召唤与特殊召唤限制的判定函数
function c77402960.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c77402960.getsummoncount(sump)>e:GetLabel()
end
-- 计算剩余特殊召唤次数的辅助函数
function c77402960.countval(e,re,tp)
	if c77402960.getsummoncount(tp)>e:GetLabel() then return 0 else return 1 end
end
