--タロンズ・オブ・シュリーレン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：对方回合，以「纹影魔爪」以外的自己场上1只恶魔族·幻想魔族怪兽为对象才能发动。那只怪兽回到手卡，这张卡从手卡特殊召唤。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ③：自己的卡为对象的效果由对方发动时，以对方场上1只怪兽为对象才能发动。场上的这张卡回到手卡，那只怪兽破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册①手卡特召/回手、②战斗不破、③对象应对破坏三个效果
function s.initial_effect(c)
	-- ①：对方回合，以「纹影魔爪」以外的自己场上1只恶魔族·幻想魔族怪兽为对象才能发动。那只怪兽回到手卡，这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己的卡为对象的效果由对方发动时，以对方场上1只怪兽为对象才能发动。场上的这张卡回到手卡，那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件函数：必须在对方回合才能发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果①的对象怪兽过滤条件：自己场上表侧表示的「纹影魔爪」以外的恶魔族·幻想魔族怪兽，且能回到手卡，并且其离开后有可用的怪兽区域
function s.spfilter(c,tp)
	return not c:IsCode(id) and c:IsRace(RACE_FIEND+RACE_ILLUSION) and c:IsFaceup() and c:IsAbleToHand()
		-- 判定该怪兽离开场上后，自己场上是否有可用的怪兽区域用于特殊召唤
		and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①的发动准备与对象选择：判定自身能否特殊召唤以及场上是否存在符合条件的怪兽，并选择该怪兽作为对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.spfilter(chkc,tp) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判定自己场上是否存在至少1只满足条件的恶魔族或幻想魔族怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要返回手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置连锁处理信息：将选择的对象怪兽送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置连锁处理信息：将手卡的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理：将对象怪兽送回手卡，若成功回到手卡，则将这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽是否仍对应连锁且为怪兽，并将其送回手卡，确认是否成功送回
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND) and c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的适用对象判定：适用于这张卡自身以及与这张卡进行战斗的对方怪兽
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 效果③的发动条件函数：对方发动了以自己场上的卡为对象的效果
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取对方发动效果时所选择的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return rp==1-tp and tg and tg:IsExists(Card.IsControler,1,nil,tp)
end
-- 效果③的发动准备与对象选择：判定自身能否回到手卡以及对方场上是否存在怪兽，并选择对方场上1只怪兽作为破坏的对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and c:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 判定自身是否能回到手卡，且对方场上是否存在可以作为对象的怪兽
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理信息：破坏选择的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁处理信息：将场上的这张卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果③的效果处理：将这张卡送回手卡，若成功回到手卡，则将作为对象的对方怪兽破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果③选择的要破坏的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判定这张卡是否仍对应效果，并将其送回手卡，确认是否成功送回
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_HAND) then
		if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
			-- 将作为对象的对方怪兽破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
