--マジシャン・オブ・ブラックカオス・MAX
-- 效果：
-- 「混沌形态」降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，把自己场上1只怪兽解放才能发动。这个回合，对方不能把怪兽的效果发动。
-- ②：这张卡战斗破坏对方怪兽时，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。
function c79613121.initial_effect(c)
	aux.AddCodeList(c,21082832)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合，把自己场上1只怪兽解放才能发动。这个回合，对方不能把怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79613121,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,79613121)
	e1:SetCost(c79613121.cost)
	e1:SetOperation(c79613121.sumsuc)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽时，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79613121,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,79613122)
	-- 设置发动条件为自身战斗破坏对方怪兽并送去墓地时
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c79613121.thtg)
	e2:SetOperation(c79613121.thop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动代价（Cost）处理函数
function c79613121.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择自己场上1只怪兽
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 将选择的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- ①号效果的效果处理函数
function c79613121.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方不能把怪兽的效果发动。/以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(c79613121.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册该限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动的卡片类型为怪兽
function c79613121.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 过滤自己墓地可加入手牌的魔法卡
function c79613121.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ②号效果的发动准备（Target）处理函数
function c79613121.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c79613121.thfilter(chkc) end
	-- 检查自己墓地是否存在符合条件的魔法卡
	if chk==0 then return Duel.IsExistingTarget(c79613121.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c79613121.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将目标卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②号效果的效果处理（Operation）函数
function c79613121.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
