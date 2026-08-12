--憑依覚醒－デーモン・リーパー
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡可以把自己场上的表侧表示的1只魔法师族怪兽和1只4星以下的地属性怪兽送去墓地，从手卡·卡组特殊召唤。
-- ②：这张卡的①的方法特殊召唤时才能发动。从自己墓地把1只4星以下的怪兽效果无效特殊召唤。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「地灵术」卡或「凭依」魔法·陷阱卡加入手卡。
function c65268179.initial_effect(c)
	-- ①：这张卡可以把自己场上的表侧表示的1只魔法师族怪兽和1只4星以下的地属性怪兽送去墓地，从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCondition(c65268179.spcon)
	e1:SetTarget(c65268179.sptg)
	e1:SetOperation(c65268179.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的方法特殊召唤时才能发动。从自己墓地把1只4星以下的怪兽效果无效特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65268179,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,65268179)
	e2:SetCondition(c65268179.condition)
	e2:SetTarget(c65268179.sptg1)
	e2:SetOperation(c65268179.spop1)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「地灵术」卡或「凭依」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65268179,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,65268180)
	e3:SetCondition(c65268179.thcon)
	e3:SetTarget(c65268179.thtg)
	e3:SetOperation(c65268179.thop)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示且能作为cost送去墓地的卡片
function c65268179.spfilter1(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 过滤4星以下的地属性怪兽
function c65268179.spfilter2(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevelBelow(4)
end
-- 检查选取的卡片组是否满足怪兽区域空位要求，且包含1只魔法师族怪兽和1只4星以下的地属性怪兽
function c65268179.fselect(g,tp)
	-- 检查怪兽区域空位，并利用gffcheck验证卡片组是否由1只魔法师族怪兽和1只满足spfilter2（4星以下地属性）的怪兽组成
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,Card.IsRace,RACE_SPELLCASTER,c65268179.spfilter2,nil)
end
-- 特殊召唤规则的Condition函数，判断场上是否存在满足特殊召唤条件的怪兽组合
function c65268179.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有表侧表示且能送去墓地的怪兽
	local g=Duel.GetMatchingGroup(c65268179.spfilter1,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c65268179.fselect,2,2,tp)
end
-- 特殊召唤规则的Target函数，让玩家选择用于特殊召唤的2只怪兽，并将其保存在LabelObject中
function c65268179.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有表侧表示且能送去墓地的怪兽
	local g=Duel.GetMatchingGroup(c65268179.spfilter1,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c65268179.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的Operation函数，将选定的怪兽送去墓地以完成特殊召唤
function c65268179.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽作为特殊召唤的素材送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 效果②的发动条件，判断此卡是否通过自身①的方法特殊召唤成功
function c65268179.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤墓地中可以特殊召唤的4星以下怪兽
function c65268179.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的Target函数，检查怪兽区域空位并确认墓地中是否存在可特殊召唤的怪兽，设置特殊召唤的操作信息
function c65268179.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在至少1只满足条件的4星以下怪兽
		and Duel.IsExistingMatchingCard(c65268179.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的Operation函数，从墓地选择1只4星以下怪兽，将其效果无效并特殊召唤
function c65268179.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有可用的怪兽区域空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地选择1只满足条件且不受王家长眠之谷影响的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c65268179.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选择怪兽，则尝试以表侧表示进行特殊召唤的单步处理
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 效果③的发动条件，判断此卡是否从场上送去墓地
function c65268179.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中属于「地灵术」魔法·陷阱卡或「凭依」魔法·陷阱卡的卡片
function c65268179.thfilter(c)
	return ((c:IsSetCard(0xc0) and c:IsType(TYPE_SPELL+TYPE_TRAP)) or c:IsSetCard(0x314c)) and c:IsAbleToHand()
end
-- 效果③的Target函数，确认卡组中是否存在可检索的卡片，并设置检索的操作信息
function c65268179.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己卡组中是否存在至少1张满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c65268179.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手牌的操作信息，表示将从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的Operation函数，从卡组选择1张「地灵术」卡或「凭依」魔法·陷阱卡加入手牌
function c65268179.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,c65268179.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选取的卡片通过效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
