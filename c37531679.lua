--飛龍炎サラマンドラ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以自己场上1只战士族怪兽为对象才能发动。这张卡当作装备魔法卡使用给那只自己怪兽装备。
-- ②：只要这张卡给「炎之剑士」或者有那个卡名记述的怪兽装备中，装备怪兽的攻击力上升700。
-- ③：这张卡被送去墓地的场合才能发动。从卡组把1张「飞龙炎」魔法·陷阱卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果，包括装备攻击力提升效果、装备效果发动效果、墓地发动检索效果
function s.initial_effect(c)
	-- 记录该卡具有「炎之剑士」的卡名
	aux.AddCodeList(c,45231177)
	-- 只要这张卡给「炎之剑士」或者有那个卡名记述的怪兽装备中，装备怪兽的攻击力上升700
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.eqcon)
	e1:SetValue(700)
	c:RegisterEffect(e1)
	-- 这张卡在手卡·墓地存在的场合，以自己场上1只战士族怪兽为对象才能发动。这张卡当作装备魔法卡使用给那只自己怪兽装备
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"装备效果"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	-- 这张卡被送去墓地的场合才能发动。从卡组把1张「飞龙炎」魔法·陷阱卡加入手卡
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索「飞龙炎」魔法·陷阱卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 判断装备怪兽是否为「炎之剑士」或具有其卡名
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local qc=e:GetHandler():GetEquipTarget()
	-- 装备怪兽为「炎之剑士」或具有其卡名
	return (qc:IsCode(45231177) or aux.IsCodeListed(qc,45231177))
end
-- 筛选场上正面表示的战士族怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 设置装备效果的发动条件和目标选择
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) and chkc~=c end
	-- 判断场上是否有足够的装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():CheckUniqueOnField(tp)
		-- 判断场上是否存在符合条件的战士族怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,c) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上符合条件的战士族怪兽作为装备对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,c)
	if c:IsLocation(LOCATION_GRAVE) then
		-- 设置装备效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,0,0,0)
	end
end
-- 装备效果的处理函数
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取装备效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断装备条件是否满足
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or tc:GetControler()~=tp
		or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 执行装备操作
	if not Duel.Equip(tp,c,tc) then return end
	-- 设置装备限制效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 限制只能装备到指定怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 筛选「飞龙炎」魔法·陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x1ac) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置检索效果的发动条件和操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在符合条件的「飞龙炎」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一张符合条件的「飞龙炎」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
