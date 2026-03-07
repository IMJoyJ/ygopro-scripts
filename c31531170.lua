--共鳴する振動
-- 效果：
-- ①：对方的灵摆区域有2张卡存在的场合，以那2张卡为对象才能发动。那2张卡在对方的灵摆区域存在，这个回合自己灵摆召唤的场合，可以用对方一组灵摆刻度来灵摆召唤。那个场合，不是从额外卡组中不能把怪兽灵摆召唤。
function c31531170.initial_effect(c)
	-- ①：对方的灵摆区域有2张卡存在的场合，以那2张卡为对象才能发动。那2张卡在对方的灵摆区域存在，这个回合自己灵摆召唤的场合，可以用对方一组灵摆刻度来灵摆召唤。那个场合，不是从额外卡组中不能把怪兽灵摆召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c31531170.target)
	e1:SetOperation(c31531170.activate)
	c:RegisterEffect(e1)
end
-- 检查是否满足发动条件：对方灵摆区域有2张卡，且当前玩家未使用过灵摆召唤权或拥有额外灵摆召唤权
function c31531170.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 初始化灵摆召唤检查标记列表
	if not aux.PendulumChecklist then aux.PendulumChecklist=0 end
	-- 判断是否满足发动条件：当前玩家未使用过灵摆召唤权或拥有额外灵摆召唤权，并且对方灵摆区域有2张卡
	if chk==0 then return (aux.PendulumChecklist&(0x1<<tp)==0 or Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)) and Duel.IsExistingTarget(nil,tp,0,LOCATION_PZONE,2,nil) end
	-- 获取对方灵摆区域的卡组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_PZONE)
	-- 设置目标卡为对方灵摆区域的卡
	Duel.SetTargetCard(g)
end
-- 发动效果：将对方灵摆区域的2张卡作为对象，使自己可以使用对方的灵摆刻度进行灵摆召唤
function c31531170.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方灵摆区域的左侧灵摆卡
	local tc1=Duel.GetFieldCard(1-tp,LOCATION_PZONE,0)
	-- 获取对方灵摆区域的右侧灵摆卡
	local tc2=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
	if not tc1:IsRelateToEffect(e) or not tc2:IsRelateToEffect(e) then return end
	-- 创建一个用于灵摆召唤的特殊召唤规则效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(1163)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_BOTH_SIDE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c31531170.pendcon)
	e1:SetOperation(c31531170.pendop)
	e1:SetValue(SUMMON_TYPE_PENDULUM)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc1:RegisterEffect(e1)
	tc1:RegisterFlagEffect(31531170,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,tc2:GetFieldID())
	tc2:RegisterFlagEffect(31531170,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,tc1:GetFieldID())
end
-- 判断灵摆召唤条件是否满足：检查是否满足额外灵摆召唤权、灵摆刻度范围、是否有足够的召唤位置
function c31531170.pendcon(e,c,og)
	if c==nil then return true end
	local tp=e:GetOwnerPlayer()
	-- 获取当前玩家受到的额外灵摆召唤效果
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
	-- 如果当前玩家已使用过灵摆召唤权但没有额外灵摆召唤权，则返回false
	if aux.PendulumChecklist&(0x1<<tp)~=0 and #eset==0 then return false end
	-- 获取对方灵摆区域的右侧灵摆卡
	local rpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
	if rpz==nil or rpz:GetFieldID()~=c:GetFlagEffectLabel(31531170) then return false end
	local lscale=c:GetLeftScale()
	local rscale=rpz:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	-- 获取当前玩家额外卡组中可以灵摆召唤的怪兽数量
	local ft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	if ft<=0 then return false end
	if og then
		-- 如果传入的卡组中存在满足条件的怪兽，则返回true
		return og:IsExists(aux.PConditionFilter,1,nil,e,tp,lscale,rscale,eset)
	else
		-- 如果额外卡组中存在满足条件的怪兽，则返回true
		return Duel.IsExistingMatchingCard(aux.PConditionFilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lscale,rscale,eset)
	end
end
-- 处理灵摆召唤操作：选择要特殊召唤的怪兽并应用额外灵摆召唤权
function c31531170.pendop(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
	local tp=e:GetOwnerPlayer()
	-- 获取当前玩家受到的额外灵摆召唤效果
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
	-- 获取对方灵摆区域的右侧灵摆卡
	local rpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
	local lscale=c:GetLeftScale()
	local rscale=rpz:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	-- 获取当前玩家额外卡组中可以灵摆召唤的怪兽数量
	local ft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 检测是否受到【青眼精灵龙】效果影响，限制召唤数量
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	if ect~=nil then ft=math.min(ft,ect) end
	local tg=nil
	if og then
		-- 从传入的卡组中筛选出额外卡组中的满足条件的怪兽
		tg=og:Filter(Card.IsLocation,nil,LOCATION_EXTRA):Filter(aux.PConditionFilter,nil,e,tp,lscale,rscale,eset)
	else
		-- 从额外卡组中筛选出满足条件的怪兽
		tg=Duel.GetMatchingGroup(aux.PConditionFilter,tp,LOCATION_EXTRA,0,nil,e,tp,lscale,rscale,eset)
	end
	local ce=nil
	-- 判断当前玩家是否未使用过灵摆召唤权
	local b1=aux.PendulumChecklist&(0x1<<tp)==0
	local b2=#eset>0
	if b1 and b2 then
		local options={1163}
		for _,te in ipairs(eset) do
			table.insert(options,te:GetDescription())
		end
		-- 让玩家选择使用哪个额外灵摆召唤效果
		local op=Duel.SelectOption(tp,table.unpack(options))
		if op>0 then
			ce=eset[op]
		end
	elseif b2 and not b1 then
		local options={}
		for _,te in ipairs(eset) do
			table.insert(options,te:GetDescription())
		end
		-- 让玩家选择使用哪个额外灵摆召唤效果
		local op=Duel.SelectOption(tp,table.unpack(options))
		ce=eset[op+1]
	end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 根据选择的额外灵摆召唤效果筛选并选择要特殊召唤的怪兽
	local g=tg:FilterSelect(tp,aux.PConditionExtraFilterSpecific,0,ft,nil,e,tp,lscale,rscale,ce)
	if #g==0 then return end
	if ce then
		-- 提示发动额外灵摆召唤效果的卡牌编号
		Duel.Hint(HINT_CARD,0,ce:GetOwner():GetOriginalCode())
		ce:UseCountLimit(tp)
	else
		-- 标记当前玩家已使用过灵摆召唤权
		aux.PendulumChecklist=aux.PendulumChecklist|(0x1<<tp)
	end
	-- 提示发动此卡的卡牌编号
	Duel.Hint(HINT_CARD,0,31531170)
	sg:Merge(g)
	-- 提示选中的灵摆卡
	Duel.HintSelection(Group.FromCards(c))
	-- 提示选中的灵摆卡
	Duel.HintSelection(Group.FromCards(rpz))
end
