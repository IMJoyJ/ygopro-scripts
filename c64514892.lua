--小法師ヒダルマー
-- 效果：
-- 兽族·兽战士族·鸟兽族怪兽2只
-- ①：这张卡的攻击力上升场上的兽族·兽战士族·鸟兽族怪兽数量×100。
-- ②：1回合1次，以自己以及对方场上的魔法·陷阱卡各1张为对象才能发动。那些卡破坏。
-- ③：这张卡战斗破坏对方怪兽时，从自己墓地的怪兽以及除外的自己怪兽之中以1只兽族·兽战士族·鸟兽族怪兽为对象才能发动。那只怪兽加入手卡。
function c64514892.initial_effect(c)
	-- 设置连接召唤手续：兽族·兽战士族·鸟兽族怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升场上的兽族·兽战士族·鸟兽族怪兽数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c64514892.atkval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己以及对方场上的魔法·陷阱卡各1张为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64514892,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetTarget(c64514892.destg)
	e2:SetOperation(c64514892.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡战斗破坏对方怪兽时，从自己墓地的怪兽以及除外的自己怪兽之中以1只兽族·兽战士族·鸟兽族怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64514892,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果发动条件：这张卡战斗破坏对方怪兽时
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(c64514892.thtg)
	e3:SetOperation(c64514892.thop)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示的兽族、兽战士族、鸟兽族怪兽
function c64514892.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
end
-- 定义攻击力上升数值的计算函数
function c64514892.atkval(e,c)
	-- 返回场上符合条件的怪兽数量乘以100的数值
	return Duel.GetMatchingGroupCount(c64514892.cfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)*100
end
-- 过滤魔法、陷阱卡
function c64514892.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果②（破坏魔法·陷阱）的发动准备与目标选择
function c64514892.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在发动时，检查自己场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c64514892.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 在发动时，检查对方场上是否存在可以作为对象的魔法·陷阱卡
		and Duel.IsExistingTarget(c64514892.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张魔法·陷阱卡作为对象
	local g1=Duel.SelectTarget(tp,c64514892.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为对象
	local g2=Duel.SelectTarget(tp,c64514892.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息：破坏选中的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果②（破坏魔法·陷阱）的效果处理
function c64514892.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 破坏仍存在于场上的对象卡片
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 过滤自己墓地或除外状态的兽族、兽战士族、鸟兽族怪兽
function c64514892.thfilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToHand()
end
-- 效果③（回收怪兽）的发动准备与目标选择
function c64514892.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c64514892.thfilter(chkc) end
	-- 在发动时，检查自己墓地或除外状态是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c64514892.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地或除外状态的1只符合条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c64514892.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③（回收怪兽）的效果处理
function c64514892.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的那张卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
