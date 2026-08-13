--一回休み
-- 效果：
-- 特殊召唤的怪兽不在自己场上存在的场合才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，特殊召唤的怪兽直到那个回合结束时效果无效化。
-- ②：效果怪兽攻击表示特殊召唤的场合把这个效果发动。那些怪兽变成守备表示。
function c24348804.initial_effect(c)
	-- 特殊召唤的怪兽不在自己场上存在的场合才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_SPSUMMON)
	e1:SetCondition(c24348804.condition)
	e1:SetTarget(c24348804.target1)
	e1:SetOperation(c24348804.operation)
	c:RegisterEffect(e1)
	-- ②：效果怪兽攻击表示特殊召唤的场合把这个效果发动。那些怪兽变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c24348804.target2)
	e2:SetOperation(c24348804.operation)
	e2:SetLabel(1)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在魔法与陷阱区域存在，特殊召唤的怪兽直到那个回合结束时效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c24348804.distg)
	c:RegisterEffect(e3)
end
-- 筛选条件：判断怪兽是否为特殊召唤（召唤类型为特殊召唤），用于检查场上是否存在特殊召唤的怪兽。
function c24348804.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 发动条件：检查我方怪兽区是否存在特殊召唤的怪兽；只有不存在时，这张卡才能发动。
function c24348804.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.IsExistingMatchingCard，在我方怪兽区检索是否存在特殊召唤的怪兽；取反表示不存在时条件通过。
	return not Duel.IsExistingMatchingCard(c24348804.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 魔法卡发动时的目标处理：先通过合法性检查；若当前同时有特殊召唤成功事件，则筛选其中攻击表示的效果怪兽，并询问玩家是否将其变成守备表示。若同意，则将它们设为对象、写入操作信息，并将标签设为1使处理阶段执行；否则标签为0，处理阶段不执行。
function c24348804.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(0)
	-- 检查当前时点是否为特殊召唤成功，并获取该事件的详细信息（eg为特殊召唤成功的怪兽组），用于判断能否在发动时一并处理②。
	local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
	if res then
		local g=teg:Filter(c24348804.filter1,nil)
		-- 若存在攻击表示的效果怪兽且玩家选择使用效果，则继续执行后续的设置对象操作。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(24348804,0)) then  --"是否使用效果？"
			-- 将选中的特殊召唤怪兽设置为当前连锁的对象，以便效果处理时对这些怪兽变更表示形式。
			Duel.SetTargetCard(g)
			-- 设置操作信息：本次连锁的处理分类为改变表示形式，处理对象为g，数量为g的卡数；供系统判定相关交互（如被无效、或对应星尘龙等）。
			Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
			e:SetLabel(1)
			e:GetHandler():RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(24348804,1))  --"发动同时使用效果"
		end
	end
end
-- 筛选条件：怪兽为表侧攻击表示且为效果怪兽，用于②的触发对象判定。
function c24348804.filter1(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsType(TYPE_EFFECT)
end
-- 诱发效果②的目标处理：只要特殊召唤成功事件中包含攻击表示的效果怪兽，就将这些怪兽全都设为对象，并设置变更表示形式的操作信息；该效果为必发，因此chk==0时仅判断是否存在符合条件的怪兽。
function c24348804.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c24348804.filter1,1,nil) end
	local g=eg:Filter(c24348804.filter1,nil)
	-- 将本次特殊召唤成功怪兽中满足条件的攻击表示效果怪兽设为当前连锁的对象。
	Duel.SetTargetCard(g)
	-- 设置操作信息：将对象怪兽的表示形式变更（CATEGORY_POSITION），对象数量为g的卡数。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：若标签为0或此卡与效果不再关联则跳过；否则从连锁对象中取出仍与效果关联的怪兽，将其全部变为守备表示。
function c24348804.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 从当前连锁信息中获取对象卡组，并过滤出仍然与当前效果存在关联的卡（防止对离场或失去关联的卡误操作）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 变更表示形式：将对象怪兽一律改为守备表示（原攻击表示改为表侧守备表示，原守备表示保持守备）。注意这里不会变成攻击表示。
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE)
	end
end
-- 无效化筛选：判断怪兽是否在本回合被特殊召唤过（具有STATUS_SPSUMMON_TURN状态且召唤类型为特殊召唤），若满足则被无效化，对应①的效果无效化处理。
function c24348804.distg(e,c)
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
