--鉄のハンス
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从卡组把1只「铁骑士」特殊召唤。这个效果的处理时场地区域没有「急流山的金宫」存在的场合，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
-- ②：场地区域有「急流山的金宫」存在的场合，这张卡的攻击力上升自己场上的「铁骑士」数量×1000。
function c41916534.initial_effect(c)
	-- 记录此卡具有「急流山的金宫」这张卡的卡名
	aux.AddCodeList(c,72283691)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从卡组把1只「铁骑士」特殊召唤。这个效果的处理时场地区域没有「急流山的金宫」存在的场合，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41916534,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,41916534)
	e1:SetTarget(c41916534.sptg)
	e1:SetOperation(c41916534.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：场地区域有「急流山的金宫」存在的场合，这张卡的攻击力上升自己场上的「铁骑士」数量×1000。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetCondition(c41916534.atkcon)
	e4:SetValue(c41916534.value)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断卡组中是否存在可特殊召唤的「铁骑士」
function c41916534.filter(c,e,tp)
	return c:IsCode(73405179) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的判断条件，检查是否满足特殊召唤的条件
function c41916534.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家卡组中是否存在至少1张「铁骑士」
		and Duel.IsExistingMatchingCard(c41916534.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行特殊召唤操作并根据场地卡情况设置不能特殊召唤的限制
function c41916534.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只「铁骑士」
		local g=Duel.SelectMatchingCard(tp,c41916534.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的「铁骑士」特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 判断场地区域是否存在「急流山的金宫」
	if not Duel.IsEnvironment(72283691,PLAYER_ALL,LOCATION_FZONE) then
		-- 创建并注册一个限制玩家不能从额外卡组特殊召唤的永续效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c41916534.splimit)
		-- 将效果注册到玩家环境中
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制效果的目标，仅对来自额外卡组的怪兽生效
function c41916534.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 判断场地区域是否存在「急流山的金宫」
function c41916534.atkcon(e)
	-- 判断场地区域是否存在「急流山的金宫」
	return Duel.IsEnvironment(72283691,PLAYER_ALL,LOCATION_FZONE)
end
-- 过滤函数，用于判断场上是否有「铁骑士」
function c41916534.atkfilter(c)
	return c:IsFaceup() and c:IsCode(73405179)
end
-- 计算攻击力提升值，为场上「铁骑士」数量乘以1000
function c41916534.value(e,c)
	-- 计算场上「铁骑士」的数量并乘以1000作为攻击力提升值
	return Duel.GetMatchingGroupCount(c41916534.atkfilter,c:GetControler(),LOCATION_ONFIELD,0,nil)*1000
end
