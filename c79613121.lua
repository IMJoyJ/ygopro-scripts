--マジシャン・オブ・ブラックカオス・MAX
-- 效果：
-- 「混沌形态」降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，把自己场上1只怪兽解放才能发动。这个回合，对方不能把怪兽的效果发动。
-- ②：这张卡战斗破坏对方怪兽时，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。
function c79613121.initial_effect(c)
	-- 记录该卡记载了「混沌形态」的卡名
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
	-- 检测该卡是否战斗破坏了对方怪兽
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c79613121.thtg)
	e2:SetOperation(c79613121.thop)
	c:RegisterEffect(e2)
end
-- ①的效果的发动代价判断与解放怪兽操作
function c79613121.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否存在至少1只可以解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 让玩家选择场上1只用来解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 将选中的怪兽因代价解放
	Duel.Release(g,REASON_COST)
end
-- ①的效果的具体操作：在全局注册此回合内对方玩家不能把怪兽的效果发动的效果
function c79613121.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方不能把怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(c79613121.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向全局环境注册该限制效果，作用于当前玩家的对手
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动效果的卡片类型为怪兽卡
function c79613121.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 过滤墓地中的魔法卡且能加入手卡
function c79613121.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 回收魔法卡效果的目标判断与操作信息设置
function c79613121.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c79613121.thfilter(chkc) end
	-- 判断自己墓地是否存在符合回收条件的魔法卡
	if chk==0 then return Duel.IsExistingTarget(c79613121.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择墓地中1张魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c79613121.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为：将选中的魔法卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收魔法卡效果的具体操作：将选中的魔法卡从墓地加入手牌
function c79613121.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的目标魔法卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标魔法卡因效果加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
