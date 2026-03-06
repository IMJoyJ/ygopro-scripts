--ARG☆S－HomeStadium
-- 效果：
-- ①：1回合1次，支付1000基本分才能发动。自己的墓地·除外状态的1张「阿尔戈☆群星」卡加入手卡。
-- ②：每次从魔法与陷阱区域往自己场上有永续陷阱卡特殊召唤，给与对方500伤害。
-- ③：自己的「阿尔戈☆群星」怪兽除外中的状态，自己的永续陷阱卡在怪兽区域把效果发动的场合，以对方场上1张表侧表示卡为对象才能发动（同一连锁上最多1次）。那张卡的效果直到回合结束时无效。
local s,id,o=GetID()
-- 初始化卡片效果，创建场地卡通用的发动条件、三个效果的触发条件和处理函数
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，支付1000基本分才能发动。自己的墓地·除外状态的1张「阿尔戈☆群星」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：每次从魔法与陷阱区域往自己场上有永续陷阱卡特殊召唤，给与对方500伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.damcon)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	-- ③：自己的「阿尔戈☆群星」怪兽除外中的状态，自己的永续陷阱卡在怪兽区域把效果发动的场合，以对方场上1张表侧表示卡为对象才能发动（同一连锁上最多1次）。那张卡的效果直到回合结束时无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"无效"
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_ACTIVATE_CONDITION)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e4:SetCondition(s.discon)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
-- 支付1000基本分的费用处理
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤满足条件的「阿尔戈☆群星」卡（表侧表示、在墓地或除外区、能加入手牌）
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1c1) and c:IsAbleToHand()
end
-- 设置效果目标，检查是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的「阿尔戈☆群星」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息，指定将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 处理效果发动，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤满足条件的永续陷阱卡（在魔法陷阱区域被特殊召唤）
function s.cfilter(c,tp)
	return c:IsAllTypes(TYPE_TRAP+TYPE_CONTINUOUS) and c:IsPreviousLocation(LOCATION_SZONE) and c:IsControler(tp)
end
-- 判断是否有满足条件的永续陷阱卡被特殊召唤
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 处理伤害效果，给与对方500伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动该效果的卡号
	Duel.Hint(HINT_CARD,0,id)
	-- 给与对方500伤害
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
-- 过滤满足条件的「阿尔戈☆群星」怪兽（表侧表示、在除外区、是怪兽）
function s.cfilter2(c)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1c1)
end
-- 判断是否满足无效效果发动条件
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsAllTypes(TYPE_TRAP+TYPE_CONTINUOUS)	and re:GetActivateLocation()==LOCATION_MZONE
		-- 检查自己场上有除外状态的「阿尔戈☆群星」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_REMOVED,0,1,nil) and rp==tp
end
-- 设置无效效果的目标选择
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 设置目标选择的过滤条件
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 检查是否存在满足条件的目标
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，指定将卡无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 处理无效效果，使目标卡效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使目标卡相关的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标卡效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标卡效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 使目标陷阱怪兽效果无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
