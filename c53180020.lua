--影霊衣の戦士 エグザ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡被效果解放的场合才能发动。从卡组把1只龙族「影灵衣」仪式怪兽加入手卡。
-- ②：这张卡被除外的场合，以自己的除外状态的1只其他的「影灵衣」怪兽为对象才能发动。那只怪兽特殊召唤。
function c53180020.initial_effect(c)
	-- ①：这张卡被效果解放的场合才能发动。从卡组把1只龙族「影灵衣」仪式怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53180020,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_RELEASE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,53180020)
	e1:SetCondition(c53180020.thcon)
	e1:SetTarget(c53180020.thtg)
	e1:SetOperation(c53180020.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以自己的除外状态的1只其他的「影灵衣」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53180020,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,53180020)
	e2:SetTarget(c53180020.sptg)
	e2:SetOperation(c53180020.spop)
	c:RegisterEffect(e2)
end
-- 判断效果是否由效果解放触发
function c53180020.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 检索满足条件的龙族影灵衣仪式怪兽
function c53180020.thfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_RITUAL) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 设置效果处理时要检索的卡组中的龙族影灵衣仪式怪兽
function c53180020.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c53180020.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为检索手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行从卡组检索并加入手牌的操作
function c53180020.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c53180020.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 筛选可特殊召唤的影灵衣怪兽
function c53180020.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xb4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时要选择的目标
function c53180020.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c53180020.spfilter(chkc,e,tp) and chkc~=e:GetHandler() end
	-- 检查是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的除外怪兽
		and Duel.IsExistingTarget(c53180020.spfilter,tp,LOCATION_REMOVED,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的除外怪兽作为目标
	local g=Duel.SelectTarget(tp,c53180020.spfilter,tp,LOCATION_REMOVED,0,1,1,e:GetHandler(),e,tp)
	-- 设置效果处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行将目标怪兽特殊召唤的操作
function c53180020.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
