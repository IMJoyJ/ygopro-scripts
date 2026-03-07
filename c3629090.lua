--サイバー・エンジェル－韋駄天－
-- 效果：
-- 「机械天使的仪式」降临。
-- ①：这张卡仪式召唤成功的场合才能发动。从自己的卡组·墓地选1张仪式魔法卡加入手卡。
-- ②：这张卡被解放的场合才能发动。自己场上的全部仪式怪兽的攻击力·守备力上升1000。
function c3629090.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤成功的场合才能发动。从自己的卡组·墓地选1张仪式魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3629090,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c3629090.thcon)
	e1:SetTarget(c3629090.thtg)
	e1:SetOperation(c3629090.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被解放的场合才能发动。自己场上的全部仪式怪兽的攻击力·守备力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3629090,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetTarget(c3629090.adtg)
	e2:SetOperation(c3629090.adop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：这张卡是仪式召唤成功时才能发动
function c3629090.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤函数：检索满足条件的仪式魔法卡（类型为0x82且能加入手牌）
function c3629090.thfilter(c)
	return c:GetType()==0x82 and c:IsAbleToHand()
end
-- 效果处理准备：检查场上是否存在满足条件的仪式魔法卡并设置操作信息
function c3629090.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：检查场上是否存在满足条件的仪式魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c3629090.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：将要加入手牌的卡设置为操作对象
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：选择并把满足条件的仪式魔法卡加入手牌并确认
function c3629090.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡：从卡组和墓地选择一张仪式魔法卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c3629090.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡加入手牌：把选中的卡以效果原因加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认卡牌：向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：检索满足条件的仪式怪兽（正面表示且类型包含0x81）
function c3629090.adfilter(c)
	return c:IsFaceup() and bit.band(c:GetType(),0x81)==0x81
end
-- 效果处理准备：检查场上是否存在满足条件的仪式怪兽并设置操作信息
function c3629090.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：检查场上是否存在满足条件的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c3629090.adfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：给场上所有满足条件的仪式怪兽的攻击力和守备力各上升1000
function c3629090.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组：获取场上所有满足条件的仪式怪兽
	local g=Duel.GetMatchingGroup(c3629090.adfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 给目标怪兽增加攻击力：给目标怪兽增加1000点攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
