--夢魔鏡の黒騎士－ルペウス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：场地区域有「圣光之梦魔镜」存在的场合，自己·对方的主要阶段以及战斗阶段，把这张卡解放才能发动。从卡组把1只「梦魔镜的白骑士-卢甫斯」特殊召唤。
function c38267552.initial_effect(c)
	-- 将本卡记载的卡名「梦魔镜的白骑士-卢甫斯」（1872843）以及「圣光之梦魔镜」（74665651）加入代码列表，供后续判定是否具有相关卡名信息时使用。
	aux.AddCodeList(c,74665651,1872843)
	-- ①：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38267552,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,38267552)
	e1:SetCondition(c38267552.descon)
	e1:SetTarget(c38267552.destg)
	e1:SetOperation(c38267552.desop)
	c:RegisterEffect(e1)
	-- ②：场地区域有「圣光之梦魔镜」存在的场合，自己·对方的主要阶段以及战斗阶段，把这张卡解放才能发动。从卡组把1只「梦魔镜的白骑士-卢甫斯」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38267552,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,38267553)
	e2:SetCondition(c38267552.spcon)
	e2:SetCost(c38267552.spcost)
	e2:SetTarget(c38267552.sptg)
	e2:SetOperation(c38267552.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：本卡是用「梦魔镜」怪兽的效果特殊召唤成功，即记载了本次特殊召唤的召唤信息中类型为怪兽且特殊召唤的来源卡组名包含「梦魔镜」（0x131）时，条件成立。
function c38267552.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x131)
end
-- ①效果的发动时点与对象选择：满足发动条件后，选择场上1张卡作为对象；若选择到的卡的合法性检查通过，则选定该对象并写入破坏相关的操作信息。
function c38267552.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- ①效果的发动合法性检查：场上存在至少1张可以被选择为对象的卡（我方或对方的场上区域均可）。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示选择提示，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家从双方场上选择1张卡作为效果对象，并将其与本连锁效果关联。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 将本次连锁处理中要执行的操作信息登记为“破坏1张卡”，所需的破坏对象即为已选择的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理：取得效果对象，若该对象仍与效果相关（未离开过场上或未失去联系），则将其破坏。
function c38267552.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中最初选择的1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 用效果原因将对象卡破坏送去墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②效果的发动条件：当前阶段为双方主要阶段或战斗阶段，且场地区域存在「圣光之梦魔镜」。
function c38267552.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否处于可以发动②效果的阶段。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
		-- 检查场地区域是否存在卡号74665651（圣光之梦魔镜），任意玩家均可。
		and Duel.IsEnvironment(74665651,PLAYER_ALL,LOCATION_FZONE)
end
-- ②效果的发动代价：将这张卡自身解放作为发动代价；发动前确认这张卡可以解放。
function c38267552.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将效果的处理者（这张卡自身）解放，作为发动②效果所需的COST。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ②效果的特殊召唤对象的筛选条件：卡号为1872843（「梦魔镜的白骑士-卢甫斯」），并且能够被当前效果特殊召唤。
function c38267552.spfilter(c,e,tp)
	return c:IsCode(1872843) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动合法性检查：我方怪兽区域有空位，且卡组中存在满足特殊召唤条件的「梦魔镜的白骑士-卢甫斯」。
function c38267552.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②效果的发动合法性检查之一：我方场上解放这张卡后仍有可用的怪兽区空格。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- ②效果的发动合法性检查之二：卡组中存在1只满足特殊召唤条件的「梦魔镜的白骑士-卢甫斯」。
		and Duel.IsExistingMatchingCard(c38267552.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次连锁处理中要执行的操作信息登记为“从卡组特殊召唤1只怪兽”，对象卡在处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：若我方怪兽区域仍有空位，则从卡组选择1只「梦魔镜的白骑士-卢甫斯」特殊召唤到场上。
function c38267552.spop(e,tp,eg,ep,ev,re,r,rp)
	-- ②效果处理时再次确认我方怪兽区是否有空位，若没有则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让当前玩家从卡组选择1张满足spfilter条件的卡（即「梦魔镜的白骑士-卢甫斯」）。
	local g=Duel.SelectMatchingCard(tp,c38267552.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到我方场上，无视召唤条件限制但保留苏生限制检查。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
