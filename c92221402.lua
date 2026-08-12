--カオティック・エレメンツ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的卡组·墓地把1只5星以上而光·暗属性的炎族·水族怪兽加入手卡。那之后，自己墓地有炎族·水族怪兽3只以上存在的场合，可以把场上1张卡破坏。
-- ②：对方场上有光·暗属性的炎族·水族怪兽存在的场合，把墓地的这张卡除外，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：从自己的卡组·墓地把1只5星以上而光·暗属性的炎族·水族怪兽加入手卡。那之后，自己墓地有炎族·水族怪兽3只以上存在的场合，可以把场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：对方场上有光·暗属性的炎族·水族怪兽存在的场合，把墓地的这张卡除外，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"得到控制权"
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.ctcon)
	-- 设置发动代价为把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
end
-- 过滤卡组·墓地中5星以上且光·暗属性的炎族·水族怪兽
function s.thfilter(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_AQUA+RACE_PYRO) and c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 效果①的发动检测与操作信息设置
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己的卡组或墓地是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置将卡组或墓地的卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的处理函数，执行加入手卡及后续的破坏卡片处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组或墓地选择1只满足条件的怪兽（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	-- 若成功将选中的卡加入手卡
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		-- 给对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
		::cancel::
		-- 获取场上除这张卡以外的所有卡
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
		-- 判断场上是否存在可破坏的卡，且自己墓地是否有3只以上的炎族·水族怪兽
		if dg:GetCount()>0 and Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_AQUA+RACE_PYRO)>=3
			-- 询问玩家是否选择发动破坏效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否破坏1张卡？"
			local tg=dg:CancelableSelect(tp,1,1,nil)
			if tg then
				-- 中断当前效果，使后续处理与加入手卡不视为同时进行
				Duel.BreakEffect()
				-- 在场上高亮显示被选择破坏的卡
				Duel.HintSelection(tg)
				-- 以效果破坏选中的卡
				Duel.Destroy(tg,REASON_EFFECT)
			else
				goto cancel
			end
		end
	end
end
-- 过滤场上表侧表示且光·暗属性的炎族·水族怪兽
function s.ctfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA+RACE_PYRO) and c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT)
end
-- 效果②的发动条件：对方场上存在光·暗属性的炎族·水族怪兽
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测对方场上是否存在光·暗属性的炎族·水族怪兽
	return Duel.IsExistingMatchingCard(s.ctfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 效果②的发动检测与目标选择
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 检测对方场上是否存在可以改变控制权的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只可以改变控制权的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置改变控制权的操作信息
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果②的处理函数，执行控制权转移
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 直到结束阶段得到该怪兽的控制权
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
