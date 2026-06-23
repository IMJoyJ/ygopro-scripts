--竜剣士ウィンドユニコーンP
-- 效果：
-- ←2 【灵摆】 2→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域有卡存在的场合，可以从以下效果选择1个发动。
-- ●这张卡特殊召唤。
-- ●这张卡破坏，自己的灵摆区域1张5星以下的灵摆怪兽卡特殊召唤。
-- 【怪兽效果】
-- 这个卡名的②的怪兽效果1回合只能使用1次。
-- ①：只要灵摆召唤的这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
-- ②：自己·对方回合，以自己场上1张灵摆怪兽卡和对方场上1张卡为对象才能发动。那些卡回到手卡。
local s,id,o=GetID()
-- 注册卡片的所有效果，包括灵摆效果和怪兽效果
function s.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：另一边的自己的灵摆区域有卡存在的场合，可以从以下效果选择1个发动。●这张卡特殊召唤。●这张卡破坏，自己的灵摆区域1张5星以下的灵摆怪兽卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"灵摆效果发动"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.pencon)
	e1:SetTarget(s.pentg)
	e1:SetOperation(s.penop)
	c:RegisterEffect(e1)
	-- ①：只要灵摆召唤的这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.protcon)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置效果值为过滤函数aux.tgoval，用于判断该卡是否不会被对方的效果选为对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置效果值为过滤函数aux.indoval，用于判断该卡是否不会被对方的效果破坏
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ②：自己·对方回合，以自己场上1张灵摆怪兽卡和对方场上1张卡为对象才能发动。那些卡回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 判断灵摆区域的两个位置是否都有卡存在
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断灵摆区域的两个位置是否都有卡存在
	return Duel.GetFieldCard(tp,LOCATION_PZONE,0) and Duel.GetFieldCard(tp,LOCATION_PZONE,1)
end
-- 过滤函数，用于筛选满足条件的灵摆怪兽卡
function s.penspfilter(c,e,tp)
	return c:IsLevelBelow(5) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置灵摆效果的发动条件和目标选择逻辑
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否可以将此卡特殊召唤
	local b1=c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 判断自己灵摆区域是否存在满足条件的5星以下灵摆怪兽卡
	local b2=Duel.IsExistingMatchingCard(s.penspfilter,tp,LOCATION_PZONE,0,1,c,e,tp)
		-- 判断是否有足够的怪兽区域进行特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return b1 or b2 end
	-- 让玩家从选项中选择一个发动效果
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"这张卡特殊召唤"
			{b2,aux.Stringid(id,3),2})  --"这张卡破坏"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息为特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息为破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
		-- 设置操作信息为特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
	end
end
-- 执行灵摆效果的操作逻辑
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	elseif op==2 then
		-- 破坏此卡并检查是否有足够的怪兽区域进行特殊召唤
		if Duel.Destroy(c,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 获取满足条件的灵摆怪兽卡组
			local sg=Duel.GetMatchingGroup(s.penspfilter,tp,LOCATION_PZONE,0,nil,e,tp)
			if #sg==0 then return end
			if #sg==1 then
				-- 将符合条件的灵摆怪兽卡特殊召唤到场上
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				return
			end
			if #sg>1 then
				-- 提示玩家选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local g=sg:Select(tp,1,1,nil)
				-- 将玩家选择的卡特殊召唤到场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 判断此卡是否为灵摆召唤
function s.protcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 过滤函数，用于筛选满足条件的灵摆怪兽卡
function s.thfilter(c,tp)
	return (c:GetOriginalType()&(TYPE_PENDULUM|TYPE_MONSTER)==TYPE_PENDULUM|TYPE_MONSTER) and c:IsFaceup() and c:IsControler(tp)
end
-- 设置怪兽效果的发动条件和目标选择逻辑
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取满足条件的场上卡组
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsCanBeEffectTarget,Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chk==0 then return g:CheckSubGroup(s.thcheck,2,2,tp) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:SelectSubGroup(tp,s.thcheck,false,2,2,tp)
	-- 设置当前处理的连锁的目标卡
	Duel.SetTargetCard(sg)
	-- 设置操作信息为返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,2,0,0)
end
-- 检查所选卡组是否满足返回手牌的条件
function s.thcheck(g,tp)
	return g:IsExists(s.thfilter,1,nil,tp)
		-- 检查所选卡组中是否存在对方控制的卡
		and g:IsExists(aux.AND(Card.IsControler,Card.IsAbleToHand),1,nil,1-tp)
end
-- 执行怪兽效果的操作逻辑
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中涉及的目标卡
	local g=Duel.GetTargetsRelateToChain()
	if #g>0 then
		-- 将目标卡送回手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
