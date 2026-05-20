--白の聖女エクレシア
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，这张卡可以从手卡特殊召唤。
-- ②：自己·对方的主要阶段，把这张卡解放才能发动。从手卡·卡组把1只「相剑」怪兽或「阿不思的落胤」特殊召唤。
-- ③：这个回合有融合怪兽被送去自己墓地的场合，结束阶段才能发动。墓地的这张卡加入手卡。
function c55273560.initial_effect(c)
	-- 注册该卡片记载了「阿不思的落胤」（卡号68468459）的事实。
	aux.AddCodeList(c,68468459)
	-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,55273560+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c55273560.sspcon)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，把这张卡解放才能发动。从手卡·卡组把1只「相剑」怪兽或「阿不思的落胤」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55273560,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,55273561)
	e2:SetCondition(c55273560.spcon)
	e2:SetCost(c55273560.spcost)
	e2:SetTarget(c55273560.sptg)
	e2:SetOperation(c55273560.spop)
	c:RegisterEffect(e2)
	-- ③：这个回合有融合怪兽被送去自己墓地的场合，结束阶段才能发动。墓地的这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(55273560,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1,55273562)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(c55273560.thcon)
	e3:SetTarget(c55273560.thtg)
	e3:SetOperation(c55273560.thop)
	c:RegisterEffect(e3)
	if not c55273560.global_check then
		c55273560.global_check=true
		-- 这个回合有融合怪兽被送去自己墓地的场合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c55273560.checkop)
		-- 注册全局环境效果，用于检测是否有融合怪兽被送去墓地。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 特殊召唤规则的条件函数：检查自己场上是否有空位，且对方场上的怪兽数量是否比自己场上的怪兽多。
function c55273560.sspcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域空格。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查对方场上的怪兽数量是否比自己场上的怪兽数量多。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)<Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)
end
-- 效果②的发动条件函数：必须在自己或对方的主要阶段。
function c55273560.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果②的发动代价函数：检查并解放自身。
function c55273560.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果②的过滤函数：筛选手卡或卡组中可以特殊召唤的「相剑」怪兽或「阿不思的落胤」。
function c55273560.spfilter(c,e,tp)
	return (c:IsSetCard(0x16b) or c:IsCode(68468459)) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动目标函数：检查怪兽区域空格，并确认手卡或卡组中是否存在可特殊召唤的怪兽，然后设置特殊召唤的操作信息。
function c55273560.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在解放这张卡后，自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查手卡或卡组中是否存在至少1只满足过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(c55273560.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为：从手卡或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的效果处理函数：从手卡或卡组选择1只满足条件的怪兽特殊召唤。
function c55273560.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送选择特殊召唤卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c55273560.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 全局检测过滤函数：筛选送去墓地的卡是否为自己场上送去自己墓地的融合怪兽。
function c55273560.checkfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsControler(tp)
end
-- 全局检测处理函数：若有融合怪兽被送去墓地，则为对应玩家注册一个回合结束前有效的标识效果。
function c55273560.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 若有融合怪兽被送去玩家0的墓地，则为玩家0注册一个回合结束前有效的标识效果。
	if eg:IsExists(c55273560.checkfilter,1,nil,0) then Duel.RegisterFlagEffect(0,55273560,RESET_PHASE+PHASE_END,0,1) end
	-- 若有融合怪兽被送去玩家1的墓地，则为玩家1注册一个回合结束前有效的标识效果。
	if eg:IsExists(c55273560.checkfilter,1,nil,1) then Duel.RegisterFlagEffect(1,55273560,RESET_PHASE+PHASE_END,0,1) end
end
-- 效果③的发动条件函数：检查本回合是否有融合怪兽被送去自己墓地。
function c55273560.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己是否拥有融合怪兽送去墓地的标识效果。
	return Duel.GetFlagEffect(tp,55273560)~=0
end
-- 效果③的发动目标函数：检查自身是否可以加入手卡，并设置回收的操作信息。
function c55273560.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁处理中的操作信息为：将墓地的这张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果③的效果处理函数：将墓地的这张卡加入手卡。
function c55273560.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
