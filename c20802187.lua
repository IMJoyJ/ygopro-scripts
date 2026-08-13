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
-- 筛选自己场上表侧表示的超量怪兽，作为①效果的对象候选。
function c20802187.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 筛选自己场上表侧表示、光属性、4星且可作为超量素材的怪兽，并排除不受该效果影响的卡。
function c20802187.matfilter(c,e)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4) and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- ①效果的取对象处理：选择自己场上1只表侧表示超量怪兽作为对象，并确认有可成为素材的光属性4星怪兽。
function c20802187.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c20802187.xyzfilter(chkc) end
	-- 发动时检查自己场上是否存在1只表侧表示超量怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c20802187.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 同时检查自己场上是否存在1只符合条件的可作超量素材的光属性4星怪兽。
		and Duel.IsExistingMatchingCard(c20802187.matfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示，让玩家选择1只表侧表示的超量怪兽作为对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只表侧表示的超量怪兽作为效果对象。
	Duel.SelectTarget(tp,c20802187.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理时，确认对象超量怪兽仍在场且有效，选择1只光属性4星怪兽叠放在其下方作为超量素材。
function c20802187.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的那只超量怪兽作为对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 弹出选择提示，让玩家选择要作为超量素材的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从自己场上选择1只满足条件的光属性4星怪兽作为素材候选。
		local g=Duel.SelectMatchingCard(tp,c20802187.matfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
		if g:GetCount()>0 then
			-- 将选择的怪兽作为超量素材叠放在对象超量怪兽下方。
			Duel.Overlay(tc,g)
		end
	end
end
-- ②效果的发动条件：这张卡从场上送去墓地（即之前位于场上）。
function c20802187.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选墓地中符合条件的雷族·光属性·4星怪兽作为②效果的对象候选，且能成为效果对象。
function c20802187.thfilter(c,e)
	return c:IsRace(RACE_THUNDER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4) and c:IsCanBeEffectTarget(e)
end
-- 用于确保选择的两只怪兽卡名相同（检查已选卡在剩余组中是否有同名卡）。
function c20802187.thfilter2(c,g)
	return g:IsExists(Card.IsCode,1,c,c:GetCode())
end
-- ②效果的取对象处理：从自己墓地选择2只雷族·光属性·4星的同名怪兽为对象，并设置加入手卡的操作信息。
function c20802187.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c20802187.thfilter(chkc,e) end
	-- 获取自己墓地中所有雷族·光属性·4星且能成为效果对象的怪兽组成候选组。
	local g=Duel.GetMatchingGroup(c20802187.thfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return true end
	-- 弹出选择提示，让玩家选择要加入手卡的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local g1=g:FilterSelect(tp,c20802187.thfilter2,1,1,nil,g)
	if g1:GetCount()>0 then
		local g2=g:FilterSelect(tp,Card.IsCode,1,1,g1:GetFirst(),g1:GetFirst():GetCode())
		g1:Merge(g2)
		-- 将选择的两只同名怪兽设置为效果对象。
		Duel.SetTargetCard(g1)
		-- 设置本次操作将把2只对象怪兽加入手卡，供连锁判定使用。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
	end
end
-- 效果处理时，将对象怪兽加入手卡，并向对方确认。
function c20802187.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时记录的对象怪兽组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将对象怪兽送入其持有者的手卡（实际返回手卡）。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的怪兽，确认效果处理。
		Duel.ConfirmCards(1-tp,sg)
	end
end
