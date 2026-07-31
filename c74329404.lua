--D－フォーメーション
-- 效果：
-- 每次自己场上表侧表示存在的名字带有「命运英雄」的怪兽被破坏，每有1只给这张卡放置1个D指示物。自己的主要阶段时有怪兽的召唤·特殊召唤成功时，可以把D指示物有2个以上放置的这张卡送去墓地，和召唤·特殊召唤的怪兽同名卡最多2张从自己的卡组·墓地加入手卡。
function c74329404.initial_effect(c)
	c:EnableCounterPermit(0x1c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次自己场上表侧表示存在的名字带有「命运英雄」的怪兽被破坏，每有1只给这张卡放置1个D指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetOperation(c74329404.ctop)
	c:RegisterEffect(e2)
	-- 自己的主要阶段时有怪兽的召唤·特殊召唤成功时，可以把D指示物有2个以上放置的这张卡送去墓地，和召唤·特殊召唤的怪兽同名卡最多2张从自己的卡组·墓地加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(74329404,0))  --"检索"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c74329404.thcon)
	e3:SetCost(c74329404.thcost)
	e3:SetTarget(c74329404.thtg)
	e3:SetOperation(c74329404.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
c74329404.mentioned_counter={
	[0x1c]=true,
}
-- 放置指示物过滤条件：原本由自己控制、原本在怪兽区域表侧表示且带有「命运英雄」字段的被破坏怪兽
function c74329404.ctfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0xc008)
end
-- 放置指示物处理：统计被破坏的「命运英雄」怪兽数量，给此卡放置对应数量的D指示物
function c74329404.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c74329404.ctfilter,nil,tp)
	if ct>0 then
		e:GetHandler():AddCounter(0x1c,ct)
	end
end
-- 检索效果发动条件：处于己方回合的主要阶段
function c74329404.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合阶段
	local ph=Duel.GetCurrentPhase()
	-- 确认当前是否为己方回合的主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 检索效果Cost：检查此卡放置有2个以上D指示物且能送去墓地，并将此卡送去墓地
function c74329404.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() and e:GetHandler():GetCounter(0x1c)>=2 end
	-- 将自身送去墓地作为发动Cost
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 召·特召怪兽过滤条件：表侧表示存在且卡组/墓地存在同名卡可加入手牌
function c74329404.filter1(c,e,tp)
	return c:IsFaceup() and (not e or c:IsRelateToEffect(e))
		-- 检查卡组或墓地是否存在同名卡可加入手牌
		and Duel.IsExistingMatchingCard(c74329404.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- 检索过滤条件：卡号与召·特召怪兽一致且可加入手牌
function c74329404.filter2(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- 检索效果发动准备：检查并锁定召·特召成功的目标怪兽，设置检索操作信息
function c74329404.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c74329404.filter1,1,nil,nil,tp) end
	-- 将召·特召成功的怪兽设置为连锁影响对象
	Duel.SetTargetCard(eg)
	-- 设置连锁操作信息：从卡组/墓地将最多2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 检索效果处理：从卡组/墓地选择最多2张与召·特召怪兽同名的卡加入手牌并展示
function c74329404.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c74329404.filter1,nil,e,tp)
	if g:GetCount()==0 then return end
	if g:GetCount()>1 then
		-- 存在多只召·特召怪兽时，提示玩家选择其中1只作为基准
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=g:Select(tp,1,1,nil)
	end
	local tc=g:GetFirst()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组/墓地选择1~2张与基准怪兽同名且不受王谷影响的卡
	local ag=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c74329404.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,2,nil,tc:GetCode())
	-- 将选中的同名卡加入手牌
	Duel.SendtoHand(ag,nil,REASON_EFFECT)
	-- 向对方玩家确认加入手牌的卡
	Duel.ConfirmCards(1-tp,ag)
end
