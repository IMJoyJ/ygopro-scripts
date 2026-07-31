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
	-- ①：每次自己场上表侧表示的「命运英雄」怪兽被破坏，给这张卡放置被破坏数量的D指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetOperation(c74329404.ctop)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段怪兽召唤·特殊召唤成功时，把放置有2个以上D指示物的这张卡送去墓地才能发动。选那1只召唤·特殊召唤的怪兽的最多2张同名卡从自己的卡组·墓地加入手牌。
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
-- 计数器过滤条件：原本控制者为自己、从怪兽区域离开且破坏前为表侧表示的「命运英雄」怪兽
function c74329404.ctfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0xc008)
end
-- 放置指示物处理：统计被破坏的「命运英雄」怪兽数量并放置等量D指示物
function c74329404.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c74329404.ctfilter,nil,tp)
	if ct>0 then
		e:GetHandler():AddCounter(0x1c,ct)
	end
end
-- ②效果发动条件：必须在自己的主要阶段
function c74329404.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断是否为自己的回合且处于主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- ②效果发动Cost：把放置有2个以上D指示物的此卡送去墓地
function c74329404.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() and e:GetHandler():GetCounter(0x1c)>=2 end
	-- 将此卡作为Cost送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 检索目标检测过滤：召唤·特召成功的怪兽中，卡组/墓地存在其同名卡且可加入手牌的怪兽
function c74329404.filter1(c,e,tp)
	return c:IsFaceup() and (not e or c:IsRelateToEffect(e))
		-- 检查卡组或墓地中是否存在同名卡且能加入手牌
		and Duel.IsExistingMatchingCard(c74329404.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- 卡组/墓地检索过滤条件：同名卡且可加入手牌
function c74329404.filter2(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- ②效果发动准备：设置检索同名卡的操作信息
function c74329404.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c74329404.filter1,1,nil,nil,tp) end
	-- 将本次召唤·特殊召唤的怪兽设为目标
	Duel.SetTargetCard(eg)
	-- 设置连锁操作信息：从卡组/墓地把卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果处理：从卡组·墓地把召唤·特召怪兽的最多2张同名卡加入手牌
function c74329404.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c74329404.filter1,nil,e,tp)
	if g:GetCount()==0 then return end
	if g:GetCount()>1 then
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=g:Select(tp,1,1,nil)
	end
	local tc=g:GetFirst()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组/墓地选择1~2张与选中怪兽同名的卡（受王谷影响）
	local ag=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c74329404.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,2,nil,tc:GetCode())
	-- 将选中的卡加入手牌
	Duel.SendtoHand(ag,nil,REASON_EFFECT)
	-- 向对方确认加入手牌的卡
	Duel.ConfirmCards(1-tp,ag)
end
