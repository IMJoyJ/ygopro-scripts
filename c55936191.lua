--ベアルクティ－ミクタナス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，从手卡把这张卡以外的1只7星以上的怪兽解放才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己若非持有等级的怪兽则不能特殊召唤。
-- ②：这张卡特殊召唤成功的场合，以「北极天熊-小黑熊」以外的自己墓地1只「北极天熊」怪兽为对象才能发动。那只怪兽加入手卡。
function c55936191.initial_effect(c)
	-- 注册北极天熊系列怪兽共有的手卡特殊召唤效果（①号效果）
	local e1=aux.AddUrsarcticSpSummonEffect(c)
	e1:SetDescription(aux.Stringid(55936191,0))
	e1:SetCountLimit(1,55936191)
	-- ②：这张卡特殊召唤成功的场合，以「北极天熊-小黑熊」以外的自己墓地1只「北极天熊」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55936191,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,55936192)
	e2:SetTarget(c55936191.thtg)
	e2:SetOperation(c55936191.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地「北极天熊-小黑熊」以外的「北极天熊」怪兽，且能加入手卡
function c55936191.thfilter(c)
	return c:IsSetCard(0x163) and c:IsType(TYPE_MONSTER) and not c:IsCode(55936191) and c:IsAbleToHand()
end
-- 效果②（回收墓地怪兽）的发动准备与目标选择
function c55936191.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c55936191.thfilter(chkc) end
	-- 检查自己墓地是否存在符合条件的「北极天熊」怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c55936191.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的「北极天熊」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c55936191.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理信息，表示该效果包含将选中的1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②（回收墓地怪兽）的效果处理
function c55936191.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
