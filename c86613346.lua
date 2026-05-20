--ホーリーナイツ・フラムエル
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：对方怪兽的攻击宣言时，把手卡·场上的这张卡送去墓地才能发动。从手卡把1只龙族·光属性·7星怪兽特殊召唤。
-- ②：把墓地的这张卡除外，以自己的场上·墓地1只龙族·光属性·7星怪兽为对象才能发动。那只怪兽回到持有者手卡。这个效果在对方回合也能发动。
function c86613346.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时，把手卡·场上的这张卡送去墓地才能发动。从手卡把1只龙族·光属性·7星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,86613346)
	e1:SetCondition(c86613346.spcon)
	e1:SetCost(c86613346.spcost)
	e1:SetTarget(c86613346.sptg)
	e1:SetOperation(c86613346.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己的场上·墓地1只龙族·光属性·7星怪兽为对象才能发动。那只怪兽回到持有者手卡。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,86613346)
	-- 把墓地的这张卡除外作为发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c86613346.thtg)
	e2:SetOperation(c86613346.thop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件函数
function c86613346.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方（即对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- 效果①的代价过滤与处理函数
function c86613346.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把手卡·场上的这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤手卡中龙族·光属性·7星且能特殊召唤的怪兽
function c86613346.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与目标检查函数
function c86613346.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查这张卡送去墓地后，自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查手卡中是否存在至少1只满足条件的龙族·光属性·7星怪兽
		and Duel.IsExistingMatchingCard(c86613346.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的处理（特殊召唤）函数
function c86613346.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足条件的龙族·光属性·7星怪兽
	local g=Duel.SelectMatchingCard(tp,c86613346.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤场上或墓地中龙族·光属性·7星且能加入手卡的怪兽
function c86613346.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(7)
		and c:IsAbleToHand() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 效果②的发动准备与取对象函数
function c86613346.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and chkc:IsControler(tp) and c86613346.thfilter(chkc) end
	-- 检查自己的场上或墓地是否存在至少1只满足条件的龙族·光属性·7星怪兽
	if chk==0 then return Duel.IsExistingTarget(c86613346.thfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上·墓地1只满足条件的龙族·光属性·7星怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c86613346.thfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil)
	-- 设置返回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理（返回手牌）函数
function c86613346.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适应此效果，且不受王家长眠之谷的影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽送回持有者手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
