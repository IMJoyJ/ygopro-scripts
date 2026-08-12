--ゼアル・エントラスト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地的「希望皇 霍普」、「异热同心武器」、「异热同心从者」怪兽之内任意1只为对象才能发动。那只怪兽加入手卡或特殊召唤。
-- ②：自己基本分比对方少2000以上的场合，把墓地的这张卡除外，以「异热同心信托」以外的自己墓地1张「异热同心」魔法·陷阱卡为对象才能发动。那张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c4017398.initial_effect(c)
	-- ①：以自己墓地的「希望皇 霍普」、「异热同心武器」、「异热同心从者」怪兽之内任意1只为对象才能发动。那只怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,4017398)
	e1:SetTarget(c4017398.target)
	e1:SetOperation(c4017398.activate)
	c:RegisterEffect(e1)
	-- ②：自己基本分比对方少2000以上的场合，把墓地的这张卡除外，以「异热同心信托」以外的自己墓地1张「异热同心」魔法·陷阱卡为对象才能发动。那张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4017398,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,4017399)
	-- 将这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c4017398.thcon)
	e2:SetTarget(c4017398.thtg)
	e2:SetOperation(c4017398.thop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的怪兽组（包括能加入手牌或能特殊召唤的怪兽）
function c4017398.spfilter(c,e,tp)
	return c:IsSetCard(0x107f,0x107e,0x207e) and c:IsType(TYPE_MONSTER)
		-- 判断目标怪兽是否能特殊召唤或加入手牌
		and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 设置效果的对象为满足条件的墓地怪兽
function c4017398.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4017398.spfilter(chkc,e,tp) end
	-- 判断是否存在满足条件的墓地怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c4017398.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c4017398.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
end
-- 处理效果的发动，根据条件选择将怪兽特殊召唤或加入手牌
function c4017398.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 检查是否因王家长眠之谷而无效
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 判断场上是否有足够空间进行特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 根据玩家选择决定是否特殊召唤
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将目标怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将目标怪兽加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
-- 判断是否满足效果发动条件（自己基本分比对方少2000以上）
function c4017398.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己基本分是否比对方少2000以上，并且该卡未在送去墓地的回合发动
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp)-2000 and aux.exccon(e)
end
-- 检索满足条件的魔法·陷阱卡（异热同心卡且非本卡）
function c4017398.thfilter(c)
	return c:IsSetCard(0x7e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(4017398) and c:IsAbleToHand()
end
-- 设置效果的对象为满足条件的墓地魔法·陷阱卡
function c4017398.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4017398.thfilter(chkc) end
	-- 判断是否存在满足条件的墓地魔法·陷阱卡作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c4017398.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c4017398.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果的发动，将目标魔法·陷阱卡加入手牌
function c4017398.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标魔法·陷阱卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
