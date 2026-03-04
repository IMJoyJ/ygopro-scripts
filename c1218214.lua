--方界法
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1张「方界」卡送去墓地，自己从卡组抽1张。
-- ②：只要这张卡在魔法与陷阱区域存在，自己的「方界」怪兽的战斗发生的对自己的战斗伤害变成0。
-- ③：把墓地的这张卡除外，以自己墓地1只「方界」怪兽为对象才能发动。那只怪兽加入手卡。
function c1218214.initial_effect(c)
	-- ①：自己主要阶段才能发动。从手卡把1张「方界」卡送去墓地，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在，自己的「方界」怪兽的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c1218214.filter)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ①：自己主要阶段才能发动。从手卡把1张「方界」卡送去墓地，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,1218214)
	e3:SetTarget(c1218214.drawtg)
	e3:SetOperation(c1218214.drawop)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外，以自己墓地1只「方界」怪兽为对象才能发动。那只怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,1218215)
	-- 将这张卡除外作为cost
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c1218214.thtg)
	e4:SetOperation(c1218214.thop)
	c:RegisterEffect(e4)
end
-- 判断目标怪兽是否为「方界」卡
function c1218214.filter(e,c)
	return c:IsSetCard(0xe3)
end
-- 判断手卡是否包含「方界」卡
function c1218214.cfilter(c)
	return c:IsSetCard(0xe3)
end
-- 设置①效果的发动条件
function c1218214.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查手卡是否存在「方界」卡
		and Duel.IsExistingMatchingCard(c1218214.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置将手卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 设置抽卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 设置①效果的处理流程
function c1218214.drawop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行丢弃手卡并抽卡的操作
	if Duel.DiscardHand(tp,c1218214.cfilter,1,1,REASON_EFFECT)>0 then
		-- 执行抽卡操作
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 判断墓地的怪兽是否为「方界」怪兽且可加入手卡
function c1218214.thfilter(c)
	return c:IsSetCard(0xe3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置③效果的发动条件
function c1218214.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c1218214.thfilter(chkc) end
	-- 检查墓地是否存在「方界」怪兽
	if chk==0 then return Duel.IsExistingTarget(c1218214.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c1218214.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将怪兽加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 设置③效果的处理流程
function c1218214.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
