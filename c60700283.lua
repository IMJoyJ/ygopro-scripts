--星騎士 キュグニ
-- 效果：
-- 这个卡名在规则上也当作「星圣」卡使用。这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤的场合才能发动。从卡组把1只「星骑士」、「星圣」怪兽加入手卡。
-- ②：以自己场上1只其他的光属性怪兽为对象才能发动。那只怪兽和这张卡的等级上升1星。
-- ③：以怪兽3只以上为素材的「星骑士」超量怪兽超量召唤的场合，这张卡可以作为2只数量的超量素材。
local s,id,o=GetID()
-- 初始化函数，注册该卡片的所有效果
function s.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤的场合才能发动。从卡组把1只「星骑士」、「星圣」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	s.star_knight_summon_effect=e1
	-- ②：以自己场上1只其他的光属性怪兽为对象才能发动。那只怪兽和这张卡的等级上升1星。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"改变等级"
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.lvtg)
	e4:SetOperation(s.lvop)
	c:RegisterEffect(e4)
	-- ③：以怪兽3只以上为素材的「星骑士」超量怪兽超量召唤的场合，这张卡可以作为2只数量的超量素材。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_DOUBLE_XMATERIAL)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.sxyzfilter)
	e5:SetValue(id)
	e5:SetCountLimit(1,id+o*2)
	c:RegisterEffect(e5)
end
-- 过滤卡组中可以加入手牌的「星骑士」或「星圣」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x9c,0x53) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动准备与可行性检测
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 检查卡组中是否存在可以加入手牌的「星骑士」或「星圣」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,exc) end
	-- 设置将卡组中的卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理过程
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「星骑士」或「星圣」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤场上表侧表示、等级1以上的光属性怪兽
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- ②效果的发动准备与选择对象
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) and chkc:IsControler(tp) and chkc~=e:GetHandler() end
	-- 检查自己场上是否存在除自身以外的其他光属性怪兽，且自身等级在1以上
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) and c:IsLevelAbove(1) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只其他的光属性怪兽作为效果对象
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- ②效果的实际处理过程
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and tc:IsFaceup()
		and c:IsRelateToChain() and c:IsType(TYPE_MONSTER) and c:IsFaceup() then
		-- 那只怪兽...等级上升1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- ...和这张卡的等级上升1星。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 过滤作为超量召唤目标的「星骑士」超量怪兽
function s.sxyzfilter(e,c)
	return c:IsSetCard(0x9c)
end
