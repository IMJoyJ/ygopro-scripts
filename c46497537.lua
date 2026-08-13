--トン＝トン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力·等级之内比原本数值高的数值变成原本数值。那之后，支付100的倍数的基本分（最多1000）。
-- ②：这张卡在墓地存在，自己基本分和对方相同的场合，自己主要阶段才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化卡片效果：创建①效果作为魔法卡发动（取对象修正攻击力/守备力/等级并支付LP）和②效果作为墓地起动效果（将自身盖放），并分别注册到该卡。
function s.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力·等级之内比原本数值高的数值变成原本数值。那之后，支付100的倍数的基本分（最多1000）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置①效果的发动条件：仅在伤害步骤且未进行伤害计算时也可发动（即伤害步骤内只能伤害计算前发动）。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在，自己基本分和对方相同的场合，自己主要阶段才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 定义①效果的取对象筛选条件：场上表侧表示怪兽，且其攻击力、守备力、等级中至少有一项高于各自原本数值。
function s.filter(c)
	return c:IsFaceup() and (c:IsLevelAbove(c:GetOriginalLevel()+1) or c:IsAttackAbove(c:GetBaseAttack()+1) or c:IsDefenseAbove(c:GetBaseDefense()+1))
end
-- 效果发动时的对象合法性与条件检查：连锁处理中验证对象位于主要怪兽区且满足筛选条件；发动前确认场上存在符合条件的表侧表示怪兽且自己至少能支付100LP。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 发动时点检查：场上是否存在至少1只满足筛选条件的表侧表示怪兽，可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 同时确认自己当前LP足以支付至少100点基本分，满足后续支付100倍数LP的前提。
		and Duel.CheckLPCost(tp,100,true) end
	-- 发送UI提示，让玩家从场上选择表侧表示的怪兽卡，用于后续取对象的交互提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动者从双方主要怪兽区选择1只满足条件的表侧表示怪兽作为效果对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 处理①效果：若对象仍与效果关联且表侧表示、不免疫此效果，则将其攻击力、守备力、等级中高于原本数值的项分别恢复为原本数值；至少变更一项后，由玩家从可支付的100倍数（最多1000）中宣言数值并支付LP。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时已选择的1只对象怪兽（通常是从目标列表中取得第一张卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		local ct=0
		local ba,bd,bl=tc:GetBaseAttack(),tc:GetBaseDefense(),tc:GetOriginalLevel()
		if tc:IsAttackAbove(ba) then
			-- 那只怪兽的攻击力·守备力·等级之内比原本数值高的数值变成原本数值（攻击力部分）。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(ba)
			tc:RegisterEffect(e1)
			ct=ct+1
		end
		if tc:IsDefenseAbove(bd) then
			-- 那只怪兽的攻击力·守备力·等级之内比原本数值高的数值变成原本数值（守备力部分）。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(bd)
			tc:RegisterEffect(e2)
			ct=ct+1
		end
		if tc:IsLevelAbove(bl) then
			-- 那只怪兽的攻击力·守备力·等级之内比原本数值高的数值变成原本数值（等级部分）。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CHANGE_LEVEL)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			e3:SetValue(bl)
			tc:RegisterEffect(e3)
			ct=ct+1
		end
		if ct==0 then return end
		-- 获取当前发动者的LP数值，用于计算可支付的基本分上限（LP与1000中取较小值）。
		local lp=Duel.GetLP(tp)
		local m=math.min(lp,1000)//100
		local t={}
		for i=1,m do
			t[i]=i*100
		end
		-- 让发动者从可选的100倍数数值（100、200、...、min(LP,1000)）中宣言一个数，作为实际支付的基本分数。
		local ac=Duel.AnnounceNumber(tp,table.unpack(t))
		-- 中断当前效果处理，使后续支付LP的处理与之前的攻防/等级变更处理视为不同时进行，以错开时点。
		Duel.BreakEffect()
		-- 令发动者支付宣言数值的LP，完成“那之后，支付100的倍数的基本分（最多1000）”的处理。
		Duel.PayLPCost(tp,ac,true)
	end
end
-- ②效果的发动条件判断：自身在墓地存在，且双方基本分相同；满足时才可在主要阶段发动。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 比较双方玩家的当前LP，若相等则条件成立，对应“自己基本分和对方相同的场合”。
	return Duel.GetLP(0)==Duel.GetLP(1)
end
-- ②效果发动时的检查与操作信息设定：确认这张卡在墓地可以被盖放（IsSSetable），并声明该卡即将离开墓地。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置操作信息：本效果会让墓地中的这张卡（数量1）离开墓地，用于相关效果（如王家长眠之谷）的发动检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联（仍在墓地且未被无效等），则将这张卡在自己场上盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在确认该卡与效果关联后，将其从墓地以里侧表示盖放到自己场上，完成②效果。
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end
