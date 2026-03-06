--神碑の牙ゲーリ
-- 效果：
-- 「神碑」怪兽×2
-- ①：这张卡从额外卡组的特殊召唤成功的场合，以速攻魔法卡以外的自己墓地1张「神碑」魔法卡为对象才能发动。那张卡加入手卡。
-- ②：场上的这张卡不会被效果破坏。
-- ③：这张卡被战斗破坏时，以场上1张卡为对象才能发动。那张卡破坏。
function c28373620.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用2个满足「神碑」融合条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x17f),2,true)
	-- ①：这张卡从额外卡组的特殊召唤成功的场合，以速攻魔法卡以外的自己墓地1张「神碑」魔法卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28373620,0))  --"墓地回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c28373620.thcon)
	e1:SetTarget(c28373620.thtg)
	e1:SetOperation(c28373620.thop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗破坏时，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28373620,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetTarget(c28373620.dstg)
	e3:SetOperation(c28373620.dsop)
	c:RegisterEffect(e3)
end
-- 效果发动条件：确认此卡是从额外卡组特殊召唤成功
function c28373620.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- 检索过滤器：满足魔法卡类型、神碑系列、可加入手牌、非速攻魔法卡的条件
function c28373620.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x17f) and c:IsAbleToHand() and not c:IsType(TYPE_QUICKPLAY)
end
-- 效果处理：选择满足条件的墓地魔法卡作为对象，设置操作信息为回手牌
function c28373620.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28373620.thfilter(chkc) end
	-- 判断是否满足选择目标的条件：确认场上存在满足条件的墓地魔法卡
	if chk==0 then return Duel.IsExistingTarget(c28373620.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择目标：显示“请选择要加入手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地魔法卡作为对象
	local g=Duel.SelectTarget(tp,c28373620.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选择的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将选择的卡加入手牌
function c28373620.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌，原因来自效果
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果处理：选择场上任意一张卡作为对象，设置操作信息为破坏
function c28373620.dstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 判断是否满足选择目标的条件：确认场上存在任意一张卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择目标：显示“请选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上任意一张卡作为对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将选择的卡破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏选择的卡
function c28373620.dsop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
