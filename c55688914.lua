--VS プルトンHG
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。
-- ①：对方回合，自己的主要怪兽区域的怪兽不存在的场合或者只有「征服斗魂」怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。
-- ●炎：这张卡的守备力直到回合结束时上升3000。
-- ●暗·地：这张卡的攻击力直到回合结束时上升3000。
function c55688914.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。①：对方回合，自己的主要怪兽区域的怪兽不存在的场合或者只有「征服斗魂」怪兽的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55688914,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,55688914)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c55688914.spcon)
	e1:SetTarget(c55688914.sptg)
	e1:SetOperation(c55688914.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。●炎：这张卡的守备力直到回合结束时上升3000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55688914,1))  --"展示炎属性的怪兽"
	e2:SetCategory(CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,55688915)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果只能在非伤害步骤或伤害计算前发动的限制条件
	e2:SetCondition(aux.dscon)
	e2:SetCost(c55688914.defcost)
	e2:SetTarget(c55688914.deftg)
	e2:SetOperation(c55688914.defop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。●暗·地：这张卡的攻击力直到回合结束时上升3000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(55688914,2))  --"展示暗·地属性的怪兽"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,55688915)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果只能在非伤害步骤或伤害计算前发动的限制条件
	e3:SetCondition(aux.dscon)
	e3:SetCost(c55688914.atkcost)
	e3:SetTarget(c55688914.atktg)
	e3:SetOperation(c55688914.atkop)
	c:RegisterEffect(e3)
end
-- 检查卡片是否在主要怪兽区域的过滤函数
function c55688914.spcfilter1(c)
	return c:GetSequence()<5
end
-- 检查卡片是否为主要怪兽区域表侧表示的「征服斗魂」怪兽的过滤函数
function c55688914.spcfilter2(c)
	return c:GetSequence()<5 and c:IsSetCard(0x195) and c:IsFaceup()
end
-- 特殊召唤效果的条件函数：对方回合，且自己主要怪兽区域没有怪兽或者只有「征服斗魂」怪兽
function c55688914.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前回合不是对方回合则不能发动
	if Duel.GetTurnPlayer()~=1-tp then return false end
	-- 获取自己主要怪兽区域的怪兽数量
	local ct1=Duel.GetMatchingGroupCount(c55688914.spcfilter1,tp,LOCATION_MZONE,0,nil)
	-- 获取自己主要怪兽区域表侧表示的「征服斗魂」怪兽数量
	local ct2=Duel.GetMatchingGroupCount(c55688914.spcfilter2,tp,LOCATION_MZONE,0,nil)
	return ct1==0 or ct1==ct2
end
-- 特殊召唤效果的目标函数：进行发动的限制条件与可行性检测
function c55688914.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 若第一阶段检测（chk==0），则检查自己主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 并且确保当前连锁中尚未发动过同名卡的效果
		and Duel.GetFlagEffect(tp,55688914)==0 end
	-- 给玩家注册同名卡连锁标记，限制同一连锁内不能重复发动该系列效果
	Duel.RegisterFlagEffect(tp,55688914,RESET_CHAIN,0,1)
	-- 设置特殊召唤操作的信息，标记将自己特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的执行函数：如果这张卡与连锁相关联，则将其表侧表示特殊召唤
function c55688914.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 手牌中未公开的炎属性怪兽的过滤函数
function c55688914.defcfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsPublic()
end
-- 守备力上升效果的代价函数：从手牌中选择并向对方出示1只炎属性怪兽
function c55688914.defcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若第一阶段检测（chk==0），则检查自己手牌中是否存在可公开的炎属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c55688914.defcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手牌中1只满足条件的炎属性怪兽
	local g=Duel.SelectMatchingCard(tp,c55688914.defcfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽展示给对方确认
	Duel.ConfirmCards(1-tp,g)
	-- 如果自身是「征服斗魂」怪兽，则触发公开手牌怪兽的自定义事件
	if e:GetHandler():IsSetCard(0x195) then Duel.RaiseEvent(g,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0) end
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
end
-- 守备力上升效果的目标函数：进行同一连锁内唯一发动限制的检测与标记
function c55688914.deftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若第一阶段检测（chk==0），则检查当前连锁是否未发动过同名卡效果
	if chk==0 then return Duel.GetFlagEffect(tp,55688914)==0 end
	-- 给玩家注册同名卡连锁标记，限制同一连锁内不能重复发动该系列效果
	Duel.RegisterFlagEffect(tp,55688914,RESET_CHAIN,0,1)
end
-- 守备力上升效果的执行函数：如果这张卡在场上，则使其防守力上升3000点直到回合结束
function c55688914.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- ●炎：这张卡的守备力直到回合结束时上升3000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetValue(3000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 手牌中未公开的暗属性或地属性怪兽的过滤函数
function c55688914.atkcfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_DARK) and not c:IsPublic()
end
-- 攻击力上升效果的代价函数：从手牌中选择并向对方出示地属性与暗属性怪兽各1只
function c55688914.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手牌中未公开的暗属性及地属性怪兽的集合
	local g=Duel.GetMatchingGroup(c55688914.atkcfilter,tp,LOCATION_HAND,0,nil)
	-- 若第一阶段检测（chk==0），则检查手牌中是否存在暗属性与地属性怪兽各1只的组合
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_EARTH,ATTRIBUTE_DARK) end
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手牌中暗属性与地属性怪兽各1只的组合
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_EARTH,ATTRIBUTE_DARK)
	-- 将选中的怪兽展示给对方确认
	Duel.ConfirmCards(1-tp,sg)
	-- 如果自身是「征服斗魂」怪兽，则触发公开手牌怪兽的自定义事件
	if e:GetHandler():IsSetCard(0x195) then Duel.RaiseEvent(sg,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0) end
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
end
-- 攻击力上升效果的目标函数：进行同一连锁内唯一发动限制的检测与标记
function c55688914.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若第一阶段检测（chk==0），则检查当前连锁是否未发动过同名卡效果
	if chk==0 then return Duel.GetFlagEffect(tp,55688914)==0 end
	-- 给玩家注册同名卡连锁标记，限制同一连锁内不能重复发动该系列效果
	Duel.RegisterFlagEffect(tp,55688914,RESET_CHAIN,0,1)
end
-- 攻击力上升效果的执行函数：如果这张卡在场上，则使其攻击力上升3000点直到回合结束
function c55688914.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- ●暗·地：这张卡的攻击力直到回合结束时上升3000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(3000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
