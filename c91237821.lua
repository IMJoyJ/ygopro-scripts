--道化の一座 デビルズ
-- 效果：
-- 3星怪兽×2
-- ①：自己场上的上级召唤的怪兽的攻击力上升1000。
-- ②：这张卡被解放的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●双方的场上·墓地的超量怪兽全部回到额外卡组。
-- ●从卡组把1张「道化一座」魔法卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片初始效果，包括XYZ召唤手续、①效果（上级召唤怪兽攻击力上升）和②效果（被解放时选择发动的效果）。
function s.initial_effect(c)
	-- 设置XYZ召唤手续：3星怪兽×2。
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：自己场上的上级召唤的怪兽的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤受影响的怪兽，限定为通过上级召唤出场的怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSummonType,SUMMON_TYPE_ADVANCE))
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	-- ②：这张卡被解放的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"选择效果"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 过滤场上或墓地的超量怪兽，且该怪兽可以回到卡组（额外卡组）。
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_XYZ) and c:IsAbleToDeck()
end
-- 过滤卡组中可以盖放的「道化一座」魔法卡。
function s.setfilter(c)
	return c:IsSetCard(0x1dc) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- ②效果的发动准备（Target函数），检查两个分支效果的可选性，让玩家选择其中一个，并根据选择注册对应的同名卡一回合一次限制（FlagEffect）和设置操作信息（OperationInfo）。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上或墓地是否存在至少1只可以回到额外卡组的超量怪兽。
	local b1=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,nil)
		-- 检查本回合是否尚未选择过第一个分支效果（回收超量怪兽）。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查自己卡组是否存在可以盖放的「道化一座」魔法卡。
	local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查本回合是否尚未选择过第二个分支效果（盖放「道化一座」魔法卡）。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从可用的分支效果中选择一个。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"回收超量怪兽"
			{b2,aux.Stringid(id,2),2})  --"盖放魔法卡"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TODECK)
			-- 注册玩家标识，标记本回合已选择过第一个分支效果。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 获取当前双方场上和墓地所有满足条件的超量怪兽。
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,nil)
		-- 设置连锁信息，表示该效果将把双方场上·墓地的超量怪兽全部送回卡组（额外卡组）。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_GRAVE+LOCATION_MZONE)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SSET)
			-- 注册玩家标识，标记本回合已选择过第二个分支效果。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- ②效果的效果处理（Operation函数），根据玩家在发动时选择的分支，执行对应的回收超量怪兽或盖放魔法卡的操作。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- 获取当前双方场上和墓地所有满足条件的超量怪兽。
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,nil)
		-- 检查是否受「王家之谷-Necrovalley」影响，若受影响则使涉及墓地的效果无效。
		if aux.NecroValleyNegateCheck(g) then return end
		-- 将获取到的超量怪兽全部送回持有者的卡组（额外卡组）。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要盖放的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组中选择1张满足条件的「道化一座」魔法卡。
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的魔法卡在自己场上盖放。
			Duel.SSet(tp,tc)
		end
	end
end
