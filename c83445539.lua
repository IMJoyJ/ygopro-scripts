--ダークネス・リゾネーター
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把额外卡组1只「红莲魔龙」给对方观看才能发动。这张卡从手卡特殊召唤。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「共鸣者」怪兽召唤。
-- ③：以自己场上的调整任意数量为对象才能发动。那些怪兽的等级变成1星。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含效果①、效果②和效果③的注册。
function s.initial_effect(c)
	-- 将「红莲魔龙」（卡号70902743）加入该卡的关联卡片密码列表中。
	aux.AddCodeList(c,70902743)
	-- ①：把额外卡组1只「红莲魔龙」给对方观看才能发动。这张卡从手卡特殊召唤。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「共鸣者」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"追加召唤"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
	-- ③：以自己场上的调整任意数量为对象才能发动。那些怪兽的等级变成1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"改变等级"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
end
-- 过滤条件：额外卡组中未给对方观看的「红莲魔龙」。
function s.cfilter(c)
	return c:IsCode(70902743) and not c:IsPublic()
end
-- 效果①的发动代价（Cost）处理函数：从额外卡组将1只「红莲魔龙」给对方观看。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以给对方观看的「红莲魔龙」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要确认（给对方观看）的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择额外卡组中1只满足条件的「红莲魔龙」。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选中的卡片给对方玩家确认（观看）。
	Duel.ConfirmCards(1-tp,g)
end
-- 效果①的发动检测（Target）处理函数：检查自身是否能特殊召唤并设置操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息为：特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（Operation）函数：特殊召唤自身，并适用“不是同调怪兽不能从额外卡组特殊召唤”的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。/②：这张卡特殊召唤的场合才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「共鸣者」怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该玩家受到的额外卡组特殊召唤限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能从额外卡组特殊召唤同调怪兽以外的怪兽。
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果②的发动检测（Target）处理函数：检查玩家是否能进行通常召唤、是否已获得追加召唤效果，以及当前是否为自己的回合。
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以进行通常召唤，以及是否可以获得追加召唤次数。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
		-- 检查本回合是否尚未适用过该追加召唤效果，且当前是自己的回合。
		and Duel.GetFlagEffect(tp,id)==0 and Duel.GetTurnPlayer()==tp end
end
-- 效果②的效果处理（Operation）函数：为玩家注册本回合可以追加召唤1只「共鸣者」怪兽的效果。
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查并确保本回合没有重复适用该追加召唤效果。
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	-- 这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「共鸣者」怪兽召唤。/③：以自己场上的调整任意数量为对象才能发动。那些怪兽的等级变成1星。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))  --"使用「暗冥共鸣者」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置追加召唤的限制对象为「共鸣者」怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x57))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册追加召唤效果给玩家。
	Duel.RegisterEffect(e1,tp)
	-- 给玩家注册一个回合结束前有效的标记，用于记录本回合已适用过该追加召唤效果。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤条件：自己场上表侧表示且等级在2星以上的调整怪兽。
function s.lvfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsLevelAbove(2) and c:IsFaceup()
end
-- 效果③的发动检测与对象选择（Target）处理函数：选择自己场上任意数量的调整怪兽作为效果对象。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	-- 检查自己场上是否存在至少1只满足条件的调整怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1到6只满足条件的调整怪兽作为效果对象。
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,6,nil)
end
-- 过滤条件：仍存在于场上、表侧表示且等级在2星以上的怪兽。
function s.lvopfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(2)
end
-- 效果③的效果处理（Operation）函数：将作为对象的怪兽的等级变成1星。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理时仍与该效果关联且满足过滤条件的对象怪兽。
	local g=Duel.GetTargetsRelateToChain():Filter(s.lvopfilter,nil)
	-- 遍历所有符合条件的对象怪兽。
	for tc in aux.Next(g) do
		-- 那些怪兽的等级变成1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
