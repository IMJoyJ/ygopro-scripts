--スピリット変換装置
-- 效果：
-- ①：1回合1次，以自己场上1只超量怪兽为对象才能发动。选自己场上1只光属性·4星怪兽作为成为对象的超量怪兽的超量素材。
-- ②：这张卡从场上送去墓地的场合，以自己墓地2只雷族·光属性·4星的同名怪兽为对象发动。那些雷族·光属性怪兽加入手卡。
function c20802187.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以自己场上1只超量怪兽为对象才能发动。选自己场上1只光属性·4星怪兽作为成为对象的超量怪兽的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20802187,0))  --"素材补充"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c20802187.mattg)
	e2:SetOperation(c20802187.matop)
	c:RegisterEffect(e2)
	-- ②：这张卡从场上送去墓地的场合，以自己墓地2只雷族·光属性·4星的同名怪兽为对象发动。那些雷族·光属性怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20802187,1))  --"加入手牌"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c20802187.thcon)
	e3:SetTarget(c20802187.thtg)
	e3:SetOperation(c20802187.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否为表侧表示的超量怪兽
function c20802187.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 过滤函数，用于判断是否为表侧表示的光属性4星怪兽且可以作为超量素材
function c20802187.matfilter(c,e)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4) and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 效果处理时的判断函数，检查是否满足选择对象和素材的条件
function c20802187.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c20802187.xyzfilter(chkc) end
	-- 检查自己场上是否存在至少1只表侧表示的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c20802187.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否存在至少1只表侧表示的光属性4星怪兽
		and Duel.IsExistingMatchingCard(c20802187.matfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只表侧表示的超量怪兽作为效果对象
	Duel.SelectTarget(tp,c20802187.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数，将选中的光属性4星怪兽作为超量素材叠放
function c20802187.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 选择1只满足条件的光属性4星怪兽作为超量素材
		local g=Duel.SelectMatchingCard(tp,c20802187.matfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
		if g:GetCount()>0 then
			-- 将选中的怪兽作为超量素材叠放至目标怪兽上
			Duel.Overlay(tc,g)
		end
	end
end
-- 判断此卡是否从场上送去墓地
function c20802187.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，用于判断是否为雷族·光属性·4星怪兽
function c20802187.thfilter(c,e)
	return c:IsRace(RACE_THUNDER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4) and c:IsCanBeEffectTarget(e)
end
-- 过滤函数，用于判断墓地中的怪兽是否与已选怪兽同名
function c20802187.thfilter2(c,g)
	return g:IsExists(Card.IsCode,1,c,c:GetCode())
end
-- 效果处理时的判断函数，选择满足条件的2只雷族·光属性·4星怪兽
function c20802187.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c20802187.thfilter(chkc,e) end
	-- 获取满足条件的墓地中的雷族·光属性·4星怪兽
	local g=Duel.GetMatchingGroup(c20802187.thfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return true end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local g1=g:FilterSelect(tp,c20802187.thfilter2,1,1,nil,g)
	if g1:GetCount()>0 then
		local g2=g:FilterSelect(tp,Card.IsCode,1,1,g1:GetFirst(),g1:GetFirst():GetCode())
		g1:Merge(g2)
		-- 设置当前处理的连锁的目标卡组
		Duel.SetTargetCard(g1)
		-- 设置当前处理的连锁的操作信息，指定将卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
	end
end
-- 效果处理函数，将满足条件的怪兽加入手牌并确认
function c20802187.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将目标卡组中的卡以效果原因加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
