--竜剣士ダイナマイトP
-- 效果：
-- ←6 【灵摆】 6→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以另一边的自己的灵摆区域1张「龙剑士」卡或「雾动机龙」卡为对象才能发动。那张卡特殊召唤。
-- 【怪兽效果】
-- 这个卡名在规则上也当作「雾动机龙」卡使用。这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡被解放的场合才能发动。除「龙剑士 雾动轰·输力」外的1只「龙剑士」灵摆怪兽或「雾动机龙」灵摆怪兽从自己的额外卡组（表侧）加入手卡。
function c28720123.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：以另一边的自己的灵摆区域1张「龙剑士」卡或「雾动机龙」卡为对象才能发动。那张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,28720123)
	e1:SetTarget(c28720123.sptg)
	e1:SetOperation(c28720123.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡被解放的场合才能发动。除「龙剑士 雾动轰·输力」外的1只「龙剑士」灵摆怪兽或「雾动机龙」灵摆怪兽从自己的额外卡组（表侧）加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,28720124)
	e2:SetTarget(c28720123.thtg)
	e2:SetOperation(c28720123.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断灵摆区域的卡是否为「龙剑士」或「雾动机龙」卡且可以被特殊召唤
function c28720123.spfilter(c,e,tp)
	return c:IsSetCard(0xc7,0xd8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置灵摆效果的发动条件，检查是否有满足条件的灵摆区域目标卡
function c28720123.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_PZONE) and chkc~=c and c28720123.spfilter(chkc,e,tp) end
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家灵摆区域是否存在满足条件的目标卡
		and Duel.IsExistingTarget(c28720123.spfilter,tp,LOCATION_PZONE,0,1,c,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的灵摆区域目标卡
	local g=Duel.SelectTarget(tp,c28720123.spfilter,tp,LOCATION_PZONE,0,1,1,c,e,tp)
	-- 设置连锁操作信息，表明将要特殊召唤目标卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理灵摆效果的发动，将目标卡特殊召唤到场上
function c28720123.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断额外卡组中是否含有符合条件的「龙剑士」或「雾动机龙」灵摆怪兽
function c28720123.thfilter(c)
	return c:IsSetCard(0xc7,0xd8) and not c:IsCode(28720123) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsAbleToHand()
end
-- 设置解放效果的发动条件，检查额外卡组中是否存在满足条件的卡
function c28720123.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家额外卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c28720123.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息，表明将要将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 处理解放效果的发动，从额外卡组选择符合条件的卡加入手牌
function c28720123.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从额外卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c28720123.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
