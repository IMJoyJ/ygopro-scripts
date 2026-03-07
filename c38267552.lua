--夢魔鏡の黒騎士－ルペウス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：场地区域有「圣光之梦魔镜」存在的场合，自己·对方的主要阶段以及战斗阶段，把这张卡解放才能发动。从卡组把1只「梦魔镜的白骑士-卢甫斯」特殊召唤。
function c38267552.initial_effect(c)
	-- 注册此卡为「梦魔镜」怪兽的卡片，用于效果判定
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
-- 判断此卡是否由「梦魔镜」怪兽的效果特殊召唤成功
function c38267552.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x131)
end
-- 选择场上1张卡作为破坏对象
function c38267552.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在至少1张可作为破坏对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，确定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果
function c38267552.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断是否满足②效果发动条件
function c38267552.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
		-- 检查场地区域是否存在「圣光之梦魔镜」
		and Duel.IsEnvironment(74665651,PLAYER_ALL,LOCATION_FZONE)
end
-- 设置②效果的解放费用
function c38267552.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡解放作为②效果的费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义用于筛选「梦魔镜的白骑士-卢甫斯」的过滤函数
function c38267552.spfilter(c,e,tp)
	return c:IsCode(1872843) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置②效果的发动条件
function c38267552.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有可用怪兽区
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查卡组中是否存在「梦魔镜的白骑士-卢甫斯」
		and Duel.IsExistingMatchingCard(c38267552.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，确定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行②效果的特殊召唤
function c38267552.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有可用怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只「梦魔镜的白骑士-卢甫斯」
	local g=Duel.SelectMatchingCard(tp,c38267552.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
