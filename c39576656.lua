--キラーチューン・クラックル
-- 效果：
-- 「杀手级调整曲·削波手」＋调整1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。把对方的额外卡组确认，那之内的1张直到结束阶段表侧除外。那之后，可以让这张卡的攻击力上升除外的怪兽的攻击力数值。
-- ②：同调召唤的这张卡被送去墓地的场合才能发动。这张卡特殊召唤。那之后，以下效果可以适用。
-- ●把对方的额外卡组确认，那之内的2张直到结束阶段表侧除外。
local s,id,o=GetID()
-- 初始化卡片效果：注册同调素材及手续，注册同调召唤成功诱发效果、送墓诱发效果以及规则效果
function s.initial_effect(c)
	-- 将「杀手级调整曲·削波手」记入作为素材的特定卡名列表
	aux.AddMaterialCodeList(c,43904702)
	-- 添加同调召唤手续：「杀手级调整曲·削波手」＋调整1只以上
	aux.AddSynchroMixProcedure(c,aux.FilterBoolFunction(Card.IsCode,43904702),nil,nil,aux.Tuner(nil),1,99)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡同调召唤的场合才能发动。把对方的额外卡组确认，那之内的1张直到结束阶段表侧除外。那之后，可以让这张卡的攻击力上升除外的怪兽的攻击力数值。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：同调召唤的这张卡被送去墓地的场合才能发动。这张卡特殊召唤。那之后，以下效果可以适用。●把对方的额外卡组确认，那之内的2张直到结束阶段表侧除外。
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
	-- 「杀手级调整曲·削波手」＋调整1只以上
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(21142671)
	c:RegisterEffect(e3)
end
-- 效果发动条件：自身同调召唤成功
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果发动目标检查
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方额外卡组是否存在可除外的卡
	if chk==0 then return Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)>0 end
	-- 设置操作信息：将对方额外卡组1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end
-- 效果处理：确认对方额外卡组并除外1张，可让自身攻击力上升该怪兽攻击力数值
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方额外卡组的全部卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g>0 then
		-- 确认对方额外卡组
		Duel.ConfirmCards(tp,g,true)
		-- 提示选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
		local tc=sg:GetFirst()
		-- 将选中的卡直到结束阶段暂时表侧除外
		if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			local fid=c:GetFieldID()
			-- 获取实际除外的卡片组
			local og=Duel.GetOperatedGroup()
			local oc=og:GetFirst()
			if oc then
				oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,4))  --"直到结束阶段除外"
				-- 那之内的1张直到结束阶段表侧除外。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetReset(RESET_PHASE+PHASE_END)
				e1:SetLabel(fid)
				e1:SetLabelObject(oc)
				e1:SetCountLimit(1)
				e1:SetOperation(s.retop)
				-- 注册回合结束阶段使除外卡片返回的回合效果
				Duel.RegisterEffect(e1,tp)
				local atk=oc:GetAttack()
				-- 询问是否让自身攻击力上升除外怪兽的攻击力数值
				if c:IsRelateToChain() and c:IsFaceup() and atk>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否上升攻击力？"
					-- 可以让这张卡的攻击力上升除外的怪兽的攻击力数值。
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
-- 过滤此前在额外卡组表侧表示存在的卡
function s.retexfilter(c)
	return c:IsPreviousLocation(LOCATION_EXTRA) and c:IsPreviousPosition(POS_FACEUP)
end
-- 将暂时除外的卡返回额外卡组或主卡组
function s.returnremoved(g)
	local pg=g:Filter(s.retexfilter,nil)
	-- 过滤需要洗回额外/主卡组的卡
	local dg=g:Filter(aux.NOT(s.retexfilter),nil)
	if #pg>0 then
		-- 将灵摆卡表侧表示返回额外卡组
		Duel.SendtoExtraP(pg,nil,REASON_EFFECT)
	end
	if #dg>0 then
		-- 将非灵摆卡洗回额外卡组
		Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 结束阶段将暂时除外的1张卡返回额外卡组
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local tc=e:GetLabelObject()
	if tc and tc:GetFlagEffectLabel(id)==fid then
		s.returnremoved(Group.FromCards(tc))
	end
end
-- 效果发动条件：同调召唤的自身从怪兽区被送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果发动目标检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空闲的主要怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：特殊召唤自身，可适用后续除外对方额外卡组2张卡的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 特殊召唤自身并检查是否成功
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取对方额外卡组所有可除外的卡
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)
		-- 检查对方额外卡组是否有至少2张卡并询问是否适用除外效果
		if #g>=2 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否除外额外卡组？"
			-- 中断效果处理
			Duel.BreakEffect()
			-- 确认对方额外卡组
			Duel.ConfirmCards(tp,Duel.GetFieldGroup(tp,0,LOCATION_EXTRA),true)
			-- 提示选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local sg=g:FilterSelect(tp,Card.IsAbleToRemove,2,2,nil)
			if #sg==2 then
				local fid=c:GetFieldID()
				-- 将选中的2张卡直到结束阶段暂时表侧除外
				if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
					-- 获取实际除外的卡片组
					local og=Duel.GetOperatedGroup()
					-- 遍历被除外的卡片
					for oc in aux.Next(og) do
						oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,4))  --"直到结束阶段除外"
					end
					og:KeepAlive()
					-- 把对方的额外卡组确认，那之内的2张直到结束阶段表侧除外。
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					e1:SetCode(EVENT_PHASE+PHASE_END)
					e1:SetReset(RESET_PHASE+PHASE_END)
					e1:SetLabel(fid)
					e1:SetLabelObject(og)
					e1:SetCountLimit(1)
					e1:SetOperation(s.retop2)
					-- 注册回合结束阶段使除外卡片返回的回合效果
					Duel.RegisterEffect(e1,tp)
				end
			end
			-- 洗切对方额外卡组
			Duel.ShuffleExtra(1-tp)
		end
	end
end
-- 过滤带有对应标记编号的卡片
function s.retfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 结束阶段将暂时除外的2张卡返回额外卡组
function s.retop2(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local g=e:GetLabelObject()
	local tg=g:Filter(s.retfilter,nil,fid)
	g:DeleteGroup()
	s.returnremoved(tg)
end
