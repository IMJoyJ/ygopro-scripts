--面子蝙蝠
-- 效果：
-- ①：1回合最多3次，对方把怪兽召唤·特殊召唤的场合，以那之内的1只为对象才能发动。进行1次投掷硬币。表的场合，那只怪兽变成表侧攻击表示。里的场合，那只怪兽变成里侧守备表示。
-- ②：1回合1次，这张卡在怪兽区域存在的状态，场上的怪兽反转的场合或者表侧表示怪兽变成里侧守备表示的场合，以那之内的1只为对象才能发动（伤害步骤也能发动）。那只怪兽变成表侧攻击表示或里侧守备表示。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（召唤·特殊召唤时投硬币改变表示形式）和②效果（场上怪兽反转或变里侧守备时改变表示形式）。
function s.initial_effect(c)
	-- ①：1回合最多3次，对方把怪兽召唤·特殊召唤的场合，以那之内的1只为对象才能发动。进行1次投掷硬币。表的场合，那只怪兽变成表侧攻击表示。里的场合，那只怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"用①效果改变表现形式"
	e1:SetCategory(CATEGORY_COIN+CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(3,EFFECT_COUNT_CODE_SINGLE)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，这张卡在怪兽区域存在的状态，场上的怪兽反转的场合或者表侧表示怪兽变成里侧守备表示的场合，以那之内的1只为对象才能发动（伤害步骤也能发动）。那只怪兽变成表侧攻击表示或里侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"用②效果改变表现形式"
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCondition(s.poscon2)
	e3:SetTarget(s.postg2)
	e3:SetOperation(s.posop2)
	c:RegisterEffect(e3)
end
s.toss_coin=true
-- 过滤对方召唤·特殊召唤的、可以改变表示形式且可以作为效果对象的怪兽（若已是表侧攻击表示，则必须能变成里侧守备表示）。
function s.filter(c,e,tp)
	return c:IsCanChangePosition() and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(1-tp)
		and (not c:IsPosition(POS_FACEUP_ATTACK) or c:IsCanTurnSet())
end
-- ①效果的发动准备（Target函数），确认是否有符合条件的怪兽，并进行取对象和设置操作信息。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.filter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(s.filter,1,nil,e,tp) and not eg:IsContains(e:GetHandler(),tp) end
	local tc=eg:FilterSelect(tp,s.filter,1,1,nil,e,tp)
	-- 将选择的怪兽设为效果处理的对象。
	Duel.SetTargetCard(tc)
	-- 设置操作信息，表示该效果包含改变表示形式的操作，对象为选中的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
	-- 设置操作信息，表示该效果包含投掷1次硬币的操作。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- ①效果的效果处理（Operation函数），进行投硬币，根据正反面结果将对象怪兽变成表侧攻击表示或里侧守备表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and tc:IsCanChangePosition() then
		-- 让发动效果的玩家进行1次投掷硬币。
		local c1=Duel.TossCoin(tp,1)
		if c1==1 and not tc:IsPosition(POS_FACEUP_ATTACK) then
			-- 将对象怪兽变成表侧攻击表示。
			Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		elseif c1==0 and not tc:IsPosition(POS_FACEDOWN_DEFENSE) then
			-- 将对象怪兽变成里侧守备表示。
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
end
-- 过滤场上发生反转（里侧变表侧）或表侧变里侧守备表示的怪兽。
function s.cfilter(c)
	return c:IsPreviousPosition(POS_FACEDOWN) and c:IsFaceup() and (not c:IsPosition(POS_FACEUP_ATTACK) or c:IsCanTurnSet())
		or c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown()
end
-- ②效果的发动条件，检查是否有怪兽反转或变成里侧守备表示。
function s.poscon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ②效果的发动准备（Target函数），确认并选择那之内的一只怪兽作为对象。
function s.postg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.cfilter(chkc) and eg:IsContains(chkc) end
	if chk==0 then return eg:Filter(Card.IsOnField,nil):IsExists(s.cfilter,1,nil,e) and not eg:IsContains(e:GetHandler(),tp) end
	local tc=eg:Filter(Card.IsOnField,nil):FilterSelect(tp,s.cfilter,1,1,nil)
	-- 给玩家发送提示信息，提示选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 将选择的怪兽设为效果处理的对象。
	Duel.SetTargetCard(tc)
	-- 设置操作信息，表示该效果包含改变表示形式的操作，对象为选中的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
end
-- ②效果的效果处理（Operation函数），将对象怪兽变成表侧攻击表示或里侧守备表示。
function s.posop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		if tc:IsPosition(POS_FACEUP_ATTACK) then
			-- 将原本是表侧攻击表示的对象怪兽变成里侧守备表示。
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		elseif tc:IsPosition(POS_FACEDOWN_DEFENSE) then
			-- 将原本是里侧守备表示的对象怪兽变成表侧攻击表示。
			Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		elseif tc:IsCanTurnSet() then
			-- 让玩家选择将对象怪兽变成表侧攻击表示或里侧守备表示。
			local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
			-- 将对象怪兽改变为玩家选择的表示形式。
			Duel.ChangePosition(tc,pos)
		else
			-- 若无法变成里侧守备表示，则强制将对象怪兽变成表侧攻击表示。
			Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		end
	end
end
