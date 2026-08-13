--H・E・R・O フラッシュ！
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下选择1个发动。
-- ●这个回合中，自己的「元素英雄」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ●以最多有自己场上的「元素英雄」怪兽数量的对方场上的卡为对象才能发动。那些卡破坏。
-- ●从自己墓地选1只「元素英雄」怪兽加入手卡或特殊召唤。
-- ●这个回合中，「元素英雄」怪兽可以直接攻击。
local s,id,o=GetID()
-- 创建并注册这张卡的发动效果：设定效果描述、分类（破坏/特召/回手/涉及墓地）、类型为魔法卡发动、发动时机为自由时点、取对象标志、同名卡1回合1次限制，并指定发动时的目标选择函数与效果处理函数。
function s.initial_effect(c)
	-- 对应效果原文：‘这个卡名的卡在1回合只能发动1张。①：可以从以下选择1个发动。’
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_SPSUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断怪兽是否为表侧表示且属于「元素英雄」系列，用于统计自己场上「元素英雄」怪兽数量。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008)
end
-- 过滤函数：判断墓地的卡是否为「元素英雄」怪兽，且能够加入手卡或在有可用怪兽区的情况下可以被特殊召唤，用于回收/特召选项。
function s.thfilter(c,e,tp)
	if not (c:IsSetCard(0x3008) and c:IsType(TYPE_MONSTER)) then return false end
	-- 获取自己主要怪兽区的可用空格数，用于判断能否从墓地特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 发动时的目标选择与分支判定：统计可用「元素英雄」数量，计算四个选项是否可选；让玩家选择要发动的分支；根据分支设置相应的效果分类、取对象属性、选择对象并设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 统计自己场上表侧表示的「元素英雄」怪兽数量，该数量作为破坏选项最多能选择对方场上的卡的数量。
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 判断贯通伤害选项是否可选：本回合尚未使用过该选项（通过flag记录），且当前可以进入战斗阶段（确保在主阶段发动）。
	local b1=Duel.GetFlagEffect(tp,id)==0 and Duel.IsAbleToEnterBP()
	-- 判断卡片破坏选项是否可选：自己场上有「元素英雄」怪兽，且对方场上有至少1张能成为对象的卡。
	local b2=ct>0 and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	-- 判断墓地回收选项是否可选：自己墓地存在至少1张满足回手或特召条件的「元素英雄」怪兽。
	local b3=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	-- 判断直接攻击选项是否可选：本回合尚未使用过该选项（通过另一个flag记录），且当前可以进入战斗阶段。
	local b4=Duel.GetFlagEffect(tp,id+o)==0 and Duel.IsAbleToEnterBP()
	if chk==0 then return b1 or b2 or b3 or b4 end
	-- 让玩家从四个可用的选项中选择一个效果分支，返回选项编号并存入效果的Label中。
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"贯通伤害"
			{b2,aux.Stringid(id,2),2},  --"卡片破坏"
			{b3,aux.Stringid(id,3),3},  --"墓地回收"
			{b4,aux.Stringid(id,4),4})  --"直接攻击"
	e:SetLabel(op)
	e:SetCategory(0)
	e:SetProperty(0)
	if op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY)
			e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		end
		-- 在选择破坏对象前，向玩家发出“请选择要破坏的卡”的提示，并缓存选择消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上1到ct张卡（ct为自己场上「元素英雄」怪兽数量）作为破坏对象，并将它们设为连锁对象。
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
		-- 设置操作信息：本次连锁将破坏选中的卡，数量为g的卡数，用于发动后的效果检测（如星尘龙等）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	elseif op==3 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_SPSUMMON+CATEGORY_GRAVE_ACTION)
		end
		-- 获取自己墓地所有满足回收/特召条件的「元素英雄」怪兽，作为回收选项的候选集合。
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 设置操作信息：本次连锁将会有1张墓地的卡离开墓地（回手或特召），用于与墓地相关的效果检测（如王家长眠之谷）。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 过滤函数：判断怪兽是否属于「元素英雄」系列，用于赋予贯穿伤害或直接攻击效果。
function s.atkfilter(e,c)
	return c:IsSetCard(0x3008)
