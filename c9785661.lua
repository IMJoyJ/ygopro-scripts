--飢渇聖徒エリュシクトーン
-- 效果：
-- 幻想魔族怪兽＋恶魔族怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合，以场上1张卡为对象才能发动。那张卡送去墓地。
-- ②：自己·对方的准备阶段，以自己墓地1张「蓟花」卡或「罪宝」卡为对象才能发动。那张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合素材设定、召唤限制以及①②效果的注册
function s.initial_effect(c)
	-- 设定融合素材为幻想魔族怪兽1只和恶魔族怪兽1只
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_ILLUSION),aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),true)
	c:EnableReviveLimit()
	-- ①：这张卡融合召唤的场合，以场上1张卡为对象才能发动。那张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的准备阶段，以自己墓地1张「蓟花」卡或「罪宝」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回手"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：这张卡融合召唤成功的场合
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果①的靶向/目标选择函数，确认场上是否存在可送去墓地的卡并将其设为效果对象
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToGrave() end
	-- 检查场上是否存在至少1张可以送去墓地的卡作为可选对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择场上1张可以送去墓地的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，表示该效果的操作分类为将选中的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果①的处理函数，将作为对象的卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①锁定的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 过滤自己墓地中可以加入手牌的「蓟花」卡或「罪宝」卡
function s.thfilter(c)
	return c:IsSetCard(0x1bc,0x19e) and c:IsAbleToHand()
end
-- 效果②的靶向/目标选择函数，确认自己墓地是否存在符合条件的「蓟花」或「罪宝」卡并将其设为效果对象
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1张可以加入手牌的「蓟花」或「罪宝」卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择自己墓地1张符合条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，表示该效果的操作分类为将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理函数，将作为对象的卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②锁定的对象卡
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡在效果处理时仍存在且未受「王家长眠之谷」影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 因效果将目标卡加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
