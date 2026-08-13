--幻影解放
-- 效果：
-- ①：以自己的魔法与陷阱区域1张「幻影英雄」怪兽卡为对象才能发动。那张卡特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1只「幻影英雄」怪兽为对象才能发动。那只怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c19186123.initial_effect(c)
	-- ①：以自己的魔法与陷阱区域1张「幻影英雄」怪兽卡为对象才能发动。那张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19186123,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c19186123.target)
	e1:SetOperation(c19186123.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只「幻影英雄」怪兽为对象才能发动。那只怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19186123,1))  --"回收墓地"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置②效果的发动条件：这张卡送去墓地的回合不能发动。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c19186123.thtg)
	e2:SetOperation(c19186123.thop)
	c:RegisterEffect(e2)
end
-- 定义①效果的对象筛选条件：对象必须是表侧表示的「幻影英雄」怪兽卡，位于自己的魔法与陷阱区域（序号0~4），且可以被特殊召唤。
function c19186123.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x5008) and c:GetSequence()<5 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动时点处理：验证取对象条件，并选择自己魔法与陷阱区域的1张符合条件的「幻影英雄」怪兽卡作为对象。
function c19186123.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and c19186123.filter(chkc,e,tp) end
	-- 发动①效果的检测之一：确认自己主要怪兽区有空位可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动①效果的检测之二：确认自己魔法与陷阱区域存在至少1张符合条件的「幻影英雄」怪兽卡可选择为对象。
		and Duel.IsExistingTarget(c19186123.filter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 显示“请选择要特殊召唤的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己魔法与陷阱区域选择1张符合条件的「幻影英雄」怪兽卡，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c19186123.filter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息：效果分类为特殊召唤，对象为已选择的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：取得对象怪兽，若其仍与效果关联，则将其特殊召唤到自己场上。
function c19186123.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得“幻影解放”①效果的对象卡（唯一的对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上（sumtype=0，不检查召唤条件/苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果的对象筛选条件：对象必须是「幻影英雄」怪兽卡，且能够加入手卡。
function c19186123.thfilter(c)
	return c:IsSetCard(0x5008) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动时点处理：验证取对象条件，并选择自己墓地的1只符合条件的「幻影英雄」怪兽作为对象。
function c19186123.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19186123.thfilter(chkc) end
	-- 发动②效果的检测：确认自己墓地存在至少1只符合条件的「幻影英雄」怪兽可选择为对象。
	if chk==0 then return Duel.IsExistingTarget(c19186123.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示“请选择要加入手牌的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只符合条件的「幻影英雄」怪兽，并将其设为效果对象。
	local sg=Duel.SelectTarget(tp,c19186123.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁的操作信息：效果分类为加入手卡，对象为已选择的卡，数量为其数量。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- ②效果处理：取得对象怪兽，若其仍与效果关联，则将其加入持有者的手卡。
function c19186123.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得“幻影解放”②效果的对象卡（唯一的对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果原因送去其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
