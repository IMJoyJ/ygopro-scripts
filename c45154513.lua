--アルグールマゼラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的不死族怪兽被战斗·效果破坏的场合，可以作为代替把手卡·墓地的这张卡除外。
-- ②：这张卡从手卡·墓地除外的场合才能发动。这张卡守备表示特殊召唤。那之后，可以让这张卡的等级下降1星。
local s,id,o=GetID()
-- 注册两个效果：①代替破坏的效果和②从墓地除外时特殊召唤的效果
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
-- 用于判断是否满足代替破坏条件的过滤器函数，检查目标怪兽是否为正面表示的不死族怪兽且处于场上且因效果或战斗破坏
function c45154513.repfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的发动判断函数，检查是否满足发动条件并询问玩家是否发动
function c45154513.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c45154513.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏效果的值函数，返回是否满足代替破坏条件
function c45154513.repval(e,c)
	return c45154513.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的处理函数，将该卡以效果和代替原因除外
function c45154513.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将该卡以效果和代替原因除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
-- 特殊召唤效果的发动条件函数，检查该卡是否从手卡或墓地被除外
function c45154513.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_GRAVE)
end
-- 特殊召唤效果的目标设定函数，检查是否有足够的召唤区域并判断该卡是否可以特殊召唤
function c45154513.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数，将该卡特殊召唤并询问是否下降等级
function c45154513.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否可以特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0
		-- 询问玩家是否下降等级
		and Duel.SelectYesNo(tp,aux.Stringid(45154513,0)) then  --"是否下降等级？"
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 等级下降效果的设置函数，使该卡等级减少1星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-1)
		c:RegisterEffect(e1)
	end
end
