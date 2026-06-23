--R－ACEアビトレイター
-- 效果：
-- 炎属性怪兽2只以上
-- 自己对「救援ACE队 仲裁消防战车」1回合只能有1次特殊召唤，那个②的效果1回合可以使用最多2次。
-- ①：这张卡连接召唤的场合才能发动。从自己的卡组·墓地把1只「救援ACE队 消防栓」或1张「救援ACE队总部」加入手卡。
-- ②：自己把「救援ACE队」速攻魔法·通常陷阱卡发动的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果，设置卡片的代码列表、连接召唤条件、特殊召唤限制和两个效果
function s.initial_effect(c)
	-- 记录该卡与「救援ACE队 消防栓」和「救援ACE队总部」的关联
	aux.AddCodeList(c,63899465,37617348)
	c:SetSPSummonOnce(id)
	-- 设置该卡必须使用至少2只炎属性怪兽作为连接素材进行连接召唤
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_FIRE),2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从自己的卡组·墓地把1只「救援ACE队 消防栓」或1张「救援ACE队总部」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己把「救援ACE队」速攻魔法·通常陷阱卡发动的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(2,id)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 效果条件：确认该卡是否为连接召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索过滤器：筛选「救援ACE队 消防栓」或「救援ACE队总部」且能加入手牌的卡
function s.thfilter(c)
	return c:IsCode(63899465,37617348) and c:IsAbleToHand()
end
-- 效果目标设置：检查是否有满足条件的卡可检索并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的卡可检索
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息为检索1张卡到手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：选择并检索满足条件的卡到手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡进行检索
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果条件：确认是否为己方发动的「救援ACE队」速攻魔法或通常陷阱卡
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and (rc:GetType()==TYPE_TRAP or rc:GetType()&TYPE_QUICKPLAY==TYPE_QUICKPLAY)
		and rc:IsSetCard(0x18b)
end
-- 效果目标设置：选择对方场上的1张卡作为破坏对象并设置操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查是否能选择对方场上的卡作为破坏对象且该卡未使用过此效果
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏选中的对方场上的卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
