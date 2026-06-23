--FNo.0 未来皇ホープ・ゼアル
-- 效果：
-- 相同阶级的超量怪兽×2
-- 规则上，这张卡的阶级当作1阶使用。
-- ①：这张卡的攻击力·守备力上升自己场上以及对方墓地的超量怪兽的阶级合计×500。
-- ②：对方怪兽不能选择其他怪兽作为攻击对象，对方不能把场上的其他卡作为效果的对象。
-- ③：1回合1次，对方在场上把效果发动时，把这张卡1个超量素材取除才能发动。得到对方场上1只怪兽的控制权。这个回合，这张卡不会被战斗·效果破坏。
local s,id,o=GetID()
-- 初始化效果，设置XYZ召唤手续、启用复活限制，并注册攻击力和守备力上升效果、不能被选为攻击对象效果、不能成为效果对象效果以及控制权变更效果
function s.initial_effect(c)
	-- 添加XYZ召唤手续，要求使用2只相同阶级的超量怪兽进行召唤
	aux.AddXyzProcedureLevelFree(c,s.mfilter,s.xyzcheck,2,2)
	c:EnableReviveLimit()
	-- 设置自身攻击力上升效果，上升值为己方场上和对方墓地的超量怪兽数值总和×500
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
	-- 设置对方怪兽不能选择自身作为攻击对象
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetValue(s.atlimit)
	c:RegisterEffect(e3)
	-- 设置对方不能把自身以外的场上卡作为效果对象
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e4:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e4:SetTarget(s.tgtg)
	-- 设置效果对象过滤函数，使对方效果不能作用于自身
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- 设置控制权变更效果，对方在场上发动效果时可消耗1个超量素材获得对方1只怪兽控制权
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
-- 设置该卡的XYZ编号为0
aux.xyz_number[id]=0
-- 设置怪兽过滤函数，用于筛选超量怪兽
function s.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_XYZ)
end
-- 设置XYZ召唤检查函数，确保叠放的怪兽阶级相同
function s.xyzcheck(g)
	return g:GetClassCount(Card.GetRank)==1
end
-- 设置攻击力计算过滤函数，筛选场上和墓地的超量怪兽
function s.atkfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_XYZ)
end
-- 设置攻击力计算函数，计算己方场上和对方墓地的超量怪兽阶级总和并乘以500
function s.atkval(e,c)
	-- 获取己方场上和对方墓地的超量怪兽组
	local g=Duel.GetMatchingGroup(s.atkfilter,c:GetControler(),LOCATION_MZONE,LOCATION_GRAVE,nil)
	return g:GetSum(Card.GetRank)*500
end
-- 设置攻击限制函数，使对方怪兽不能选择自身作为攻击对象
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 设置效果对象过滤函数，使对方效果不能作用于自身
function s.tgtg(e,c)
	return c~=e:GetHandler()
end
-- 设置控制权变更效果发动条件，对方在场上发动效果时且自身未被战斗破坏
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and ep==1-tp
		and ((re:GetActivateLocation()&LOCATION_ONFIELD)>0 or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 设置控制权变更效果消耗，消耗1个超量素材
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置选择目标过滤函数，筛选可改变控制权的怪兽
function s.tgfilter(c)
	return c:IsControlerCanBeChanged()
end
-- 设置控制权变更效果目标选择函数，检查对方场上是否存在可改变控制权的怪兽
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可改变控制权的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向对方提示发动了控制权变更效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将要改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
-- 设置控制权变更效果处理函数，选择对方场上一只怪兽并获得其控制权，同时使自身在本回合内不会被战斗或效果破坏
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上一只可改变控制权的怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 显示所选怪兽被选为对象的动画效果
		Duel.HintSelection(g)
		-- 获得所选怪兽的控制权
		Duel.GetControl(tc,tp)
	end
	if c:IsRelateToChain() then
		-- 设置自身在本回合内不会被战斗破坏的效果
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
