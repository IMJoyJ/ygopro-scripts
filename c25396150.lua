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
	-- ②：自己场上有「亚马逊」怪兽卡存在，对方场上有怪兽特殊召唤的场合，以那1只对方怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力的数值。
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
-- 过滤函数，用于筛选满足条件的「亚马逊」怪兽，包括墓地和额外卡组中的灵摆怪兽或普通怪兽。
function c25396150.filter(c,tp,pcon)
	return ((c:IsFaceup() and c:IsLocation(LOCATION_EXTRA) and c:IsType(TYPE_PENDULUM)) or c:IsLocation(LOCATION_GRAVE))
		and c:IsSetCard(0x4) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsType(TYPE_PENDULUM) and pcon)
end
-- 处理①效果的发动，从满足条件的卡中选择一张进行操作，可以选择加入手卡或放置在灵摆区域。
function c25396150.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有灵摆区域可用，用于判断是否可以将灵摆怪兽放置在灵摆区域。
	local pcon=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	-- 获取满足过滤条件的「亚马逊」怪兽组，包括墓地和额外卡组中的灵摆怪兽或普通怪兽。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c25396150.filter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil,tp,pcon)
	-- 判断是否有满足条件的卡，并询问玩家是否发动①效果。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(25396150,0)) then  --"是否从墓地或额外卡组选卡？"
		-- 提示玩家选择要操作的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if sc then
			local b1=sc:IsAbleToHand()
			local b2=sc:IsType(TYPE_PENDULUM) and pcon
			local s=0
			if b1 and not b2 then
				-- 当只能加入手卡时，选择加入手卡选项。
				s=Duel.SelectOption(tp,aux.Stringid(25396150,1))  --"加入手卡"
			end
			if not b1 and b2 then
				-- 当只能放置在灵摆区域时，选择放置选项。
				s=Duel.SelectOption(tp,aux.Stringid(25396150,2))+1  --"在灵摆区域放置"
			end
			if b1 and b2 then
				-- 当两种操作都可选时，选择加入手卡或放置选项。
				s=Duel.SelectOption(tp,aux.Stringid(25396150,1),aux.Stringid(25396150,2))  --"加入手卡/在灵摆区域放置"
			end
			if s==0 then
				-- 将选中的卡加入手卡。
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
			end
			if s==1 then
				-- 将选中的卡移动到玩家的灵摆区域。
				Duel.MoveToField(sc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
		end
	end
end
-- 过滤函数，用于筛选玩家场上的「亚马逊」怪兽。
function c25396150.rcfilter(c)
	return c:IsSetCard(0x4) and c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 判断玩家场上是否存在「亚马逊」怪兽，用于触发②效果的条件。
function c25396150.rccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否存在至少1只「亚马逊」怪兽。
	return Duel.IsExistingMatchingCard(c25396150.rcfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤函数，用于筛选对方特殊召唤的怪兽作为效果对象。
function c25396150.tgfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsControler(1-tp)
end
-- 设置②效果的目标，选择对方特殊召唤的怪兽作为对象。
function c25396150.rctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c25396150.tgfilter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c25396150.tgfilter,1,nil,e,tp) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local tc=eg:FilterSelect(tp,c25396150.tgfilter,1,1,nil,e,tp):GetFirst()
	-- 设置当前连锁的效果对象为选中的怪兽。
	Duel.SetTargetCard(tc)
	-- 设置操作信息，表示将要控制对方的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
-- 处理②效果的发动，回复玩家基本分。
function c25396150.rcop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使玩家回复对方怪兽攻击力数值的基本分。
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	end
end
