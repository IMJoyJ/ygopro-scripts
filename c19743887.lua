--蹴神－VARefar
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上的怪兽成为对方场上的怪兽的效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。这张卡从手卡特殊召唤。那之后，可以选那1只对方怪兽并把1张手卡给对方观看。那个场合，再让给人观看的卡种类的以下效果对选的怪兽适用。
-- ●怪兽：变成守备表示。
-- ●魔法：攻击力变成2倍。
-- ●陷阱：除外。
local s,id,o=GetID()
-- 创建并注册效果1，用于处理被选为攻击对象时的特殊召唤效果
function s.initial_effect(c)
	-- ①：自己场上的怪兽成为对方场上的怪兽的效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 判断是否满足效果发动条件：攻击怪兽为对方控制，被攻击怪兽为己方控制
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击目标怪兽
	local at=Duel.GetAttackTarget()
	-- 判断攻击怪兽是否为对方控制，攻击目标是否为己方控制
	return Duel.GetAttacker():IsControler(1-tp) and at:IsControler(tp)
end
-- 过滤函数，用于判断卡是否在己方场上
function s.cfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 判断是否满足效果发动条件：连锁为对方发动且具有取对象属性，且对象卡中有己方场上怪兽
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取连锁对象卡组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 获取连锁发生位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return (loc&LOCATION_ONFIELD)~=0 and re:IsActiveType(TYPE_MONSTER) and g and g:IsExists(s.cfilter,1,nil,tp)
end
-- 设置特殊召唤的判定条件：己方场上存在空位且该卡可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断己方场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 获取当前攻击怪兽
	local ac=Duel.GetAttacker()
	-- 设置当前连锁对象为攻击怪兽
	Duel.SetTargetCard(ac)
	-- 设置操作信息：特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数，用于判断手牌是否满足后续效果触发条件
function s.cfilter2(c,ac)
	return not c:IsPublic()
		and (c:IsType(TYPE_MONSTER) and ac:IsCanChangePosition() and ac:IsPosition(POS_ATTACK)
		or c:IsType(TYPE_SPELL) and ac:IsFaceup()
		or c:IsType(TYPE_TRAP) and ac:IsAbleToRemove())
end
-- 处理特殊召唤后的操作：将该卡特殊召唤到场上，并调用后续效果处理函数
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否在连锁中且成功特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前连锁对象
		local ac=Duel.GetFirstTarget()
		if ac and ac:IsRelateToChain() and ac:IsType(TYPE_MONSTER) then
			s.cfop(e,tp,eg,ep,ev,re,r,rp,ac)
		end
	end
end
-- 设置特殊召唤的判定条件：己方场上存在空位且该卡可特殊召唤
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断己方场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁对象为连锁发动的卡
	Duel.SetTargetCard(re:GetHandler())
	-- 设置操作信息：特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理特殊召唤后的操作：将该卡特殊召唤到场上，并调用后续效果处理函数
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否在连锁中且成功特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前连锁对象
		local ac=Duel.GetFirstTarget()
		if ac and ac:IsRelateToChain() and ac:IsType(TYPE_MONSTER) then
			s.cfop(e,tp,eg,ep,ev,re,r,rp,ac)
		end
	end
end
-- 处理效果触发后的操作：选择手牌并根据其类型对目标怪兽施加效果
function s.cfop(e,tp,eg,ep,ev,re,r,rp,ac)
	-- 获取满足条件的手牌组
	local g=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_HAND,0,nil,ac)
	if not ac:IsLocation(LOCATION_MZONE) or not ac:IsControler(1-tp) then return end
	-- 判断是否有满足条件的手牌且玩家选择观看手牌
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否给对方观看手卡？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 显示目标怪兽被选为对象的动画效果
		Duel.HintSelection(Group.FromCards(ac))
		-- 提示玩家选择要确认的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		-- 确认对方观看手牌
		Duel.ConfirmCards(1-tp,tc)
		-- 洗切己方手牌
		Duel.ShuffleHand(tp)
		if tc:IsType(TYPE_MONSTER) then
			-- 将目标怪兽变为守备表示
			Duel.ChangePosition(ac,POS_FACEUP_DEFENSE)
		elseif tc:IsType(TYPE_SPELL) then
			-- 魔法：攻击力变成2倍。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(ac:GetAttack()*2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ac:RegisterEffect(e1)
		elseif tc:IsType(TYPE_TRAP) then
			-- 将目标怪兽除外
			Duel.Remove(ac,POS_FACEUP,REASON_EFFECT)
		end
	end
end
