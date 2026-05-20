--緊急発進
-- 效果：
-- 对方场上的怪兽数量比衍生物以外的自己场上的怪兽数量多的场合，把自己场上的「幻兽机衍生物」任意数量解放才能发动。把解放的衍生物数量的名字带有「幻兽机」的怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段时回到持有者卡组。「紧急起飞」在1回合只能发动1张。
function c83054225.initial_effect(c)
	-- 对方场上的怪兽数量比衍生物以外的自己场上的怪兽数量多的场合，把自己场上的「幻兽机衍生物」任意数量解放才能发动。把解放的衍生物数量的名字带有「幻兽机」的怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段时回到持有者卡组。「紧急起飞」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c83054225.spcon)
	e1:SetTarget(c83054225.sptg)
	e1:SetOperation(c83054225.spop)
	c:RegisterEffect(e1)
end
-- 过滤非衍生物怪兽的条件函数
function c83054225.cfilter(c)
	return not c:IsType(TYPE_TOKEN)
end
-- 效果发动条件判断函数
function c83054225.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 比较对方场上的怪兽数量是否大于自己场上非衍生物的怪兽数量
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetMatchingGroupCount(c83054225.cfilter,tp,LOCATION_MZONE,0,nil)
end
-- 过滤卡组中可特殊召唤的「幻兽机」怪兽的条件函数
function c83054225.spfilter(c,e,tp)
	return c:IsSetCard(0x101b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与代价支付处理函数
function c83054225.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中满足特殊召唤条件的「幻兽机」怪兽数量
	local ct=Duel.GetMatchingGroupCount(c83054225.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then
		-- 检查本回合是否已发动过此卡，以及自己场上的怪兽区域是否已满
		if Duel.GetFlagEffect(tp,83054225)~=0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<0 then return false end
		-- 检查卡组中是否有可特召的怪兽，且自己场上是否存在至少1只可解放的「幻兽机衍生物」
		return ct>0 and Duel.CheckReleaseGroup(tp,Card.IsCode,1,nil,31533705)
	end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 让玩家选择任意数量（不超过卡组可特召怪兽数量）的「幻兽机衍生物」解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsCode,1,ct,nil,31533705)
	-- 解放选中的「幻兽机衍生物」作为发动的代价
	Duel.Release(g,REASON_COST)
	e:SetLabel(g:GetCount())
	-- 为玩家注册1回合只能发动1张的誓约标识效果
	Duel.RegisterFlagEffect(tp,83054225,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
	-- 设置特殊召唤效果的操作信息，指定从卡组特殊召唤对应数量的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,g:GetCount(),tp,LOCATION_DECK)
end
-- 效果处理函数，执行特殊召唤并注册结束阶段回到卡组的效果
function c83054225.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上空余的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local ct=e:GetLabel()
	if ft<ct then return end
	-- 获取卡组中所有满足特殊召唤条件的「幻兽机」怪兽
	local g=Duel.GetMatchingGroup(c83054225.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()<ct then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,ct,ct,nil)
	local fid=e:GetHandler():GetFieldID()
	local tc=sg:GetFirst()
	while tc do
		-- 将选中的怪兽以表侧表示特殊召唤到场上（分解步骤）
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(83054225,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc=sg:GetNext()
	end
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
	sg:KeepAlive()
	-- 这个效果特殊召唤的怪兽在结束阶段时回到持有者卡组。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(sg)
	e1:SetCondition(c83054225.retcon)
	e1:SetOperation(c83054225.retop)
	-- 注册在结束阶段触发的全局延迟效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤出带有本次特殊召唤标记的怪兽的条件函数
function c83054225.retfilter(c,fid)
	return c:GetFlagEffectLabel(83054225)==fid
end
-- 检查场上是否存在需要回到卡组的怪兽，若不存在则重置该延迟效果
function c83054225.retcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c83054225.retfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段时，将特殊召唤的怪兽送回持有者卡组的处理函数
function c83054225.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c83054225.retfilter,nil,e:GetLabel())
	-- 将目标怪兽群送回卡组并洗牌
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
