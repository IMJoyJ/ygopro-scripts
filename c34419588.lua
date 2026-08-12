--クリベー
-- 效果：
-- 这个卡名在规则上也当作「栗子球」卡使用。
-- ①：把这张卡从手卡丢弃，以自己场上1只「栗子球」怪兽为对象才能发动。那只怪兽的攻击力上升1500。这个效果在对方回合也能发动。
-- ②：把场上的这张卡和自己的手卡·场上的「栗子丸」「栗子团」「栗子圆」「栗子球」各1只解放才能发动。从自己的卡组·墓地选1只「盗贼栗子」加入手卡。那之后，可以从手卡把1只恶魔族怪兽召唤。
function c34419588.initial_effect(c)
	-- 注册该卡名在规则上也当作「栗子球」卡使用
	aux.AddCodeList(c,44632120,71036835,7021574,40640057)
	-- ①：把这张卡从手卡丢弃，以自己场上1只「栗子球」怪兽为对象才能发动。那只怪兽的攻击力上升1500。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34419588,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetCost(c34419588.atkcost)
	e1:SetTarget(c34419588.atktg)
	e1:SetOperation(c34419588.atkop)
	c:RegisterEffect(e1)
	-- ②：把场上的这张卡和自己的手卡·场上的「栗子丸」「栗子团」「栗子圆」「栗子球」各1只解放才能发动。从自己的卡组·墓地选1只「盗贼栗子」加入手卡。那之后，可以从手卡把1只恶魔族怪兽召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34419588,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c34419588.thcost)
	e3:SetTarget(c34419588.thtg)
	e3:SetOperation(c34419588.thop)
	c:RegisterEffect(e3)
end
-- 创建一个用于检查是否满足特定卡名条件的函数数组
c34419588.spchecks=aux.CreateChecks(Card.IsCode,{44632120,71036835,7021574,40640057})
-- 将此卡从手卡丢弃作为效果的发动费用
function c34419588.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡送去墓地作为效果的发动费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 定义用于筛选「栗子球」怪兽的过滤函数
function c34419588.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa4)
end
-- 选择目标怪兽作为效果的对象
function c34419588.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c34419588.atkfilter(chkc) end
	-- 检查是否存在满足条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c34419588.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c34419588.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 使目标怪兽攻击力上升1500
function c34419588.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽攻击力上升1500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 定义用于筛选「栗子丸」「栗子团」「栗子圆」「栗子球」的过滤函数
function c34419588.rlfilter(c,tp)
	return c:IsCode(44632120,71036835,7021574,40640057) and (c:IsControler(tp) or c:IsFaceup())
end
-- 定义用于检查是否可以解放指定卡片组的函数
function c34419588.rlcheck(sg,c,tp)
	local g=sg:Clone()
	g:AddCard(c)
	-- 检查在解放指定卡片后是否还有足够的怪兽区域
	return Duel.GetMZoneCount(tp,g)>0 and Duel.CheckReleaseGroupEx(tp,aux.IsInGroup,#g,REASON_COST,true,nil,g)
end
-- 准备发动效果②，选择解放的卡片并进行解放操作
function c34419588.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取玩家可解放的「栗子丸」「栗子团」「栗子圆」「栗子球」卡片组
	local g=Duel.GetReleaseGroup(tp,true):Filter(c34419588.rlfilter,c,tp)
	if chk==0 then return c:IsReleasable() and g:CheckSubGroupEach(c34419588.spchecks,c34419588.rlcheck,c,tp) end
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g:SelectSubGroupEach(tp,c34419588.spchecks,false,c34419588.rlcheck,c,tp)
	-- 使用额外的解放次数
	aux.UseExtraReleaseCount(rg,tp)
	rg:AddCard(c)
	-- 将选定的卡片解放作为效果的发动费用
	Duel.Release(rg,REASON_COST)
end
-- 定义用于筛选「盗贼栗子」的过滤函数
function c34419588.thfilter(c)
	return c:IsCode(16404809) and c:IsAbleToHand()
end
-- 设置效果②的发动条件
function c34419588.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的「盗贼栗子」
	if chk==0 then return Duel.IsExistingMatchingCard(c34419588.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果②的处理信息：将1张「盗贼栗子」加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	-- 设置效果②的处理信息：从手卡召唤1只恶魔族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义用于筛选可召唤的恶魔族怪兽的过滤函数
function c34419588.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsRace(RACE_FIEND)
end
-- 发动效果②，检索「盗贼栗子」并可选择召唤恶魔族怪兽
function c34419588.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的「盗贼栗子」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「盗贼栗子」加入手牌
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c34419588.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	-- 将「盗贼栗子」加入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 确认对方看到加入手牌的「盗贼栗子」
		Duel.ConfirmCards(1-tp,g)
		-- 检查手卡中是否存在可召唤的恶魔族怪兽
		if Duel.IsExistingMatchingCard(c34419588.sumfilter,tp,LOCATION_HAND,0,1,nil)
			-- 询问玩家是否要召唤恶魔族怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(34419588,2)) then  --"是否把恶魔族怪兽召唤？"
			-- 中断当前效果，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要召唤的恶魔族怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			-- 选择满足条件的恶魔族怪兽进行召唤
			local sg=Duel.SelectMatchingCard(tp,c34419588.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
			if sg:GetCount()>0 then
				local tc=sg:GetFirst()
				-- 将选定的恶魔族怪兽从手卡召唤
				Duel.Summon(tp,tc,true,nil)
			end
		end
	end
end
