--嘆きの石版
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：装备怪兽不能攻击，效果无效化，不能解放。
-- ②：1回合1次，装备怪兽在自己场上存在的场合才能发动。从卡组把「叹息之石版」以外的1张「石版」卡加入手卡。
-- ③：装备怪兽被破坏让这张卡被送去墓地的场合才能发动。给与对方500伤害。
local s,id,o=GetID()
-- 初始化效果，创建装备效果的主触发效果，设置为自由时点，可以装备怪兽，限制发动次数为1次
function s.initial_effect(c)
	-- ①：装备怪兽不能攻击，效果无效化，不能解放。
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_EQUIP)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
	-- ①：装备怪兽不能攻击，效果无效化，不能解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e1)
	-- ①：装备怪兽不能攻击，效果无效化，不能解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
	-- ①：装备怪兽不能攻击，效果无效化，不能解放。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e4)
	-- ②：1回合1次，装备怪兽在自己场上存在的场合才能发动。从卡组把「叹息之石版」以外的1张「石版」卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"检索"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.thcon)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
	-- ③：装备怪兽被破坏让这张卡被送去墓地的场合才能发动。给与对方500伤害。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))  --"给与伤害"
	e6:SetCategory(CATEGORY_DAMAGE)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetCondition(s.damcon)
	e6:SetTarget(s.damtg)
	e6:SetOperation(s.damop)
	c:RegisterEffect(e6)
	-- 装备限制效果，防止此卡被其他卡装备。
	local e7=Effect.CreateEffect(c)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_EQUIP_LIMIT)
	e7:SetValue(1)
	c:RegisterEffect(e7)
end
-- 装备选择目标的处理函数，用于选择一个正面表示的怪兽作为装备对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否满足装备目标的条件，检查场上是否存在正面表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个正面表示的怪兽作为装备对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
-- 装备卡的处理函数，将装备卡装备给目标怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 检索效果的发动条件判断函数，判断装备怪兽是否在自己场上
function s.thcon(e)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	return tc and c:GetControler()==tc:GetControler()
end
-- 检索效果的过滤函数，筛选卡组中非本卡且为石版卡的卡
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1b6) and c:IsAbleToHand()
end
-- 检索效果的目标设定函数，检查卡组中是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索效果的发动条件，检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，从卡组选择一张满足条件的卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 伤害效果的发动条件判断函数，判断装备怪兽是否被破坏并送入墓地
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return ec and c:IsReason(REASON_LOST_TARGET) and ec:IsReason(REASON_DESTROY)
end
-- 伤害效果的目标设定函数，设置伤害对象和伤害值
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的目标伤害值为500
	Duel.SetTargetParam(500)
	-- 设置伤害效果的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 伤害效果的处理函数，对对方造成500点伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
