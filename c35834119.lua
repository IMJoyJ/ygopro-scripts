--灯魚
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡作为同调素材送去墓地的场合才能发动。在自己场上把2只「灯衍生物」（鱼族·炎·2星·攻/守0）特殊召唤。这个回合，自己不是鱼族怪兽不能从额外卡组特殊召唤。
-- ②：自己场上有鱼族同调怪兽存在的场合，把墓地的这张卡除外，以场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 注册卡牌的初始化效果，设置同调召唤程序并启用复活限制
function s.initial_effect(c)
	-- 为卡牌添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为同调素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡作为同调素材送去墓地的场合才能发动。在自己场上把2只「灯衍生物」（鱼族·炎·2星·攻/守0）特殊召唤。这个回合，自己不是鱼族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤衍生物"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有鱼族同调怪兽存在的场合，把墓地的这张卡除外，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	-- 设置效果发动的费用为将此卡从墓地除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否作为同调素材被送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 检测是否满足特殊召唤衍生物的条件，包括未受青眼精灵龙效果影响、场上空位足够、可以特殊召唤衍生物
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测场上是否有至少2个空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,35834120,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FISH,ATTRIBUTE_FIRE) end
	-- 设置操作信息为将要特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息为将要特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 执行特殊召唤衍生物的操作，包括设置不能特殊召唤非鱼族怪兽的效果、检查条件并特殊召唤衍生物
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置一个场上的效果，禁止非鱼族怪兽从额外卡组特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到场上
	Duel.RegisterEffect(e1,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检测场上是否有至少2个空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 检测是否可以特殊召唤衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,35834120,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FISH,ATTRIBUTE_FIRE) then return end
	for i=1,2 do
		-- 创建一只衍生物
		local token=Duel.CreateToken(tp,id+o)
		-- 将衍生物特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成特殊召唤步骤
	Duel.SpecialSummonComplete()
end
-- 设置禁止非鱼族怪兽从额外卡组特殊召唤的效果目标
function s.splimit(e,c)
	return not c:IsRace(RACE_FISH) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤场上存在的鱼族同调怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH) and c:IsType(TYPE_SYNCHRO)
end
-- 判断场上是否存在鱼族同调怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在鱼族同调怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置破坏效果的目标选择逻辑
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检测场上是否存在至少1张可破坏的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为将要破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果，将目标卡破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
