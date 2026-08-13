--FNo.0 未来皇ホープ・ゼアル
-- 效果：
-- 相同阶级的超量怪兽×2
-- 规则上，这张卡的阶级当作1阶使用。
-- ①：这张卡的攻击力·守备力上升自己场上以及对方墓地的超量怪兽的阶级合计×500。
-- ②：对方怪兽不能选择其他怪兽作为攻击对象，对方不能把场上的其他卡作为效果的对象。
-- ③：1回合1次，对方在场上把效果发动时，把这张卡1个超量素材取除才能发动。得到对方场上1只怪兽的控制权。这个回合，这张卡不会被战斗·效果破坏。
local s,id,o=GetID()
-- 定义初始效果：添加超量召唤手续（相同阶级的超量怪兽×2）、①攻击力/守备力上升、②对方攻击对象限制和效果对象限制、③对方发动效果时取除素材获得控制权并附加破坏耐性。
function s.initial_effect(c)
	-- 为这张卡添加超量召唤手续：以2只超量怪兽为素材进行超量召唤，且素材怪兽阶级相同（由xyzcheck检查），同时允许在超量怪兽上重叠叠放。
	aux.AddXyzProcedureLevelFree(c,s.mfilter,s.xyzcheck,2,2)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力·守备力上升自己场上以及对方墓地的超量怪兽的阶级合计×500。（本段为攻击力上升部分）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：对方怪兽不能选择其他怪兽作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetValue(s.atlimit)
	c:RegisterEffect(e3)
	-- ②：对方不能把场上的其他卡作为效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e4:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e4:SetTarget(s.tgtg)
	-- 设置不能成为效果对象的判定函数：使对方的效果不能选择这些卡作为对象（使用aux.tgoval的快速判定）。
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- ③：1回合1次，对方在场上把效果发动时，把这张卡1个超量素材取除才能发动。得到对方场上1只怪兽的控制权。这个回合，这张卡不会被战斗·效果破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"得到控制权"
	e5:SetCategory(CATEGORY_CONTROL)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.ctcon)
	e5:SetCost(s.ctcost)
	e5:SetTarget(s.cttg)
	e5:SetOperation(s.ctop)
	c:RegisterEffect(e5)
end
-- 将这张卡登记为No.0编号，用于相关‘No.’规则判定以及‘规则上阶级当作1阶使用’的设定。
aux.xyz_number[id]=0
-- 超量召唤素材的过滤条件：素材怪兽必须是超量怪兽。
function s.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_XYZ)
end
-- 超量召唤素材组合检查：组合中所有怪兽的阶级必须相同（GetClassCount(Card.GetRank)==1）。
function s.xyzcheck(g)
	return g:GetClassCount(Card.GetRank)==1
end
-- ①的检索条件：选择自己场上及对方墓地的超量怪兽（IsFaceupEx用于覆盖场上表侧表示和墓地的卡）。
function s.atkfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_XYZ)
end
-- ①的攻击力上升值计算：获取符合条件的所有超量怪兽，将其阶级合计×500。
function s.atkval(e,c)
	-- 获取“自己场上”和“对方墓地”中满足atkfilter的超量怪兽集合，用于计算阶级合计。
	local g=Duel.GetMatchingGroup(s.atkfilter,c:GetControler(),LOCATION_MZONE,LOCATION_GRAVE,nil)
	return g:GetSum(Card.GetRank)*500
end
-- 攻击对象限制条件：当对象怪兽不是未来皇自身时，禁止对方怪兽选择该怪兽作为攻击对象。
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 效果对象限制的目标筛选：除未来皇自身以外的场上卡片均受保护。
function s.tgtg(e,c)
	return c~=e:GetHandler()
end
-- ③的发动条件：未来皇不处于战斗破坏确定状态；效果由对方发动；且该效果在场上发动或为魔法·陷阱卡的发动。
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and ep==1-tp
		and ((re:GetActivateLocation()&LOCATION_ONFIELD)>0 or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- ③的发动代价：从未来皇身上取除1个超量素材；chk==0时仅检查是否存在可取除的素材。
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 选取控制权改变对象的过滤条件：该怪兽的控制权可以变更。
function s.tgfilter(c)
	return c:IsControlerCanBeChanged()
end
-- ③的发动目标：检查对方场上是否存在可变更控制权的怪兽，并设置操作信息为夺取控制权（CATEGORY_CONTROL）。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查：确认对方场上有至少1只满足tgfilter的怪兽才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示“你选择了发动此效果”，并显示效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本次效果处理为夺取对方场上1只怪兽的控制权，供后续效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
-- ③的效果处理：选择对方场上1只可变更控制权的怪兽获得其控制权；之后未来皇本回合获得不会被战斗·效果破坏的效果。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示选择提示，让玩家选择要变更控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方场上选择1只满足tgfilter的怪兽作为控制权夺取对象。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 显示选中怪兽的对象动画，并将其标记为本连锁的对象。
		Duel.HintSelection(g)
		-- 将选中的怪兽控制权转移给未来皇的控制者。
		Duel.GetControl(tc,tp)
	end
	if c:IsRelateToChain() then
		-- 这个回合，这张卡不会被战斗·效果破坏。（本段为战斗破坏耐性部分）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		c:RegisterEffect(e2)
	end
end
