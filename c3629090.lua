--サイバー・エンジェル－韋駄天－
-- 效果：
-- 「机械天使的仪式」降临。
-- ①：这张卡仪式召唤成功的场合才能发动。从自己的卡组·墓地选1张仪式魔法卡加入手卡。
-- ②：这张卡被解放的场合才能发动。自己场上的全部仪式怪兽的攻击力·守备力上升1000。
function c3629090.initial_effect(c)
	-- 将卡片「机械天使的仪式」（39996157）加入到此卡的关联卡片代码列表中
	aux.AddCodeList(c,39996157)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤成功的场合才能发动。从自己的卡组·墓地选1张仪式魔法卡加入手卡
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
	-- ②：这张卡被解放的场合才能发动。自己场上的全部仪式怪兽的攻击力·守备力上升1000
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
-- 判断此卡是否是通过仪式召唤特殊召唤成功，以确定是否满足效果①的发动条件
function c3629090.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤卡组·墓地中可以加入手牌的仪式魔法卡
function c3629090.thfilter(c)
	return c:GetType()==0x82 and c:IsAbleToHand()
end
-- 定义效果①的对象确认和可行性检查逻辑，以及设置检索与回收操作信息
function c3629090.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组或墓地中是否存在至少1张满足条件的仪式魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c3629090.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 向系统声明此效果的操作信息为“从卡组或墓地将1张卡加入手卡”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 定义效果①的具体处理逻辑：从卡组或墓地选择1张仪式魔法卡加入手卡
function c3629090.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张满足条件的仪式魔法卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c3629090.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的仪式魔法卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示选中的仪式魔法卡以确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤自己场上表侧表示的仪式怪兽卡
function c3629090.adfilter(c)
	return c:IsFaceup() and bit.band(c:GetType(),0x81)==0x81
end
-- 定义效果②的可行性检查逻辑：确认自己场上是否存在表侧表示的仪式怪兽
function c3629090.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否存在至少1只表侧表示的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c3629090.adfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 定义效果②的具体处理逻辑：使自己场上的全部仪式怪兽的攻击力·守备力上升1000
function c3629090.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上全部表侧表示的仪式怪兽
	local g=Duel.GetMatchingGroup(c3629090.adfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部仪式怪兽的攻击力上升1000
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
