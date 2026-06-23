--選律のヴァルモニカ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「异响鸣」怪兽卡存在的场合，从以下效果选1个适用。自己场上有「异响鸣」连接怪兽存在的场合，可以选两方适用。
-- ●自己回复500基本分。这个回合中，对方不能把自己场上的「异响鸣」怪兽卡作为效果的对象。
-- ●自己受到500伤害。那之后，可以把对方场上1只效果怪兽的效果直到回合结束时无效。
local s,id,o=GetID()
-- 注册卡牌效果：设置为发动时点、条件判断和处理函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 筛选场上存在的「异响鸣」怪兽（包括连接怪兽）
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a3) and c:GetOriginalType()&TYPE_MONSTER>0
end
-- 判断是否满足发动条件：自己场上有「异响鸣」怪兽卡存在
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张「异响鸣」怪兽卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 筛选场上存在的「异响鸣」连接怪兽
function s.afilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a3) and c:IsType(TYPE_LINK)
end
-- 处理效果发动时的选项选择与执行逻辑
function s.activate(e,tp,eg,ep,ev,re,r,rp,op)
	if op==nil and not s.condition(e,tp) then return end
	local c=e:GetHandler()
	if op==nil then
		-- 检查自己场上是否存在至少1张「异响鸣」连接怪兽
		local chk=Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_MZONE,0,1,nil)
		-- 调用选项选择函数，让玩家选择效果
		op=aux.SelectFromOptions(tp,
			{true,aux.Stringid(id,1)},  --"自己回复500基本分"
			{true,aux.Stringid(id,2)},  --"自己受到500伤害"
			{chk,aux.Stringid(id,3)})  --"选两方适用"
	end
	-- 若选择第1个效果（回复LP），则执行回复500基本分并设置不能成为效果对象
	if op&1>0 and Duel.Recover(tp,500,REASON_EFFECT)>0 then
		-- 自己回复500基本分。这个回合中，对方不能把自己场上的「异响鸣」怪兽卡作为效果的对象。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetTargetRange(LOCATION_ONFIELD,0)
		e1:SetTarget(s.target)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 设置效果值为辅助函数tgoval，用于判断是否能成为效果对象
		e1:SetValue(aux.tgoval)
		-- 将效果注册到玩家全局环境
		Duel.RegisterEffect(e1,tp)
		-- 如果选择了两个效果，则中断当前效果处理
		if op==3 then Duel.BreakEffect() end
	end
	-- 若选择第2个效果（受到伤害），则执行造成500伤害并选择对方怪兽无效
	if op&2>0 and Duel.Damage(tp,500,REASON_EFFECT)>0 then
		-- 获取对方场上所有可被无效化的怪兽
		local g=Duel.GetMatchingGroup(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,nil)
		-- 如果存在可无效怪兽且玩家选择无效，则继续处理
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否把对方1只怪兽的效果无效？"
			-- 提示玩家选择要无效的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 显示被选中的怪兽动画
			Duel.HintSelection(sg)
			local tc=sg:GetFirst()
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 使目标怪兽相关的连锁无效
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 对方场上1只效果怪兽的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
		end
	end
end
-- 设置目标过滤函数，用于判断是否为「异响鸣」怪兽
function s.target(e,c)
	return c:IsSetCard(0x1a3) and c:GetOriginalType()&TYPE_MONSTER>0
end
