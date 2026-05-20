--スケアクロー・クシャトリラ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤，从自己的手卡·墓地选1张「俱舍怒威族」卡或者「恐吓爪牙族」卡除外。
-- ②：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
-- ③：自己的「俱舍怒威族」怪兽或者「恐吓爪牙族」怪兽和对方怪兽进行战斗的场合，直到回合结束时那只对方怪兽的效果无效化。
local s,id,o=GetID()
-- 初始化函数，注册卡片的所有效果
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤，从自己的手卡·墓地选1张「俱舍怒威族」卡或者「恐吓爪牙族」卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DEFENSE_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己的「俱舍怒威族」怪兽或者「恐吓爪牙族」怪兽和对方怪兽进行战斗的场合，直到回合结束时那只对方怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	-- ③：自己的「俱舍怒威族」怪兽或者「恐吓爪牙族」怪兽和对方怪兽进行战斗的场合，直到回合结束时那只对方怪兽的效果无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DISABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetTarget(s.distg)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_DISABLE_EFFECT)
	e6:SetValue(RESET_TURN_SET)
	c:RegisterEffect(e6)
end
-- 效果①的发动条件：自己或对方的主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤自身以外的手卡·墓地的「俱舍怒威族」卡或「恐吓爪牙族」卡
function s.rmfilter(c)
	return c:IsSetCard(0x189,0x17a) and c:IsAbleToRemove()
end
-- 效果①的发动准备与合法性检测
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查手卡或墓地是否存在除这张卡以外可除外的「俱舍怒威族」卡或「恐吓爪牙族」卡
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c) end
	-- 设置特殊召唤的操作信息，表示将特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置除外的操作信息，表示将从手卡或墓地除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的处理：特殊召唤自身并除外1张卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e)
		-- 将这张卡表侧表示特殊召唤，若特殊召唤成功则继续处理
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家从手卡或墓地选择1张满足条件的卡（受王家长眠之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			-- 将选中的卡表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 战斗发生时，立即刷新场上卡片的状态以应用无效化效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 立即刷新场上受到此卡影响的卡片的无效状态
	Duel.AdjustInstantly(e:GetHandler())
end
-- 过滤进行战斗的自己的表侧表示「俱舍怒威族」怪兽或「恐吓爪牙族」怪兽
function s.disfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x189,0x17a) and c:IsControler(tp)
end
-- 确定需要无效化的对方怪兽，并在其上注册标记以持续到回合结束
function s.distg(e,c)
	local fid=e:GetHandler():GetFieldID()
	for _,flag in ipairs({c:GetFlagEffectLabel(id)}) do
		if flag==fid then return true end
	end
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and bc and s.disfilter(bc,e:GetHandlerPlayer()) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		return true
	end
	return false
end
