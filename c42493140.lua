--従騎士トゥルーデア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。自己场上的这张卡和除「从骑士 特露迪娅」以外的手卡·卡组1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。这个回合，自己不能把「从骑士 特露迪娅」特殊召唤。
-- ②：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。那之后，可以让这张卡的等级上升4星。
local s,id,o=GetID()
-- 创建两个效果，分别对应①②效果
function s.initial_effect(c)
	-- ①：自己主要阶段才能发动。自己场上的这张卡和除「从骑士 特露迪娅」以外的手卡·卡组1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。这个回合，自己不能把「从骑士 特露迪娅」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。那之后，可以让这张卡的等级上升4星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选「百夫长骑士」怪兽
function s.filter(c)
	return c:IsSetCard(0x1a2) and c:IsType(TYPE_MONSTER) and not c:IsForbidden() and not c:IsCode(id)
end
-- ①效果的发动条件判断，检查手卡和卡组中是否存在满足条件的怪兽且场上魔法陷阱区有足够空位
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡和卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil)
		-- 检查场上魔法陷阱区是否有至少2个空位
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>1 end
end
-- ①效果的处理函数，将自己和符合条件的怪兽移至魔法陷阱区并变为永续陷阱卡，同时禁止本回合特殊召唤自己
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否在场且为玩家控制，且魔法陷阱区有足够空位
	if c:IsRelateToEffect(e) and c:IsControler(tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>1 then
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 选择满足条件的1张「百夫长骑士」怪兽
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将自身移至魔法陷阱区
			Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 将自身变为永续陷阱卡
			local e1=Effect.CreateEffect(c)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
			c:RegisterEffect(e1)
			-- 将选中的怪兽移至魔法陷阱区
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 将选中的怪兽变为永续陷阱卡
			local e2=Effect.CreateEffect(c)
			e2:SetCode(EFFECT_CHANGE_TYPE)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e2:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
			tc:RegisterEffect(e2)
		end
	end
	-- 设置效果，禁止本回合特殊召唤自己
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册禁止特殊召唤的效果
	Duel.RegisterEffect(e3,tp)
end
-- 限制特殊召唤的条件，禁止召唤自己
function s.splimit(e,c)
	return c:IsCode(id)
end
-- ②效果的发动条件判断，检查当前阶段是否为主要阶段且自身为永续陷阱卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- ②效果的发动条件判断，检查是否有足够的怪兽区空位且可以特殊召唤自己
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否可以特殊召唤自己
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1a2,TYPE_MONSTER+TYPE_EFFECT,1000,2000,4,RACE_PYRO,ATTRIBUTE_DARK) end
	-- 设置操作信息，确定特殊召唤的目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理函数，特殊召唤自身并询问是否提升等级
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 特殊召唤自身成功且玩家选择提升等级时执行
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否上升等级？"
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 提升自身等级4星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(4)
		c:RegisterEffect(e1)
	end
end
