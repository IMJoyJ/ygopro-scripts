--ミミックリル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。自己卡组最上面的卡翻开，那是怪兽的场合，那只怪兽特殊召唤，这张卡回到持有者卡组最下面。不是的场合或者不能特殊召唤的场合，那张卡回到卡组最下面。这个效果特殊召唤的怪兽在结束阶段回到持有者卡组最下面。
function c74879881.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：自己主要阶段才能发动。自己卡组最上面的卡翻开，那是怪兽的场合，那只怪兽特殊召唤，这张卡回到持有者卡组最下面。不是的场合或者不能特殊召唤的场合，那张卡回到卡组最下面。这个效果特殊召唤的怪兽在结束阶段回到持有者卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74879881,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,74879881)
	e1:SetTarget(c74879881.sptg)
	e1:SetOperation(c74879881.spop)
	c:RegisterEffect(e1)
end
-- 检查是否满足发动效果的条件（玩家可特召、场上有空位、不受特定卡片限制、卡组有卡）
function c74879881.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以进行特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummon(tp)
		-- 检查自己场上的主要怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否受到不能特殊召唤的限制效果影响
		and not Duel.IsPlayerAffectedByEffect(tp,63060238)
		-- 检查自己卡组是否有卡
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
-- 效果处理：翻开卡组最上方的卡，是怪兽则特殊召唤并让这张卡回卡组底，否则将翻开的卡放回卡组底
function c74879881.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若卡组没有卡，则不处理效果
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 确认（翻开）自己卡组最上方的一张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取自己卡组最上方的一张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 使接下来的操作不触发系统自动洗牌检测
		Duel.DisableShuffleCheck()
		-- 尝试将翻开的卡特殊召唤，并判断是否特殊召唤成功
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local c=e:GetHandler()
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(74879881,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- 这张卡回到持有者卡组最下面。这个效果特殊召唤的怪兽在结束阶段回到持有者卡组最下面。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(tc)
			e1:SetCondition(c74879881.retcon)
			e1:SetOperation(c74879881.retop)
			-- 注册在结束阶段适用的全局效果
			Duel.RegisterEffect(e1,tp)
			if c:IsRelateToEffect(e) then
				-- 将这张卡送回持有者卡组最下面
				Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		end
	else
		-- 将翻开的卡移动到卡组最下面
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
-- 检查特殊召唤的怪兽是否仍在场上且标记未改变，若已离场则重置该效果
function c74879881.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(74879881)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段将特殊召唤的怪兽送回卡组最下方的效果处理
function c74879881.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将特殊召唤的怪兽送回持有者卡组最下面
	Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
end
