--キラーチューン・クラックル
-- 效果：
-- 「杀手级调整曲·削波手」＋调整1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。把对方的额外卡组确认，那之内的1张直到结束阶段表侧除外。那之后，可以让这张卡的攻击力上升除外的怪兽的攻击力数值。
-- ②：同调召唤的这张卡被送去墓地的场合才能发动。这张卡特殊召唤。那之后，以下效果可以适用。
-- ●把对方的额外卡组确认，那之内的2张直到结束阶段表侧除外。
local s,id,o=GetID()
-- 初始化效果函数，设置同调召唤条件、效果注册等
function s.initial_effect(c)
	-- 为该卡添加融合/同调召唤所需的素材代码列表
	aux.AddMaterialCodeList(c,43904702)
	-- 设置该卡的同调召唤手续，允许使用特定代码的调整作为素材
	aux.AddSynchroMixProcedure(c,aux.FilterBoolFunction(Card.IsCode,43904702),nil,nil,aux.Tuner(nil),1,99)
	c:EnableReviveLimit()
	-- 效果①：这张卡同调召唤的场合才能发动。把对方的额外卡组确认，那之内的1张直到结束阶段表侧除外。那之后，可以让这张卡的攻击力上升除外的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"确认额外卡组并除外"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- 效果②：同调召唤的这张卡被送去墓地的场合才能发动。这张卡特殊召唤。那之后，以下效果可以适用。●把对方的额外卡组确认，那之内的2张直到结束阶段表侧除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 设置该卡的特殊效果，防止被无效或复制
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(21142671)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：该卡必须是同调召唤成功
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①的发动时点：确认额外卡组并选择1张除外
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：额外卡组中是否有可除外的卡
	if chk==0 then return Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)>0 end
	-- 设置操作信息：提示将要除外1张额外卡组的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end
-- 效果①的发动处理：确认额外卡组并选择1张除外，然后可让攻击力上升
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方额外卡组的所有卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g>0 then
		-- 确认对方额外卡组的卡
		Duel.ConfirmCards(tp,g,true)
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
		local tc=sg:GetFirst()
		-- 将选中的卡除外
		if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			local fid=c:GetFieldID()
			-- 获取实际被操作的卡组
			local og=Duel.GetOperatedGroup()
			local oc=og:GetFirst()
			if oc then
				oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,4))  --"直到结束阶段除外"
				-- 设置除外卡在结束阶段返回卡组的效果
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetReset(RESET_PHASE+PHASE_END)
				e1:SetLabel(fid)
				e1:SetLabelObject(oc)
				e1:SetCountLimit(1)
				e1:SetOperation(s.retop)
				-- 注册结束阶段返回卡组的效果
				Duel.RegisterEffect(e1,tp)
				local atk=oc:GetAttack()
				-- 询问玩家是否让攻击力上升
				if c:IsRelateToChain() and c:IsFaceup() and atk>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否上升攻击力？"
					-- 设置攻击力上升的效果
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_UPDATE_ATTACK)
					e2:SetValue(atk)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
					c:RegisterEffect(e2)
				end
			end
		end
		-- 洗切对方额外卡组
		Duel.ShuffleExtra(1-tp)
	end
end
-- 结束阶段返回卡组的处理函数
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local tc=e:GetLabelObject()
	if tc and tc:GetFlagEffectLabel(id)==fid then
		-- 将卡送回卡组
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 效果②的发动条件：该卡必须是同调召唤后被送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果②的发动时点：特殊召唤并确认额外卡组
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足发动条件：场上是否有空位且该卡可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：提示将要特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的发动处理：特殊召唤该卡并确认额外卡组，然后可除外2张卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤条件：该卡可特殊召唤且未被王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取对方额外卡组中所有可除外的卡
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)
		-- 判断是否满足除外2张卡的条件：额外卡组中至少有2张可除外的卡
		if #g>=2 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否除外额外卡组？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 确认对方额外卡组的卡
			Duel.ConfirmCards(tp,Duel.GetFieldGroup(tp,0,LOCATION_EXTRA),true)
			-- 提示玩家选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local sg=g:FilterSelect(tp,Card.IsAbleToRemove,2,2,nil)
			if #sg==2 then
				local fid=c:GetFieldID()
				-- 将选中的2张卡除外
				if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
					-- 获取实际被操作的卡组
					local og=Duel.GetOperatedGroup()
					-- 遍历被除外的卡
					for oc in aux.Next(og) do
						oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,4))  --"直到结束阶段除外"
					end
					og:KeepAlive()
					-- 设置除外卡在结束阶段返回卡组的效果
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					e1:SetCode(EVENT_PHASE+PHASE_END)
					e1:SetReset(RESET_PHASE+PHASE_END)
					e1:SetLabel(fid)
					e1:SetLabelObject(og)
					e1:SetCountLimit(1)
					e1:SetOperation(s.retop2)
					-- 注册结束阶段返回卡组的效果
					Duel.RegisterEffect(e1,tp)
				end
			end
			-- 洗切对方额外卡组
			Duel.ShuffleExtra(1-tp)
		end
	end
end
-- 返回卡组的过滤函数
function s.retfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 结束阶段返回卡组的处理函数
function s.retop2(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local tg=e:GetLabelObject():Filter(s.retfilter,nil,fid)
	-- 将卡送回卡组
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
