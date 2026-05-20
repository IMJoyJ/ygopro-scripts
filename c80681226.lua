--サイキック・ウェーブ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有机械族怪兽存在的场合，从手卡·卡组把1只「人造人-念力震慑者」送去墓地才能发动。给与对方600伤害。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只机械族怪兽为对象才能发动。从卡组把1只「人造人」怪兽送去墓地，作为对象的怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c80681226.initial_effect(c)
	-- 注册卡片记有「人造人-念力震慑者」卡名（用于支持相关检索或辅助效果判定）
	aux.AddCodeList(c,77585513)
	-- ①：自己场上有机械族怪兽存在的场合，从手卡·卡组把1只「人造人-念力震慑者」送去墓地才能发动。给与对方600伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c80681226.condition)
	e1:SetCost(c80681226.cost)
	e1:SetTarget(c80681226.target)
	e1:SetOperation(c80681226.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只机械族怪兽为对象才能发动。从卡组把1只「人造人」怪兽送去墓地，作为对象的怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,80681226)
	-- 设置效果2的发动条件：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置效果2的代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c80681226.thtg)
	e2:SetOperation(c80681226.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的机械族怪兽
function c80681226.cfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsFaceup()
end
-- 效果1的发动条件判定
function c80681226.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的机械族怪兽
	return Duel.IsExistingMatchingCard(c80681226.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：手卡·卡组中可以送去墓地的「人造人-念力震慑者」
function c80681226.costfilter(c)
	return c:IsCode(77585513) and c:IsAbleToGraveAsCost()
end
-- 效果1的发动代价处理
function c80681226.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡·卡组是否存在可以作为代价送去墓地的「人造人-念力震慑者」
	if chk==0 then return Duel.IsExistingMatchingCard(c80681226.costfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 从手卡·卡组选择1只「人造人-念力震慑者」
	local g=Duel.SelectMatchingCard(tp,c80681226.costfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	-- 将选择的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果1的发动准备与效果分类注册
function c80681226.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果处理的伤害数值为600
	Duel.SetTargetParam(600)
	-- 设置效果处理的操作信息：给与对方600伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 效果1的实际效果处理（给与伤害）
function c80681226.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 过滤条件：卡组中可以送去墓地的「人造人」怪兽
function c80681226.dfilter(c)
	return c:IsSetCard(0xbc) and c:IsAbleToGrave()
end
-- 过滤条件：墓地中可以加入手卡的机械族怪兽
function c80681226.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- 效果2的对象选择与效果分类注册
function c80681226.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c80681226.thfilter(chkc) end
	-- 检查自己墓地是否存在可以加入手卡的机械族怪兽
	if chk==0 then return Duel.IsExistingTarget(c80681226.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查卡组中是否存在可以送去墓地的「人造人」怪兽
		and Duel.IsExistingMatchingCard(c80681226.dfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只机械族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c80681226.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理的操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置效果处理的操作信息：将对象怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果2的实际效果处理（送墓并回收）
function c80681226.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只「人造人」怪兽
	local g=Duel.SelectMatchingCard(tp,c80681226.dfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的「人造人」怪兽送去墓地，并确认其成功送去墓地
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		and tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
