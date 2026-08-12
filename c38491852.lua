--ヴァルモニカ・インヴィターレ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从以下效果选1个适用。
-- ●从卡组把1只「异响鸣」怪兽特殊召唤。这张卡的发动后，直到回合结束时自己不能把「异响鸣」怪兽以外的场上的怪兽的效果发动。
-- ●自己场上有灵摆怪兽以外的「异响鸣」怪兽存在的场合，从卡组选2只卡名不同的「异响鸣」灵摆怪兽，那之内的1只加入手卡，另1只表侧加入额外卡组。
local s,id,o=GetID()
-- 初始化效果函数，创建主效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOEXTRA+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 特殊召唤过滤器，用于筛选「异响鸣」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1a3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 灵摆怪兽过滤器，用于筛选「异响鸣」灵摆怪兽
function s.thfilter(c,tp)
	return c:IsSetCard(0x1a3) and c:IsType(TYPE_PENDULUM)
		and (c:IsAbleToExtra() or c:IsAbleToHand())
end
-- 场上的「异响鸣」怪兽过滤器，排除灵摆怪兽
function s.cfilter(c)
	return not c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x1a3) and c:IsFaceup()
end
-- 效果的发动条件判断，判断是否可以发动效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有「异响鸣」灵摆怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 判断自己场上是否有足够的怪兽区域
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的「异响鸣」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	local b2=g:CheckSubGroup(s.Group,2,2)
		-- 判断自己场上是否存在「异响鸣」非灵摆怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
end
-- 灵摆怪兽加入手牌过滤器
function s.thfilter2(c,g)
	return c:IsAbleToExtra() and g:FilterCount(Card.IsAbleToHand,c)==1
end
-- 子组检查函数，用于判断是否满足选择2只不同卡名灵摆怪兽的条件
function s.Group(g)
	-- 检查子组中是否满足卡名不同且有1张可加入手牌的条件
	return aux.dncheck(g) and g:FilterCount(s.thfilter2,nil,g)~=0
end
-- 效果发动处理函数，根据选择的选项执行不同效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取卡组中所有「异响鸣」灵摆怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 判断自己场上是否有足够的怪兽区域
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的「异响鸣」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	local b2=g:CheckSubGroup(s.Group,2,2)
		-- 判断自己场上是否存在「异响鸣」非灵摆怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
	local op=0
	if b1 and b2 then
		-- 选择效果选项，选项1为特殊召唤
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))+1  --"特殊召唤/加入手卡"
	elseif b1 then
		-- 选择效果选项，选项1为特殊召唤
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1  --"特殊召唤"
	elseif b2 then
		-- 选择效果选项，选项2为加入手牌
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+2  --"加入手卡"
	end
	if op==1 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的1只「异响鸣」怪兽
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 设置发动后直到回合结束时自己不能发动「异响鸣」怪兽以外的怪兽效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果，使对方不能发动怪兽效果
		Duel.RegisterEffect(e1,tp)
	elseif op==2 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:SelectSubGroup(tp,s.Group,false,2,2)
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tc=sg:FilterSelect(tp,Card.IsAbleToHand,1,1,nil):GetFirst()
		-- 将选中的卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 确认对方手牌
		Duel.ConfirmCards(1-tp,tc)
		sg:RemoveCard(tc)
		-- 将剩余的卡表侧加入额外卡组
		Duel.SendtoExtraP(sg,nil,REASON_EFFECT)
	end
end
-- 限制发动效果的条件，只有非「异响鸣」怪兽才能被无效
function s.aclimit(e,re,tp)
	local c=re:GetHandler()
	return not c:IsSetCard(0x1a3) and re:IsActiveType(TYPE_MONSTER) and c:IsLocation(LOCATION_MZONE)
end
