--真炎の爆発
-- 效果：
-- ①：从自己墓地把守备力200的炎属性怪兽尽可能特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段除外。
function c74845897.initial_effect(c)
	-- ①：从自己墓地把守备力200的炎属性怪兽尽可能特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c74845897.tg)
	e1:SetOperation(c74845897.op)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地守备力200的炎属性且可以特殊召唤的怪兽
function c74845897.filter(c,e,tp)
	return c:IsDefense(200) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的开端检测：检查自己场上是否有空位，以及墓地是否存在至少1只满足条件的怪兽
function c74845897.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c74845897.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置当前处理的连锁的操作信息：从墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：尽可能从墓地特殊召唤满足条件的怪兽，并注册回合结束时除外的效果
function c74845897.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取自己墓地所有满足过滤条件的怪兽组
	local tg=Duel.GetMatchingGroup(c74845897.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local g=nil
	if tg:GetCount()>ft then
		-- 给玩家发送提示信息：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=tg:Select(tp,ft,ft,nil)
	else
		g=tg
	end
	if g:GetCount()>0 then
		local fid=e:GetHandler():GetFieldID()
		local tc=g:GetFirst()
		while tc do
			-- 将目标怪兽以表侧表示特殊召唤（分解步骤）
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(74845897,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
			tc=g:GetNext()
		end
		-- 完成所有怪兽的特殊召唤处理
		Duel.SpecialSummonComplete()
		g:KeepAlive()
		-- 这个效果特殊召唤的怪兽在这个回合的结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(g)
		e1:SetCondition(c74845897.rmcon)
		e1:SetOperation(c74845897.rmop)
		-- 在全局环境注册该延迟除外的场上效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤条件：检查卡片是否带有本次特殊召唤对应的标记（fid）
function c74845897.rmfilter(c,fid)
	return c:GetFlagEffectLabel(74845897)==fid
end
-- 除外效果的发动条件：检查被特殊召唤的怪兽组中是否仍有带有对应标记的卡存在，若无则重置该效果
function c74845897.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c74845897.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 除外效果的操作：筛选出仍带有对应标记的怪兽并将其除外
function c74845897.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c74845897.rmfilter,nil,e:GetLabel())
	g:DeleteGroup()
	-- 因效果将目标怪兽表侧表示除外
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
