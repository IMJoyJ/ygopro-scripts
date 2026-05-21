--第19層『襲来干渉！漆黒の超量士！！』
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●以场上1只攻击表示怪兽为对象才能发动。那只怪兽变成守备表示。
-- ●自己场上有「超级量子」怪兽存在的场合才能发动。原本属性相同的怪兽不在自己场上存在的1只「超级量子」怪兽从卡组守备表示特殊召唤。
-- ●从卡组把1张「超级量子」陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
local s,id,o=GetID()
-- 注册卡片发动时的效果，包含改变表示形式、特殊召唤和盖放陷阱三个可选效果。
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上可以改变表示形式的攻击表示怪兽。
function s.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- 过滤自己场上表侧表示的「超级量子」怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xdc)
end
-- 过滤自己场上原本属性与指定属性相同的表侧表示怪兽。
function s.attfilter(c,att)
	return c:IsFaceup() and c:GetOriginalAttribute()&att~=0
end
-- 过滤卡组中可以守备表示特殊召唤，且其原本属性在自己场上不存在的「超级量子」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xdc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查自己场上不存在原本属性相同的怪兽。
		and not Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_MZONE,0,1,nil,c:GetOriginalAttribute())
end
-- 过滤卡组中可以盖放的「超级量子」陷阱卡。
function s.setfilter(c)
	return c:IsSetCard(0xdc) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果发动时的目标选择与合法性检测，处理三个分支效果的选择、一回合一次限制的标记以及对应的取对象或设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==1 and chkc:IsType(TYPE_MONSTER) and s.posfilter(chkc) end
	-- 获取自己魔陷区的可用空格数。
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
	-- 检查场上是否存在可以改变表示形式的攻击表示怪兽（分支效果1的可行性）。
	local b1=Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查本回合是否尚未选择过分支效果1。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查自己场上是否有可用的怪兽区域空格（分支效果2的可行性）。
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足特殊召唤条件的「超级量子」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and (not e:IsCostChecked()
			-- 检查本回合是否尚未选择过分支效果2，且自己场上存在「超级量子」怪兽。
			or Duel.GetFlagEffect(tp,id+o)==0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil))
	-- 检查自己魔陷区是否有空格且卡组中存在可盖放的「超级量子」陷阱卡（分支效果3的可行性）。
	local b3=ct>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查本回合是否尚未选择过分支效果3。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o*2)==0)
	if chk==0 then return b1 or b2 or b3 end
	local op=0
	if b1 or b2 or b3 then
		-- 让玩家从满足发动条件的可选效果中选择1个。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"改变表示形式"
			{b2,aux.Stringid(id,2),2},  --"特殊召唤"
			{b3,aux.Stringid(id,3),3})  --"盖放陷阱"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			-- 为玩家注册全局标识，标记本回合已选择过分支效果1。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
			e:SetCategory(CATEGORY_POSITION)
		end
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择要改变表示形式的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 选择场上1只攻击表示怪兽作为效果对象。
		Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	elseif op==2 then
		if e:IsCostChecked() then
			-- 为玩家注册全局标识，标记本回合已选择过分支效果2。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		e:SetProperty(0)
		-- 设置特殊召唤的操作信息，准备从卡组特殊召唤1只怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	elseif op==3 then
		if e:IsCostChecked() then
			-- 为玩家注册全局标识，标记本回合已选择过分支效果3。
			Duel.RegisterFlagEffect(tp,id+o*2,RESET_PHASE+PHASE_END,0,1)
			e:SetCategory(CATEGORY_SSET)
		end
		e:SetProperty(0)
	end
end
-- 效果处理的执行函数，根据玩家选择的分支效果（1、2或3）分别执行对应的处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取作为效果对象的怪兽。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and tc:IsAttackPos() then
			-- 将目标怪兽变成表侧守备表示。
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		end
	elseif e:GetLabel()==2 then
		-- 效果处理时，若自己场上已无可用怪兽区域则不处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的「超级量子」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧守备表示特殊召唤。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	elseif e:GetLabel()==3 then
		-- 提示玩家选择要盖放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组选择1张「超级量子」陷阱卡。
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		-- 若成功选择卡片，则将其在自己场上盖放。
		if tc and Duel.SSet(tp,tc)~=0 then
			-- 这个效果盖放的卡在盖放的回合也能发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,4))  --"适用「第19层『袭来干涉！漆黑的超级量子战士！！』」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
