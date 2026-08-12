--H－C マグナム・エクスカリバー
-- 效果：
-- 战士族4星怪兽×2
-- ①：这张卡和对方怪兽进行战斗的伤害计算时，把这张卡2个超量素材取除才能发动。这张卡的攻击力只在那次伤害计算时变成2倍。
-- ②：1回合1次，自己·对方的主要阶段，以自己场上1只其他的表侧表示怪兽为对象才能发动。自己场上的这张卡当作攻击力·守备力上升2000的装备魔法卡使用给作为对象的怪兽装备。
-- ③：把墓地的这张卡除外才能发动。从自己墓地让3只战士族怪兽回到卡组。
local s,id,o=GetID()
-- 注册XYZ召唤手续并设置该卡为战士族4星怪兽×2，启用复活限制
function s.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足战士族条件的4星怪兽叠放2只以上
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),4,2)
	c:EnableReviveLimit()
	-- ①：这张卡和对方怪兽进行战斗的伤害计算时，把这张卡2个超量素材取除才能发动。这张卡的攻击力只在那次伤害计算时变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"攻击力变成2倍"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.atkcon)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己·对方的主要阶段，以自己场上1只其他的表侧表示怪兽为对象才能发动。自己场上的这张卡当作攻击力·守备力上升2000的装备魔法卡使用给作为对象的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"当作装备卡"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。从自己墓地让3只战士族怪兽回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"回到卡组"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	-- 效果发动时将此卡从游戏中除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 效果发动时判断是否处于战斗阶段
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- 效果发动时检查是否能移除2个超量素材并确认此卡未在该次伤害计算中使用过此效果
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) and c:GetFlagEffect(id)==0 end
	c:RemoveOverlayCard(tp,2,2,REASON_COST)
	c:RegisterFlagEffect(id,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 将此卡的攻击力设为原本攻击力的2倍
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		local atk=c:GetAttack()
		-- 将此卡的攻击力设为原本攻击力的2倍
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(atk*2)
		c:RegisterEffect(e1)
	end
end
-- 效果发动时判断是否处于主要阶段
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段
	return Duel.IsMainPhase()
end
-- 过滤函数，用于筛选场上表侧表示的怪兽
function s.eqfilter(c)
	return c:IsFaceup()
end
-- 设置装备效果的目标选择函数
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) and e:GetHandler()~=chkc end
	-- 判断装备区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断场上是否存在满足条件的怪兽作为装备对象
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择装备对象
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备效果
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and c:IsFaceup() and c:IsControler(tp) then
		-- 判断装备区是否已无空位
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0
			or tc:IsFacedown() or not tc:IsRelateToChain() or not tc:IsLocation(LOCATION_MZONE) then
			-- 将此卡送入墓地
			Duel.SendtoGrave(c,REASON_RULE)
			return
		end
		-- 尝试将此卡装备给目标怪兽
		if not Duel.Equip(tp,c,tc) then return end
		-- 设置装备限制，只能装备给指定怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 装备后使目标怪兽攻击力上升2000
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(2000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e3)
	end
end
-- 设置装备限制，只能装备给指定怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤函数，用于筛选墓地中的战士族怪兽
function s.tdfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 设置效果发动时的条件检查函数
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在至少3张战士族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,3,e:GetHandler()) end
	-- 设置效果发动时的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE)
end
-- 执行将墓地中的战士族怪兽送回卡组的效果
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查墓地中是否存在至少3张战士族怪兽
	if Duel.GetMatchingGroupCount(s.tdfilter,tp,LOCATION_GRAVE,0,nil)<3 then return end
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择3张满足条件的战士族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,3,3,nil)
	if g:GetCount()>0 then
		-- 显示所选怪兽被选为对象的动画
		Duel.HintSelection(g)
		-- 将所选怪兽送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
