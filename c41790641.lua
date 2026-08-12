--エレキングダム
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方不能把位于这张卡以及自己场上的「电气」怪兽的正对面的对方怪兽自身的召唤·特殊召唤成功时的效果发动。
-- ②：以自己场上1只「电气」怪兽为对象才能发动。和那只怪兽卡名不同的1只「电气」怪兽从卡组特殊召唤。那之后，自己失去这个效果特殊召唤的怪兽的攻击力数值的基本分。这个效果的发动后，直到回合结束时自己不是雷族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动、①效果和②效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：对方不能把位于这张卡以及自己场上的「电气」怪兽的正对面的对方怪兽自身的召唤·特殊召唤成功时的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.actlim)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只「电气」怪兽为对象才能发动。和那只怪兽卡名不同的1只「电气」怪兽从卡组特殊召唤。那之后，自己失去这个效果特殊召唤的怪兽的攻击力数值的基本分。这个效果的发动后，直到回合结束时自己不是雷族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为己方场上的表侧表示的电气族怪兽
function s.lfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xe) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 判断是否为对方的召唤或特殊召唤效果，若为则检查是否在电气王国或己方电气族怪兽的正对面
function s.actlim(e,re,tp)
	if not re:IsActivated() or re:GetCode()~=EVENT_SUMMON_SUCCESS
		and re:GetCode()~=EVENT_SPSUMMON_SUCCESS then return end
	local rc=re:GetHandler()
	local rg=rc:GetColumnGroup()
	local p=e:GetHandlerPlayer()
	return rc:IsControler(1-p) and rg:IsContains(e:GetHandler()) or rg:IsExists(s.lfilter,1,nil,p)
end
-- 过滤函数，用于判断是否为己方场上的表侧表示的电气族怪兽，并且卡组中存在与该怪兽不同名的电气族怪兽
function s.cfilter(c,e,tp)
	-- 判断是否为己方场上的表侧表示的电气族怪兽，并且卡组中存在与该怪兽不同名的电气族怪兽
	return c:IsFaceup() and c:IsSetCard(0xe) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 过滤函数，用于判断是否为电气族怪兽且可以特殊召唤，并且卡号与目标怪兽不同
function s.filter(c,e,tp,...)
	return c:IsSetCard(0xe) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(...)
end
-- 判断目标是否为己方场上的表侧表示的电气族怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup()
		and chkc:IsSetCard(0xe) end
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的己方电气族怪兽作为效果对象
		and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择己方场上的表侧表示的电气族怪兽作为效果对象
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示将要特殊召唤一张电气族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，用于判断是否为非雷族怪兽
function s.splim(e,c)
	return c:GetRace()~=RACE_THUNDER
end
-- 处理②效果的发动，选择目标怪兽并特殊召唤不同名的电气族怪兽，然后扣除基本分并设置回合结束时不能特殊召唤雷族怪兽的效果
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍然在场且为表侧表示，并且己方有空余的怪兽区域
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择一张与目标怪兽不同名的电气族怪兽
		local sc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode()):GetFirst()
		-- 将选中的怪兽特殊召唤到场上，并且攻击力不为0时才执行后续扣除基本分操作
		if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 and aux.nzatk(sc) then
			-- 中断当前效果，防止错时点
			Duel.BreakEffect()
			-- 获取当前玩家的基本分
			local lp=Duel.GetLP(tp)
			-- 扣除特殊召唤怪兽的攻击力数值的基本分
			Duel.SetLP(tp,lp-sc:GetAttack())
		end
	end
	local c=e:GetHandler()
	-- 设置回合结束时不能特殊召唤雷族怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splim)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤雷族怪兽的效果到玩家场上
	Duel.RegisterEffect(e1,tp)
end
