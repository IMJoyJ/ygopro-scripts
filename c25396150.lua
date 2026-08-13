--アマゾネス拝謁の間
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从自己墓地的怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中选1只「亚马逊」怪兽加入手卡或选1只「亚马逊」灵摆怪兽在自己的灵摆区域放置。
-- ②：自己场上有「亚马逊」怪兽卡存在，对方场上有怪兽特殊召唤的场合，以那1只对方怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力的数值。
function c25396150.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从自己墓地的怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中选1只「亚马逊」怪兽加入手卡或选1只「亚马逊」灵摆怪兽在自己的灵摆区域放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c25396150.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上有「亚马逊」怪兽卡存在，对方场上有怪兽特殊召唤的场合，以那1只对方怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25396150,3))  --"回复基本分"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,25396150)
	e2:SetCondition(c25396150.rccon)
	e2:SetTarget(c25396150.rctg)
	e2:SetOperation(c25396150.rcop)
	c:RegisterEffect(e2)
end
-- ①效果的选卡过滤条件：判断卡是否来自自己墓地或自己额外卡组表侧表示的灵摆怪兽，且为「亚马逊」怪兽；并满足可加入手卡，或为灵摆怪兽且自己灵摆区域有空格。
function c25396150.filter(c,tp,pcon)
	return ((c:IsFaceup() and c:IsLocation(LOCATION_EXTRA) and c:IsType(TYPE_PENDULUM)) or c:IsLocation(LOCATION_GRAVE))
		and c:IsSetCard(0x4) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsType(TYPE_PENDULUM) and pcon)
end
-- ①效果的发动处理函数：先检查灵摆区域是否有空格，再获取符合条件的候选卡组；若存在候选且玩家确认，则从中选择1张，根据选项将其加入手卡或放置到灵摆区域。
function c25396150.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域（左右两个灵摆格）是否存在至少1个空格，用于判断能否将灵摆怪兽放置到灵摆区域。
	local pcon=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	-- 从自己墓地的怪兽和额外卡组表侧表示的灵摆怪兽中，筛选出满足条件且不受王家长眠之谷影响的「亚马逊」怪兽，得到候选卡组。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c25396150.filter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil,tp,pcon)
	-- 当候选卡组非空且玩家选择“是”时，进入①效果后续的选卡处理。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(25396150,0)) then  --"是否从墓地或额外卡组选卡？"
		-- 显示“请选择要操作的卡”的选卡提示，以便玩家选择卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if sc then
			local b1=sc:IsAbleToHand()
			local b2=sc:IsType(TYPE_PENDULUM) and pcon
			local s=0
			if b1 and not b2 then
				-- 当所选卡只能加入手卡时，显示唯一选项“加入手卡”，并将返回的0存入s（表示执行加入手卡分支）。
				s=Duel.SelectOption(tp,aux.Stringid(25396150,1))  --"加入手卡"
			end
			if not b1 and b2 then
				-- 当所选卡只能放置到灵摆区域时，显示唯一选项“在灵摆区域放置”；SelectOption返回0，加1后得1存入s（表示执行放置灵摆区域分支）。
				s=Duel.SelectOption(tp,aux.Stringid(25396150,2))+1  --"在灵摆区域放置"
			end
			if b1 and b2 then
				-- 当所选卡既可加入手卡也可放置灵摆区域时，显示两个选项，将选中序号存入s（0=加入手卡，1=放置灵摆区域）。
				s=Duel.SelectOption(tp,aux.Stringid(25396150,1),aux.Stringid(25396150,2))  --"加入手卡/在灵摆区域放置"
			end
			if s==0 then
				-- 若s=0，将所选卡加入其持有者的手卡，原因记为效果。
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
			end
			if s==1 then
				-- 若s=1，将所选卡以表侧表示放置到自己的灵摆区域，并立即适用其效果。
				Duel.MoveToField(sc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
		end
	end
end
-- ②效果的发动条件过滤：检查卡片是否为表侧表示且原类型为怪兽的「亚马逊」卡，用于确认自己场上存在「亚马逊」怪兽卡。
function c25396150.rcfilter(c)
	return c:IsSetCard(0x4) and c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- ②效果的发动条件函数：当自己场上存在表侧表示的「亚马逊」怪兽卡时，条件成立，允许发动。
function c25396150.rccon(e,tp,eg,ep,ev,re,r,rp)
	-- 执行检索：在自己场上是否存在至少1张满足rcfilter的卡（表侧表示且原类型为怪兽的「亚马逊」卡）。
	return Duel.IsExistingMatchingCard(c25396150.rcfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ②效果取对象的过滤条件：对象必须是能成为当前效果对象的对方场上的怪兽。
function c25396150.tgfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsControler(1-tp)
end
-- ②效果的目标选择处理：若指定候选对象chkc，检查其是否在特殊召唤成功的怪兽中且合法；若在发动确认阶段，检查是否存在合法对象；然后让玩家从特殊召唤成功的对方怪兽中选择1只，设置为目标卡并声明操作信息。
function c25396150.rctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c25396150.tgfilter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c25396150.tgfilter,1,nil,e,tp) end
	-- 显示“请选择效果的对象”的选卡提示，用于对象选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local tc=eg:FilterSelect(tp,c25396150.tgfilter,1,1,nil,e,tp):GetFirst()
	-- 将选中的对方怪兽登记为当前连锁的效果对象。
	Duel.SetTargetCard(tc)
	-- 设置当前连锁的操作信息：声明对象tc（数量1）作为处理对象，分类标记为CATEGORY_CONTROL。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
-- ②效果处理函数：取得效果对象，若对象仍与效果相关且表侧表示，则使自己回复该怪兽当前攻击力数值的基本分。
function c25396150.rcop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的处理对象卡（即之前选择的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使自己回复对象怪兽当前攻击力数值的基本分，回复原因标记为效果。
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	end
end
