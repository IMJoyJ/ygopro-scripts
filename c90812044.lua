--連鎖召喚
-- 效果：
-- ①：自己场上有超量怪兽2只以上存在的场合，以那之内的1只阶级最低的超量怪兽为对象才能发动。比那只怪兽阶级低的1只超量怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽不能直接攻击，结束阶段回到额外卡组。
function c90812044.initial_effect(c)
	-- ①：自己场上有超量怪兽2只以上存在的场合，以那之内的1只阶级最低的超量怪兽为对象才能发动。比那只怪兽阶级低的1只超量怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽不能直接攻击，结束阶段回到额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c90812044.target)
	e1:SetOperation(c90812044.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的超量怪兽
function c90812044.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 过滤条件：额外卡组中阶级比目标怪兽低且能特殊召唤的超量怪兽
function c90812044.filter(c,e,tp,rk)
	return c:IsType(TYPE_XYZ) and c:GetRank()<rk
		-- 检查卡片是否可以特殊召唤，以及额外怪兽区域是否有可用空位
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动时的对象选择与可行性检查
function c90812044.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上所有的表侧表示超量怪兽
	local g=Duel.GetMatchingGroup(c90812044.cfilter,tp,LOCATION_MZONE,0,nil)
	local rg,rk=g:GetMinGroup(Card.GetRank)
	if chkc then return rg:IsContains(chkc) end
	if chk==0 then return g:GetCount()>=2 and rg:IsExists(Card.IsCanBeEffectTarget,1,nil,e)
		-- 检查额外卡组是否存在满足特殊召唤条件的超量怪兽
		and Duel.IsExistingMatchingCard(c90812044.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,rk) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=rg:FilterSelect(tp,Card.IsCanBeEffectTarget,1,1,nil,e)
	-- 将选择的怪兽设置为效果处理的对象
	Duel.SetTargetCard(sg)
	-- 设置效果处理信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的执行函数
function c90812044.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local rk=tc:GetRank()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只阶级较低的超量怪兽
	local g=Duel.SelectMatchingCard(tp,c90812044.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,rk)
	local sc=g:GetFirst()
	-- 若成功将选择的怪兽以表侧表示特殊召唤
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽不能直接攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1,true)
		sc:RegisterFlagEffect(90812044,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 结束阶段回到额外卡组。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetLabelObject(sc)
		e2:SetCondition(c90812044.retcon)
		e2:SetOperation(c90812044.retop)
		-- 注册在结束阶段将怪兽送回额外卡组的全局效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 检查特殊召唤的怪兽是否仍带有标记，若无则重置该效果
function c90812044.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(90812044)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 结束阶段将特殊召唤的怪兽送回额外卡组的具体操作
function c90812044.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽送回额外卡组
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
