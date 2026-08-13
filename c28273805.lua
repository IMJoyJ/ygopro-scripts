--六武式襲双陣
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从以下效果选1个适用。自己场上有「六武众」怪兽2只以上存在的场合，可以选两方适用。
-- ●从自己的手卡·墓地把1只攻击力2000以下的「六武众」怪兽特殊召唤。
-- ●对方场上1只攻击力2000以下的怪兽变成里侧守备表示。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「六武众」怪兽为对象才能发动。那只怪兽加入手卡。
local s,id,o=GetID()
-- 初始化这张卡的效果：注册①的魔法卡发动效果（EFFECT_TYPE_ACTIVATE，自由时点发动，1回合1次，可进行特殊召唤或变更对方怪兽表示形式）和②的墓地起动效果（除外自身为cost，取对象回收墓地「六武众」怪兽，1回合1次），两个效果共享同一个1回合1次限制。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：从以下效果选1个适用。自己场上有「六武众」怪兽2只以上存在的场合，可以选两方适用。●从自己的手卡·墓地把1只攻击力2000以下的「六武众」怪兽特殊召唤。●对方场上1只攻击力2000以下的怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「六武众」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 设置②效果的发动cost：把墓地中的这张卡除外（aux.bfgcost），对应②效果中的『把墓地的这张卡除外』。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤的过滤条件：从手卡·墓地选择攻击力2000以下、具有0x103d『六武众』字段的怪兽卡，且该怪兽能被当前效果正常特殊召唤（检查召唤条件与苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsAttackBelow(2000) and c:IsSetCard(0x103d) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义变更表示形式的过滤条件：对方场上表侧表示、攻击力2000以下、且可以被变成里侧守备表示的怪兽。
function s.posfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(2000) and c:IsCanTurnSet()
end
-- 定义自己场上表侧表示『六武众』怪兽的过滤条件，用于判断场上是否有2只以上表侧『六武众』怪兽。
function s.bfilter(c)
	return c:IsSetCard(0x103d) and c:IsFaceup()
end
-- ①效果发动合法性判定：只要『自己主要怪兽区有空格且手卡/墓地存在可特殊召唤的「六武众」怪兽』，或『对方场上存在可变成里侧守备表示的怪兽』，即可发动。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 进入chk==0的发动检测分支：先判断自己场上是否有可用的主要怪兽区空格（特殊召唤选项的前提条件）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时判断自己的手卡或墓地是否存在至少1只满足s.spfilter条件的「六武众」怪兽，使特殊召唤选项可用。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
		-- 或者判断对方场上是否存在至少1只满足s.posfilter条件的怪兽；任一组合成立则①效果可发动。
		or Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- ①效果的处理：根据可用的选项（特殊召唤/变更表示形式/若满足条件则两方适用）生成菜单并让玩家选择，再执行对应的处理；选择两方时先执行特殊召唤，再用BreakEffect分开时点，然后变更对方怪兽为里侧守备表示。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算b1的第一部分：自己主要怪兽区是否有空格。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 计算b1的第二部分：手卡·墓地中是否存在不受『王家长眠之谷』影响的、满足s.spfilter的「六武众」怪兽；两部分同时成立则b1为true。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
	-- 计算b2：对方场上是否存在至少1只满足s.posfilter的怪兽。
	local b2=Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(id,0)  --"特殊召唤"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,1)  --"改变表示形式"
		opval[off-1]=2
		off=off+1
	end
	-- 当b1、b2均成立，且自己场上有2只以上表侧表示「六武众」怪兽时，额外提供『两方适用』的选项。
	if b1 and b2 and Duel.IsExistingMatchingCard(s.bfilter,tp,LOCATION_MZONE,0,2,nil) then
		ops[off]=aux.Stringid(id,2)  --"选择2方"
		opval[off-1]=3
		off=off+1
	end
	if off==1 then return end
	-- 弹出选项菜单让玩家决定适用的效果，返回选中选项的序号（0开始）。
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then
		-- 发送选择提示消息，引导玩家选择要特殊召唤的「六武众」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的手卡·墓地中选择1只不受王家长眠之谷影响的、满足s.spfilter的「六武众」怪兽（效果处理时选择，不取对象）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上（检查召唤条件与苏生限制）。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif opval[op]==2 then
		-- 发送选择提示消息，引导玩家选择要变成里侧守备表示的对方表侧怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择对方场上1只满足s.posfilter的怪兽（表侧、攻击力2000以下、可变成里侧守备表示）。
		local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 显示所选怪兽的选中动画，并将其记录为效果对象（广义）。
			Duel.HintSelection(g)
			-- 将选中的对方怪兽变成里侧守备表示。
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	elseif opval[op]==3 then
		-- 发送选择提示消息，引导玩家选择要特殊召唤的「六武众」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的手卡·墓地中选择1只不受王家长眠之谷影响的、满足s.spfilter的「六武众」怪兽（效果处理时选择，不取对象）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
		-- 若成功选择了特殊召唤对象，则将其以表侧攻击表示特殊召唤到自己场上。
		if g:GetCount()>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
		-- 发送选择提示消息，引导玩家选择要变成里侧守备表示的对方表侧怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 再次选择对方场上1只满足条件的怪兽，作为变更表示形式处理的对象。
		local cg=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=cg:GetFirst()
		if tc then
			-- 调用Duel.BreakEffect中断当前效果处理，使后续的变更表示形式与之前的特殊召唤不在同一时点处理（避免时点被错过）。
			Duel.BreakEffect()
			-- 对变量g（在本分支中为刚才特殊召唤的怪兽组）进行选中动画展示。
			Duel.HintSelection(g)
			-- 将选中的对方怪兽变成里侧守备表示。
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
end
-- 定义②效果的目标过滤条件：墓地中卡名含0x103d『六武众』字段的怪兽卡，且能被加入手卡（不受雷王等不能加入手卡效果影响）。
function s.thfilter(c)
	return c:IsSetCard(0x103d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的取对象发动处理：必须取自己墓地1只「六武众」怪兽为对象；同时设置操作信息为回手牌。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- ②效果的发动条件检测：自己墓地存在至少1只满足s.thfilter的「六武众」怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 发送选择提示消息，引导玩家选择要加入手卡的墓地「六武众」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1只「六武众」怪兽作为效果对象（取对象，并与当前连锁建立关联）。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息：本效果将把1张对象卡加入手牌（供其他卡连锁时判断）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理：若对象仍与效果关联且不受王家长眠之谷影响，则将其加入手牌，并向对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的墓地「六武众」怪兽对象。
	local tc=Duel.GetFirstTarget()
	-- 处理前检查：对象仍与效果关联且不受『王家长眠之谷』影响，才执行加入手牌。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽加入其持有者的手卡，原因标记为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的怪兽，确认回收内容。
		Duel.ConfirmCards(1-tp,tc)
	end
end
