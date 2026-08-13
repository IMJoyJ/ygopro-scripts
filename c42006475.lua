--守護神官マナ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，只以自己场上的魔法师族怪兽1只为对象的对方的魔法·陷阱·怪兽的效果发动时才能发动。这张卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己场上的7星以上的魔法师族怪兽不会被效果破坏。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己的手卡·卡组·墓地选1只「黑魔术少女」特殊召唤。
function c42006475.initial_effect(c)
	-- 将该卡上记载的卡名「黑魔术少女」（卡号38033121）登记到辅助信息中，便于以后进行关联判断。
	aux.AddCodeList(c,38033121)
	-- 「这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡·墓地存在，只以自己场上的魔法师族怪兽1只为对象的对方的魔法·陷阱·怪兽的效果发动时才能发动。这张卡特殊召唤。」
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42006475,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,42006475)
	e1:SetCondition(c42006475.spcon)
	e1:SetTarget(c42006475.sptg)
	e1:SetOperation(c42006475.spop)
	c:RegisterEffect(e1)
	-- 「②：只要这张卡在怪兽区域存在，自己场上的7星以上的魔法师族怪兽不会被效果破坏。」
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c42006475.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 「③：这张卡被战斗·效果破坏的场合才能发动。从自己的手卡·卡组·墓地选1只「黑魔术少女」特殊召唤。」
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c42006475.spcon2)
	e3:SetTarget(c42006475.sptg2)
	e3:SetOperation(c42006475.spop2)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡片是否为表侧表示、由tp玩家控制、位于主要怪兽区域且种族为魔法师族，用于识别“自己场上的魔法师族怪兽”。
function c42006475.tfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_SPELLCASTER)
end
-- 效果①的发动条件：仅当对方玩家发动取对象效果且该效果以自己场上1只魔法师族怪兽为对象时，本卡才可发动；同时确认该连锁的对象组恰好包含1只满足tfilter的怪兽。
function c42006475.spcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁（编号ev）的效果处理中确定的对象卡组，用于后续检查对象是否为符合条件的魔法师族怪兽。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:GetCount()==1 and g:IsExists(c42006475.tfilter,1,nil,tp)
end
-- 效果①发动时点合法检测：确认自己主要怪兽区有空位，且此卡自身能够被特殊召唤（不跳过召唤条件与苏生限制的检查）。
function c42006475.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用的空格，防止特殊召唤时无格可召。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，向系统声明本连锁将执行特殊召唤（对象为此卡，数量为1，控制者/位置暂不指定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①处理：取得此卡；若此卡仍与当前效果保持关联（未因离场等原因失效），则将其特殊召唤。
function c42006475.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤到自己场上（sumtype=0，不跳过召唤条件和苏生限制检查）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的适用对象判定：该怪兽必须是魔法师族且等级为7星以上，满足条件者获得“不会被效果破坏”的适用。
function c42006475.indtg(e,c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(7)
end
-- 效果③的发动条件：此卡被破坏，且破坏原因包含战斗破坏或效果破坏。
function c42006475.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 特殊召唤对象过滤器：卡名必须是「黑魔术少女」（38033121），并且可以被当前效果特殊召唤。
function c42006475.spfilter(c,e,tp)
	return c:IsCode(38033121) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③发动时点合法检测：自己主要怪兽区有空位，并且从手卡·卡组·墓地存在至少1张可特殊召唤的「黑魔术少女」。
function c42006475.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空格，作为效果③能否发动的条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡·卡组·墓地中是否存在至少1张符合条件的「黑魔术少女」，作为效果③能否发动的条件之一。
		and Duel.IsExistingMatchingCard(c42006475.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，声明本连锁将执行特殊召唤；对象在处理时选择，数量1，来源为持有者的手卡·卡组·墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果③处理：先确认自己主要怪兽区仍有空格；给出选择提示，让玩家从手卡·卡组·墓地选择1张符合条件的「黑魔术少女」（经过王家长眠之谷的过滤）并特殊召唤。
function c42006475.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若主要怪兽区没有空格，则直接终止处理流程，不进行后续的检索与特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 发送选择卡片提示，提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从玩家的手卡·卡组·墓地中选择1张符合条件的「黑魔术少女」，并使用aux.NecroValleyFilter过滤掉受王家长眠之谷影响无法特殊召唤的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c42006475.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「黑魔术少女」以表侧表示特殊召唤到玩家自己的怪兽区域。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
