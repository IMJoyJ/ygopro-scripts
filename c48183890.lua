--アティプスの蟲惑魔
-- 效果：
-- 包含昆虫族·植物族怪兽的怪兽2只以上
-- ①：连接召唤的这张卡不受陷阱卡的效果影响。
-- ②：只要自己墓地有通常陷阱卡存在，自己场上的「虫惑魔」怪兽的攻击力上升1000。
-- ③：1回合1次，以最多有自己场上的昆虫族·植物族怪兽数量的对方场上的表侧表示的卡为对象才能发动。那些卡的效果直到回合结束时无效。那之后，以下可以适用。
-- ●从自己墓地把1张通常陷阱卡除外，选作为对象的表侧表示的卡之内1张破坏。
local s,id,o=GetID()
-- 初始化效果，设置连接召唤手续、启用复活限制并注册三个效果
function s.initial_effect(c)
	-- 添加连接召唤手续，要求使用2到3只包含昆虫族或植物族的怪兽作为连接素材
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	c:EnableReviveLimit()
	-- 效果①：连接召唤的这张卡不受陷阱卡的效果影响
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.imcon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- 效果②：只要自己墓地有通常陷阱卡存在，自己场上的「虫惑魔」怪兽的攻击力上升1000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(s.atkcon)
	-- 设置效果②的目标为「虫惑魔」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108a))
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- 效果③：1回合1次，以最多有自己场上的昆虫族·植物族怪兽数量的对方场上的表侧表示的卡为对象才能发动。那些卡的效果直到回合结束时无效。
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
-- 连接召唤素材检查函数，确保连接素材包含昆虫族或植物族怪兽
function s.lcheck(g)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_INSECT+RACE_PLANT)
end
-- 效果①的发动条件：此卡必须是连接召唤 summoned
function s.imcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的过滤函数，判断是否为陷阱卡的效果
function s.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
-- 墓地陷阱卡过滤器，用于检测墓地是否存在通常陷阱卡
function s.cfilter(c)
	return c:GetType()==TYPE_TRAP
end
-- 效果②的发动条件：自己墓地存在通常陷阱卡
function s.atkcon(e)
	-- 检查自己墓地是否存在至少一张通常陷阱卡
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
-- 场上的昆虫族或植物族怪兽过滤器
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT+RACE_PLANT)
end
-- 效果③的发动时选择目标函数，根据场上昆虫族或植物族怪兽数量选择最多数量的对方场上的表侧表示的卡
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上的昆虫族或植物族怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,0,nil)
	-- 判断是否为选择目标阶段，目标必须是对方场上的表侧表示的卡且可被无效化
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 判断效果③是否可以发动，即场上存在满足条件的目标卡
	if chk==0 then return ct>0 and Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择最多数量的对方场上的表侧表示的卡作为无效对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置操作信息，记录将要无效的卡的数量
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
-- 墓地陷阱卡过滤器，用于检测墓地是否存在可除外的通常陷阱卡
function s.rmfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsAbleToRemove()
end
-- 效果③的发动处理函数，使选中的卡效果无效并可能破坏一张卡
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与当前连锁相关的已选择目标，并筛选出表侧表示的卡
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsFaceup,nil)
	if #g==0 then return end
	local tc=g:GetFirst()
	while tc do
		-- 使目标卡的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 效果③的处理：使目标卡的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 效果③的处理：使目标卡的效果被无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 效果③的处理：使陷阱怪兽的效果被无效化
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
	-- 手动刷新场上受影响卡牌的状态
	Duel.AdjustInstantly(c)
	-- 检查自己墓地是否存在可除外的通常陷阱卡
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_GRAVE,0,1,nil)
		-- 询问玩家是否选择其中一张破坏
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否选其中1张破坏？"
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从自己墓地中选择一张通常陷阱卡除外
		local rg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		local tg=g:Filter(Card.IsFaceup,nil)
		-- 判断是否成功除外卡并进行后续破坏操作
		if #rg>0 and #tg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 显示被选为对象的卡
			Duel.HintSelection(sg)
			-- 将选中的卡破坏
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
