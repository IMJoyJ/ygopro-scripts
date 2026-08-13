--アルグールマゼラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的不死族怪兽被战斗·效果破坏的场合，可以作为代替把手卡·墓地的这张卡除外。
-- ②：这张卡从手卡·墓地除外的场合才能发动。这张卡守备表示特殊召唤。那之后，可以让这张卡的等级下降1星。
local s,id,o=GetID()
-- 初始化效果：创建并注册①的代替破坏除外效果和②的除外时特殊召唤效果，并分别设置1回合1次限制。
function c45154513.initial_effect(c)
	-- ①：自己场上的不死族怪兽被战斗·效果破坏的场合，可以作为代替把手卡·墓地的这张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,45154513)
	e1:SetTarget(c45154513.reptg)
	e1:SetValue(c45154513.repval)
	e1:SetOperation(c45154513.repop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·墓地除外的场合才能发动。这张卡守备表示特殊召唤。那之后，可以让这张卡的等级下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,45154513+o)
	e2:SetCondition(c45154513.spcon)
	e2:SetTarget(c45154513.sptg)
	e2:SetOperation(c45154513.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断一只怪兽是否为“自己场上被战斗/效果破坏的不死族怪兽”且不属于代替破坏（用于决定是否可被本卡代替）。
function c45154513.repfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- ①效果的发动条件判定与发动选择：先确认本卡可除外且存在满足条件的不死族怪兽；需要发动时，让玩家选择是否发动。
function c45154513.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c45154513.repfilter,1,nil,tp) end
	-- 让玩家选择是否发动①代替破坏效果（使用编号96的提示文本）。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏判定：破坏的怪兽若符合repfilter条件则返回真，允许用本卡代替其破坏。
function c45154513.repval(e,c)
	return c45154513.repfilter(c,e:GetHandlerPlayer())
end
-- ①效果处理：将本卡从手卡或墓地除外，以代替那些不死族怪兽的破坏。
function c45154513.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡以表侧表示除外，原因记为效果和代替破坏。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
-- ②效果发动条件：这张卡是从手卡或墓地除外时（之前位于手牌或墓地）。
function c45154513.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果的发动检查：确认自己的主要怪兽区有空位，并且本卡可以表侧守备表示特殊召唤。
function c45154513.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己的主要怪兽区是否有可用空格（作为特殊召唤的前提）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息，声明本次效果包含特殊召唤，以便系统正确检测相关连锁。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：将本卡表侧守备表示特殊召唤；若特殊召唤成功，则询问玩家是否让等级下降1星，选择是则应用等级下降效果。
function c45154513.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认本卡仍与效果关联且特殊召唤成功（避免特殊召唤被无效或本卡已离场的场合继续处理）。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0
		-- 询问玩家是否让这张卡的等级下降1星（使用卡片第0个效果提示文本）。
		and Duel.SelectYesNo(tp,aux.Stringid(45154513,0)) then  --"是否下降等级？"
		-- 中断当前效果处理，使后续的等级下降效果错开时点处理（避免影响特殊召唤成功时的时点）。
		Duel.BreakEffect()
		-- 那之后，可以让这张卡的等级下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-1)
		c:RegisterEffect(e1)
	end
end
