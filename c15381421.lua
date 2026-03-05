--輝光竜セイファート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·场上（表侧表示）把龙族怪兽任意数量送去墓地才能发动。把持有和送去墓地的怪兽的原本等级合计相同等级的1只龙族怪兽从卡组加入手卡。
-- ②：把墓地的这张卡除外，以自己墓地1只光·暗属性的龙族·8星怪兽为对象才能发动。那只怪兽加入手卡。
function c15381421.initial_effect(c)
	-- ①：从自己的手卡·场上（表侧表示）把龙族怪兽任意数量送去墓地才能发动。把持有和送去墓地的怪兽的原本等级合计相同等级的1只龙族怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15381421,0))  --"请选择要加入手卡的怪兽的等级"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,15381421)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c15381421.thcost)
	e1:SetTarget(c15381421.thtg)
	e1:SetOperation(c15381421.thop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只光·暗属性的龙族·8星怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,15381422)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c15381421.thtg2)
	e2:SetOperation(c15381421.thop2)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的龙族怪兽（手牌或场上表侧表示）
function c15381421.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:GetOriginalLevel()>0 and c:IsAbleToGraveAsCost()
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
-- 过滤满足条件的龙族怪兽（卡组）
function c15381421.filter(c,e,tp,rg)
	local lv=c:GetLevel()
	return lv>0 and c:IsRace(RACE_DRAGON) and c:IsAbleToHand() and rg:CheckWithSumEqual(Card.GetOriginalLevel,lv,1,99)
end
-- 设置标记，表示效果已准备就绪
function c15381421.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 检索满足条件的龙族怪兽并选择等级，然后将指定数量的龙族怪兽送去墓地
function c15381421.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的龙族怪兽（手牌或场上表侧表示）
	local rg=Duel.GetMatchingGroup(c15381421.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查卡组中是否存在满足条件的龙族怪兽
		return Duel.IsExistingMatchingCard(c15381421.filter,tp,LOCATION_DECK,0,1,nil,e,tp,rg) end
	-- 获取卡组中满足条件的龙族怪兽
	local g=Duel.GetMatchingGroup(c15381421.filter,tp,LOCATION_DECK,0,nil,e,tp,rg)
	local lvt={}
	local pc=1
	for i=1,12 do
		if g:IsExists(c15381421.thfilter,1,nil,i) then lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	-- 宣言一个等级
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	-- 获取满足条件的龙族怪兽（手牌或场上表侧表示）
	local rg=Duel.GetMatchingGroup(c15381421.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=rg:SelectWithSumEqual(tp,Card.GetOriginalLevel,lv,1,99)
	-- 将选择的龙族怪兽送去墓地
	Duel.SendtoGrave(sg,REASON_COST)
	e:SetLabel(lv)
	-- 设置连锁操作信息，准备将龙族怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤满足条件的龙族怪兽（卡组）
function c15381421.thfilter(c,lv)
	return c:IsLevel(lv) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 选择并加入手牌
function c15381421.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足等级条件的龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c15381421.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选择的龙族怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤满足条件的光·暗属性龙族8星怪兽
function c15381421.thfilter2(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsLevel(8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 选择并设置目标怪兽
function c15381421.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c15381421.thfilter2(chkc) end
	-- 检查墓地是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c15381421.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地怪兽
	local g=Duel.SelectTarget(tp,c15381421.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，准备将怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果，将目标怪兽加入手牌
function c15381421.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
