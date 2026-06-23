--ウィッチクラフト・エーデル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1张魔法卡才能发动。从手卡把「魔女术工匠·宝石女巫」以外的1只「魔女术」怪兽特殊召唤。这个效果在对方回合也能发动。
-- ②：把这张卡解放，以自己墓地1只「魔女术工匠·宝石女巫」以外的魔法师族怪兽为对象才能发动。那只怪兽特殊召唤。
function c58139997.initial_effect(c)
	-- ①：从手卡丢弃1张魔法卡才能发动。从手卡把「魔女术工匠·宝石女巫」以外的1只「魔女术」怪兽特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58139997,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,58139997)
	e1:SetCost(c58139997.spcost)
	e1:SetTarget(c58139997.sptg)
	e1:SetOperation(c58139997.spop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放，以自己墓地1只「魔女术工匠·宝石女巫」以外的魔法师族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58139997,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,58139998)
	e2:SetCost(c58139997.cost)
	e2:SetTarget(c58139997.target)
	e2:SetOperation(c58139997.activate)
	c:RegisterEffect(e2)
end
function c58139997.costfilter(c,tp,res)
	if c:IsLocation(LOCATION_HAND) then return c:IsType(TYPE_SPELL) and c:IsDiscardable() end
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:IsHasEffect(83289866,tp)
		or not c:IsCode(32353566) and c:IsSetCard(0x128)
		and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
		and c:IsLocation(LOCATION_DECK) and res
end
-- 效果①的发动代价：从手卡丢弃1张魔法卡（或利用魔女术相关卡片效果从场上送去墓地）
function c58139997.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local res=Duel.IsPlayerAffectedByEffect(tp,32353566) and e:GetHandler():IsSetCard(0x128)
	if chk==0 then return Duel.IsExistingMatchingCard(c58139997.costfilter,tp,LOCATION_HAND+LOCATION_SZONE+LOCATION_DECK,0,1,nil,tp,res) end
	local g=Duel.GetMatchingGroup(c58139997.costfilter,tp,LOCATION_HAND+LOCATION_SZONE+LOCATION_DECK,0,nil,tp,res)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc:IsLocation(LOCATION_HAND) then
		local te=tc:IsHasEffect(83289866,tp)
		if te then
			te:UseCountLimit(tp)
			Duel.RegisterFlagEffect(tp,tc:GetCode(),RESET_PHASE+PHASE_END,0,1)
		end
		Duel.SendtoGrave(tc,REASON_COST)
	else
		-- 将选中的手牌作为代价丢弃并送去墓地
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- 过滤手卡中除「魔女术工匠·宝石女巫」以外的「魔女术」怪兽
function c58139997.spfilter(c,e,tp)
	return c:IsSetCard(0x128) and not c:IsCode(58139997) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检查（检查怪兽区域空格及手卡中是否存在可特殊召唤的怪兽）
function c58139997.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手卡中是否存在满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c58139997.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理：从手卡特殊召唤1只「魔女术」怪兽
function c58139997.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的「魔女术」怪兽
	local g=Duel.SelectMatchingCard(tp,c58139997.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动代价：把场上的这张卡解放
function c58139997.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤自己墓地中除「魔女术工匠·宝石女巫」以外的魔法师族怪兽
function c58139997.filter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and not c:IsCode(58139997) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：选择墓地的魔法师族怪兽作为对象
function c58139997.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c58139997.filter(chkc,e,tp) end
	-- 检查在这张卡解放离开场上后，自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 并且检查自己墓地中是否存在可作为对象的魔法师族怪兽
		and Duel.IsExistingTarget(c58139997.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1只满足条件的魔法师族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c58139997.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理中的操作信息：特殊召唤指定的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：特殊召唤作为对象的墓地怪兽
function c58139997.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
