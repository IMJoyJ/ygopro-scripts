--アティプスの蟲惑魔
-- 效果：
-- 包含昆虫族·植物族怪兽的怪兽2只以上
-- ①：连接召唤的这张卡不受陷阱卡的效果影响。
-- ②：只要自己墓地有通常陷阱卡存在，自己场上的「虫惑魔」怪兽的攻击力上升1000。
-- ③：1回合1次，以最多有自己场上的昆虫族·植物族怪兽数量的对方场上的表侧表示的卡为对象才能发动。那些卡的效果直到回合结束时无效。那之后，以下可以适用。
-- ●从自己墓地把1张通常陷阱卡除外，选作为对象的表侧表示的卡之内1张破坏。
local s,id,o=GetID()
-- 定义卡片的初始化效果函数：注册连接召唤手续（2~3只怪兽且至少含昆虫族或植物族怪兽），并注册①不受陷阱效果影响②「虫惑魔」怪兽攻击力上升③1回合1次无效对方表侧表示卡并可选除外通常陷阱破坏1张之三个效果。
function s.initial_effect(c)
	-- 为这张卡添加连接召唤手续：使用2~3只怪兽作为连接素材，且素材组必须满足s.lcheck（至少包含1只昆虫族或植物族怪兽）。
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	c:EnableReviveLimit()
	-- ①：连接召唤的这张卡不受陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.imcon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- ②：只要自己墓地有通常陷阱卡存在，自己场上的「虫惑魔」怪兽的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(s.atkcon)
	-- 设定攻击力上升效果只适用于自己场上卡名含有「虫惑魔」字段（0x108a）的怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108a))
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- ③：1回合1次，以最多有自己场上的昆虫族·植物族怪兽数量的对方场上的表侧表示的卡为对象才能发动。那些卡的效果直到回合结束时无效。那之后，以下可以适用。●从自己墓地把1张通常陷阱卡除外，选作为对象的表侧表示的卡之内1张破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE+CATEGORY_DESTROY+CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 连接素材追加条件：素材组g中至少存在1只种族为昆虫族或植物族的怪兽，满足“包含昆虫族·植物族怪兽的怪兽2只以上”的召唤条件。
function s.lcheck(g)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_INSECT+RACE_PLANT)
end
-- ①效果的适用条件：这张卡是连接召唤成功的情况下才适用免疫陷阱卡效果。
function s.imcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果的免疫过滤条件：只免疫类型为陷阱卡（TYPE_TRAP）的效果，即对应“不受陷阱卡的效果影响”。
function s.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
-- 过滤函数：判断一张卡是否为通常陷阱卡（类型仅为陷阱卡），用于查找墓地中的通常陷阱卡。
function s.cfilter(c)
	return c:GetType()==TYPE_TRAP
end
-- ②效果的适用条件：效果持有者（这张卡）的玩家的墓地中存在至少1张通常陷阱卡。
function s.atkcon(e)
	-- 检查自己墓地中是否存在至少1张满足s.cfilter（通常陷阱卡）的卡，存在则返回true。
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
-- 过滤函数：判断卡牌是否满足“表侧表示且为昆虫族或植物族怪兽”，用于统计自己场上此类怪兽的数量。
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT+RACE_PLANT)
end
-- 设置③效果的发动目标：以自己场上昆虫族·植物族怪兽数量为上限，从对方场上的表侧表示且可被无效的卡中选择1~该数量张作为对象，并登记无效操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 统计自己场上表侧表示的昆虫族·植物族怪兽数量ct，作为可选对象的最大数量。
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,0,nil)
	-- 对象合法性检查：候选卡必须是对方控制、在场上且可被无效化的卡。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 发动合法性检查：要求ct>0（自己场上有昆虫/植物怪兽）且对方场上有至少1张可被无效的卡存在，否则不能发动。
	if chk==0 then return ct>0 and Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 弹出“请选择要无效的卡”的选择提示，并把选择类型设为无效目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让当前玩家从对方场上选择1~ct张可被无效的表侧表示卡作为效果对象，并锁定为连锁对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置当前连锁的操作信息为“无效卡”分类，目标为已选择的对象g，数量为g的卡数，供后续相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
-- 过滤函数：判断自己墓地中的一张卡是否为通常陷阱卡并且可以除外，用于后续除外通常陷阱卡的分支。
function s.rmfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsAbleToRemove()
end
-- 执行③效果的处理：先将仍未离场且表侧表示的对象卡无效化；若墓地存在通常陷阱卡且玩家选择“是”，则除外1张通常陷阱卡，再从仍表侧表示的对象卡中选择1张破坏。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的对象卡中仍然表侧表示的卡，作为本次无效化处理的目标集合。
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsFaceup,nil)
	if #g==0 then return end
	local tc=g:GetFirst()
	while tc do
		-- 使对象卡tc相关的连锁无效化（相当于其发力无效），持续到回合结束。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那些卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那些卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那些卡的效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
	-- 立即刷新场上卡的无效状态，使刚赋予的无效效果马上生效，避免状态延迟。
	Duel.AdjustInstantly(c)
	-- 检查自己墓地中是否存在至少1张可除外的通常陷阱卡，且不受王家长眠之谷等效果限制。
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_GRAVE,0,1,nil)
		-- 弹出“是否选其中1张破坏？”的确认框，只有玩家选择“是”才继续后续除外与破坏分支。
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否选其中1张破坏？"
		-- 中断当前连锁处理，使后续除外与破坏作为同一效果的不同步骤处理（错开时点），符合“那之后”的语义。
		Duel.BreakEffect()
		-- 弹出“请选择要除外的卡”的选择提示，让玩家从墓地选择要除外的通常陷阱卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从自己墓地选择1张满足rmfilter且不受王家长眠之谷影响的通常陷阱卡，作为除外对象。
		local rg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		local tg=g:Filter(Card.IsFaceup,nil)
		-- 确认除外选择非空、仍有表侧表示的对象卡且除外执行成功后才可进入破坏处理。
		if #rg>0 and #tg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
			-- 弹出“请选择要破坏的卡”的选择提示，让玩家从作为对象的表侧表示卡中选出要破坏的那1张。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 手动显示被选中要破坏的卡的目标选择动画，并记录为连锁对象。
			Duel.HintSelection(sg)
			-- 将被选中的对象卡以效果破坏，送去墓地，完成“选作为对象的表侧表示的卡之内1张破坏”。
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
