--立炎星－トウケイ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡用「炎星」怪兽的效果特殊召唤成功时才能发动。从卡组把1只「炎星」怪兽加入手卡。
-- ②：1回合1次，把自己场上1张表侧表示的「炎舞」魔法·陷阱卡送去墓地才能发动。从卡组选1张「炎舞」魔法·陷阱卡在自己场上盖放。
function c30929786.initial_effect(c)
	-- ①：这张卡用「炎星」怪兽的效果特殊召唤成功时才能发动。从卡组把1只「炎星」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30929786,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,30929786)
	e1:SetCondition(c30929786.thcon)
	e1:SetTarget(c30929786.thtg)
	e1:SetOperation(c30929786.thop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把自己场上1张表侧表示的「炎舞」魔法·陷阱卡送去墓地才能发动。从卡组选1张「炎舞」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30929786,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c30929786.setcost)
	e2:SetTarget(c30929786.settg)
	e2:SetOperation(c30929786.setop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否由「炎星」怪兽的效果特殊召唤而来
function c30929786.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x79)
end
-- 检索满足条件的「炎星」怪兽
function c30929786.thfilter(c)
	return c:IsSetCard(0x79) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果处理时要检索的卡组中的「炎星」怪兽
function c30929786.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c30929786.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要检索的卡组中的「炎星」怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果
function c30929786.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「炎星」怪兽
	local g=Duel.SelectMatchingCard(tp,c30929786.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「炎星」怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤满足条件的「炎舞」魔法·陷阱卡
function c30929786.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 设置效果处理时的费用
function c30929786.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的魔法·陷阱区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 若卡组存在可盖放的「炎舞」魔法·陷阱卡，则增加可用区域数量
	if Duel.IsExistingMatchingCard(c30929786.filter2,tp,LOCATION_DECK,0,1,nil) then ft=ft+1 end
	-- 判断是否满足支付费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(c30929786.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 若玩家受到效果影响且场上存在可用区域，则满足支付费用条件
		or (Duel.IsPlayerAffectedByEffect(tp,46241344) and ft>0) end
	-- 判断场上是否存在满足条件的「炎舞」魔法·陷阱卡
	if Duel.IsExistingMatchingCard(c30929786.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 若场上存在满足条件的卡且未受效果影响或可用区域不足或玩家选择不支付费用，则执行支付费用
		and (not Duel.IsPlayerAffectedByEffect(tp,46241344) or ft<=0 or not Duel.SelectYesNo(tp,aux.Stringid(46241344,0))) then  --"是否不把卡送去墓地发动？"
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择满足条件的「炎舞」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c30929786.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		-- 将选中的「炎舞」魔法·陷阱卡送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	end
end
-- 过滤满足条件的「炎舞」魔法·陷阱卡
function c30929786.filter(c,chk)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(chk)
end
-- 过滤满足条件的「炎舞」魔法·陷阱卡（仅限场地魔法）
function c30929786.filter2(c)
	return c30929786.filter(c,false) and c:IsType(TYPE_FIELD)
end
-- 设置效果处理时要盖放的卡组中的「炎舞」魔法·陷阱卡
function c30929786.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足盖放条件
	if chk==0 then return Duel.IsExistingMatchingCard(c30929786.filter,tp,LOCATION_DECK,0,1,nil,true) end
end
-- 执行盖放效果
function c30929786.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的「炎舞」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c30929786.filter,tp,LOCATION_DECK,0,1,1,nil,false)
	if g:GetCount()>0 then
		-- 将选中的「炎舞」魔法·陷阱卡盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
