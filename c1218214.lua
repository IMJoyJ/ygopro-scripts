--方界法
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1张「方界」卡送去墓地，自己从卡组抽1张。
-- ②：只要这张卡在魔法与陷阱区域存在，自己的「方界」怪兽的战斗发生的对自己的战斗伤害变成0。
-- ③：把墓地的这张卡除外，以自己墓地1只「方界」怪兽为对象才能发动。那只怪兽加入手卡。
function c1218214.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
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
	-- 这个卡名的①③的效果1回合各能使用1次。①：自己主要阶段才能发动。从手卡把1张「方界」卡送去墓地，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
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
	-- 设置效果③的发动代价为将墓地的这张卡除外
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c1218214.thtg)
	e4:SetOperation(c1218214.thop)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断怪兽是否属于「方界」(0xe3)字段（用于适用避免战斗伤害效果）
function c1218214.filter(e,c)
	return c:IsSetCard(0xe3)
end
-- 过滤函数：筛选手卡中属于「方界」(0xe3)字段的卡片
function c1218214.cfilter(c)
	return c:IsSetCard(0xe3)
end
-- 效果①的Target函数：检测己方是否能抽1张卡且手卡存在「方界」卡，并设置送墓与抽卡的操作信息
function c1218214.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方可以因效果从卡组抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 发动检测时确认己方手卡中存在至少1张「方界」卡
		and Duel.IsExistingMatchingCard(c1218214.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置从己方手卡把1张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 设置己方从卡组抽1张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①的Operation函数：从手卡选择1张「方界」卡送去墓地，成功送入墓地后自己抽1张卡
function c1218214.drawop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方玩家发送选择要送去墓地的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方手卡中选择1张「方界」卡
	local g=Duel.SelectMatchingCard(tp,c1218214.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 以效果将选中的卡送去墓地，并确认该卡确实进入了墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 己方玩家以效果从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 过滤函数：筛选墓地中属于「方界」(0xe3)字段且可加入手卡的怪兽卡
function c1218214.thfilter(c)
	return c:IsSetCard(0xe3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果③的Target函数：检测己方墓地是否存在可回收的「方界」怪兽，取其中1只为对象并设置回手操作信息
function c1218214.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c1218214.thfilter(chkc) end
	-- 发动检测时确认己方墓地存在至少1只可以作为对象的「方界」怪兽
	if chk==0 then return Duel.IsExistingTarget(c1218214.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向己方玩家发送选择要加入手卡的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方墓地选择1只「方界」怪兽作为当前效果的对象
	local g=Duel.SelectTarget(tp,c1218214.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将所选对象怪兽加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③的Operation函数：确认对象怪兽仍与效果关联后，将其加入手卡并向对方确认
function c1218214.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动效果时指定为对象的那1只「方界」怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果将对象怪兽加入持有者（己方）手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家公开确认加入手卡的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
