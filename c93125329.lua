--金雲獣－馬龍
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。这张卡的等级上升或下降1星。
-- ②：这张卡被送去墓地的场合，以对方场上1张表侧表示卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 注册卡片的效果，包括同调召唤手续、特殊召唤成功时改变等级的效果，以及送去墓地时让对方场上1张表侧表示卡回到手卡的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- ①：这张卡特殊召唤的场合才能发动。这张卡的等级上升或下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以对方场上1张表侧表示卡为对象才能发动。那张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- ①号效果的处理：让玩家选择上升1星或下降1星（等级2以上才能选择下降），并对这张卡适用改变等级的效果。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or c:IsFacedown() then return end
	local down=c:IsLevelAbove(2)
	local lv=aux.SelectFromOptions(tp,{true,aux.Stringid(id,2)},{down,aux.Stringid(id,3),-1})  --"等级上升/等级下降"
	-- 这张卡的等级上升或下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(lv)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 过滤对方场上表侧表示且可以回到手牌的卡片。
function s.filter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- ②号效果的发动准备：进行对象合法性检查，确认对方场上是否存在可以回到手牌的表侧表示卡，并让玩家选择1张卡作为效果对象，设置操作信息为将该卡送回手牌。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.filter(chkc) end
	-- 在效果发动阶段，检查对方场上是否存在至少1张满足条件的表侧表示卡。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择对方场上1张表侧表示卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理的操作信息，表示将有1张卡回到手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②号效果的处理：获取选中的对象卡，若该卡仍与效果相关联，则将其送回持有者的手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片。
	local tc=Duel.GetFirstTarget()
	-- 如果对象卡在效果处理时仍然存在且符合条件，则将其送回持有者的手牌。
	if tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
