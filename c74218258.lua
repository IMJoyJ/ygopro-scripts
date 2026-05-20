--虹の天気模様
-- 效果：
-- ①：「虹之天气模样」在自己场上只能有1张表侧表示存在。
-- ②：和这张卡相同纵列的自己的主要怪兽区域以及那些两邻的自己的主要怪兽区域存在的「天气」效果怪兽得到以下效果。
-- ●对方场上有怪兽存在的场合，把这张卡除外才能发动。从卡组把和这张卡卡名不同的1只「天气」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不能从卡组把怪兽特殊召唤。这个效果在对方回合也能发动。
function c74218258.initial_effect(c)
	c:SetUniqueOnField(1,0,74218258)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ●对方场上有怪兽存在的场合，把这张卡除外才能发动。从卡组把和这张卡卡名不同的1只「天气」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不能从卡组把怪兽特殊召唤。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74218258,0))  --"从卡组特殊召唤（虹之天气模样）"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c74218258.spcon)
	-- 把这张卡除外作为发动的代价（Cost）
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c74218258.sptg)
	e2:SetOperation(c74218258.spop)
	-- ②：和这张卡相同纵列的自己的主要怪兽区域以及那些两邻的自己的主要怪兽区域存在的「天气」效果怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c74218258.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 过滤得到效果的怪兽：必须是自己主要怪兽区域的「天气」效果怪兽，且在与这张卡相同纵列或相邻纵列
function c74218258.eftg(e,c)
	local seq=c:GetSequence()
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(0x109)
		and seq<5 and math.abs(e:GetHandler():GetSequence()-seq)<=1
end
-- 得到效果的怪兽发动特殊召唤效果的条件判定函数
function c74218258.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定对方场上是否存在怪兽
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 过滤卡组中与自身卡名不同且可以特殊召唤的「天气」怪兽
function c74218258.spfilter(c,e,tp,code)
	return c:IsSetCard(0x109) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与合法性检测函数
function c74218258.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否有可用的怪兽区域（因为自身作为Cost除外，所以可用格子数需要大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在至少1只满足过滤条件的「天气」怪兽
		and Duel.IsExistingMatchingCard(c74218258.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,e:GetHandler():GetCode()) end
	-- 向对方玩家提示选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置当前连锁的操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的执行函数，并在之后对玩家施加不能从卡组特殊召唤怪兽的限制
function c74218258.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只与自身卡名不同的「天气」怪兽
		local g=Duel.SelectMatchingCard(tp,c74218258.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetHandler():GetCode())
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不能从卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c74218258.splimit)
	-- 将不能从卡组特殊召唤怪兽的限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的来源区域为卡组的判定函数
function c74218258.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_DECK)
end
