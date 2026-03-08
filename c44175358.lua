--分裂するプラナリア
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把场上的这张卡除外才能发动。从卡组把2只同名的昆虫族·3星怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段除外。
local s,id,o=GetID()
-- 创建并注册一个起动效果，用于发动特殊召唤昆虫族3星怪兽的效果
function s.initial_effect(c)
	-- ①：把场上的这张卡除外才能发动。从卡组把2只同名的昆虫族·3星怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	-- 将此卡除外作为发动cost
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 过滤满足等级为3、种族为昆虫且可以特殊召唤的怪兽
function s.filter(c,e,tp)
	return c:IsLevel(3) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断卡片组中是否所有卡片的卡号相同
function s.fselect(g)
	return g:GetClassCount(Card.GetCode)==1
end
-- 检测是否满足发动条件：未被青眼精灵龙效果影响、场上怪兽区数量大于1、卡组中存在符合条件的2只同名昆虫族3星怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的卡组怪兽
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测场上怪兽区是否至少有2个空位
		and Duel.GetMZoneCount(tp,e:GetHandler())>1
		and g:CheckSubGroup(s.fselect,2,2) end
	-- 设置连锁操作信息为特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作：检测青眼精灵龙效果、检测场上怪兽区数量、选择2只符合条件的怪兽进行特殊召唤并设置效果无效化和结束阶段除外
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检测场上怪兽区是否至少有2个空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	-- 获取满足条件的卡组怪兽
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,2,2)
	if sg:GetCount()==2 then
		local fid=e:GetHandler():GetFieldID()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 遍历选中的怪兽进行处理
		for tc in aux.Next(sg) do
			-- 将怪兽特殊召唤到场上
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 使特殊召唤的怪兽效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 使特殊召唤的怪兽效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
		sg:KeepAlive()
		-- 注册结束阶段除外效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(sg)
		e3:SetCondition(s.descon)
		e3:SetOperation(s.desop)
		-- 将结束阶段除外效果注册给玩家
		Duel.RegisterEffect(e3,tp)
	end
end
-- 判断怪兽是否为本次特殊召唤的怪兽
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 判断是否满足结束阶段除外条件
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 执行结束阶段除外操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.desfilter,nil,e:GetLabel())
	-- 将符合条件的怪兽除外
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
