--超重武者装留イワトオシ
-- 效果：
-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
-- ②：用这张卡的效果把这张卡装备的怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把「超重武者装留 岩融」以外的1只「超重武者」怪兽加入手卡。
function c90361010.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90361010,0))  --"给「超重武者」怪兽装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c90361010.eqtg)
	e1:SetOperation(c90361010.eqop)
	c:RegisterEffect(e1)
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把「超重武者装留 岩融」以外的1只「超重武者」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90361010,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c90361010.thcon)
	e2:SetTarget(c90361010.thtg)
	e2:SetOperation(c90361010.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「超重武者」怪兽
function c90361010.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- 装备效果的发动准备与对象选择
function c90361010.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c90361010.filter(chkc) end
	-- 判定自己魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定自己场上是否存在除自身以外可以装备的「超重武者」怪兽
		and Duel.IsExistingTarget(c90361010.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只「超重武者」怪兽作为效果的对象
	Duel.SelectTarget(tp,c90361010.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 装备效果的执行处理
function c90361010.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取作为装备对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查魔法与陷阱区是否有空位，以及对象怪兽是否仍在自己场上表侧表示存在且效果关系成立
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 若不满足装备条件，则将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- 从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c90361010.eqlimit)
	c:RegisterEffect(e1)
	-- ②：用这张卡的效果把这张卡装备的怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制：只能装备给「超重武者」怪兽
function c90361010.eqlimit(e,c)
	return c:IsSetCard(0x9a)
end
-- 判定这张卡是否是从场上送去墓地
function c90361010.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：卡组中「超重武者装留 岩融」以外的1只「超重武者」怪兽
function c90361010.thfilter(c)
	return c:IsSetCard(0x9a) and not c:IsCode(90361010) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动准备与操作信息注册
function c90361010.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定卡组中是否存在满足条件的「超重武者」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90361010.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行处理
function c90361010.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的「超重武者」怪兽
	local g=Duel.SelectMatchingCard(tp,c90361010.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
