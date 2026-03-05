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
	-- 设置效果条件为：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置效果的费用为：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c19186123.thtg)
	e2:SetOperation(c19186123.thop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的「幻影英雄」怪兽卡，用于特殊召唤效果的目标选择
function c19186123.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x5008) and c:GetSequence()<5 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤效果的发动条件，包括场上是否有空位和是否存在符合条件的目标怪兽
function c19186123.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and c19186123.filter(chkc,e,tp) end
	-- 判断场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己魔法与陷阱区域是否存在符合条件的「幻影英雄」怪兽卡
		and Duel.IsExistingTarget(c19186123.filter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的「幻影英雄」怪兽卡作为特殊召唤的目标
	local g=Duel.SelectTarget(tp,c19186123.filter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示将特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，将目标怪兽特殊召唤到场上
function c19186123.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤满足条件的「幻影英雄」怪兽卡，用于墓地回收效果的目标选择
function c19186123.thfilter(c)
	return c:IsSetCard(0x5008) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 判断是否满足墓地回收效果的发动条件，包括是否存在符合条件的目标怪兽
function c19186123.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19186123.thfilter(chkc) end
	-- 判断自己墓地是否存在符合条件的「幻影英雄」怪兽卡
	if chk==0 then return Duel.IsExistingTarget(c19186123.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择符合条件的「幻影英雄」怪兽卡作为加入手牌的目标
	local sg=Duel.SelectTarget(tp,c19186123.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，表示将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 执行墓地回收操作，将目标怪兽加入手牌
function c19186123.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