end
-- 效果处理函数：根据发动时选择的分支执行对应效果——1：给己方「元素英雄」怪兽赋予贯穿伤害；2：破坏对象卡；3：从墓地选择1只「元素英雄」怪兽加入手卡或特殊召唤；4：给己方「元素英雄」怪兽赋予直接攻击能力。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- 检查tp方是否已经在本回合使用过贯通选项（flag不存在表示未使用），防止重复赋予。
		if Duel.GetFlagEffect(tp,id)==0 then
			-- 对应效果原文：‘●这个回合中，自己的「元素英雄」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。●以最多有自己场上的「元素英雄」怪兽数量的对方场上的卡为对象才能发动。那些卡破坏。●从自己墓地选1只「元素英雄」怪兽加入手卡或特殊召唤。●这个回合中，「元素英雄」怪兽可以直接攻击。’
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_PIERCE)
			e1:SetTargetRange(LOCATION_MZONE,0)
			e1:SetTarget(s.atkfilter)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将贯穿伤害效果作为场地效果注册到tp方，使tp方场上符合条件的「元素英雄」怪兽获得贯穿伤害。
			Duel.RegisterEffect(e1,tp)
			-- 为tp方注册一个flag，记录本回合已使用过贯通选项，该flag在回合结束时重置。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	elseif e:GetLabel()==2 then
		-- 获取当前连锁处理中记录的对象卡组（即发动时选择的破坏对象）。
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local tg=g:Filter(Card.IsRelateToChain,nil):Filter(Card.IsOnField,nil)
		if tg:GetCount()>0 then
			-- 将仍然存在于场上且与当前连锁相关的对象卡破坏。
			Duel.Destroy(tg,REASON_EFFECT)
		end
	elseif e:GetLabel()==3 then
		-- 在从墓地选择要操作的卡前，向玩家发出“请选择要操作的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从自己墓地选择1张满足回手/特召条件的「元素英雄」怪兽，并过滤掉受王家长眠之谷影响而不能移动墓地的卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 获取自己主要怪兽区的可用空格数，用于判断选择的怪兽能否特殊召唤。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local tc=g:GetFirst()
		if tc then
			local spchk=ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 如果选择的怪兽可以加入手卡，并且（不能特召或玩家在提示中选择回手）时，执行回手操作；否则尝试特殊召唤。
			if tc:IsAbleToHand() and (not spchk or Duel.SelectOption(tp,1190,1152)==0) then
				-- 将选择的「元素英雄」怪兽从墓地加入其持有者的手卡（因为player参数为nil，所以送回持有者手卡）。
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				-- 向对方玩家展示加入手卡的怪兽，以确认卡片信息。
				Duel.ConfirmCards(1-tp,tc)
			elseif spchk then
				-- 将选择的「元素英雄」怪兽以表侧攻击表示特殊召唤到自己场上（不检查召唤条件，不检查苏生限制）。
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif e:GetLabel()==4 then
		-- 检查tp方是否已经在本回合使用过直接攻击选项（flag不存在表示未使用），防止重复赋予。
		if Duel.GetFlagEffect(tp,id+o)==0 then
			-- 对应效果原文：‘●这个回合中，「元素英雄」怪兽可以直接攻击。’
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_DIRECT_ATTACK)
			e2:SetTargetRange(LOCATION_MZONE,0)
			e2:SetTarget(s.atkfilter)
			e2:SetReset(RESET_PHASE+PHASE_END)
			-- 将直接攻击效果作为场地效果注册到tp方，使tp方场上符合条件的「元素英雄」怪兽可以直接攻击。
			Duel.RegisterEffect(e2,tp)
			-- 为tp方注册一个flag，记录本回合已使用过直接攻击选项，该flag在回合结束时重置。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
