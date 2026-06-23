--万物の始源-「水」
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽的持有者场上1只水属性怪兽破坏，作为对象的怪兽在那个场上守备表示特殊召唤。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己或对方的墓地1只水属性怪兽为对象才能发动。那只怪兽的持有者场上1只怪兽破坏，作为对象的怪兽在那个场上守备表示特殊召唤。
local s,id,o=GetID()
-- 注册两个效果：①通常发动效果和②除外发动效果
function s.initial_effect(c)
	-- ①：以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽的持有者场上1只水属性怪兽破坏，作为对象的怪兽在那个场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target(nil))
	e1:SetOperation(s.activate(nil))
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己或对方的墓地1只水属性怪兽为对象才能发动。那只怪兽的持有者场上1只怪兽破坏，作为对象的怪兽在那个场上守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外并发动"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	-- 效果发动条件：这张卡在本回合没有被送去墓地
	e2:SetCondition(aux.exccon)
	-- 效果发动费用：将此卡从墓地除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target(ATTRIBUTE_WATER))
	e2:SetOperation(s.activate(ATTRIBUTE_WATER))
	c:RegisterEffect(e2)
end
-- 特殊召唤目标过滤函数：满足特殊召唤条件且其持有者场上存在可破坏的水属性怪兽
function s.spfilter(c,e,tp,att)
	if att and not c:IsAttribute(ATTRIBUTE_WATER) then return false end
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,c:GetOwner())
		-- 检查特殊召唤目标的持有者场上是否存在可破坏的水属性怪兽
		and Duel.IsExistingMatchingCard(s.desfilter,c:GetOwner(),LOCATION_MZONE,0,1,nil,c:GetOwner(),att,tp)
end
-- 破坏目标过滤函数：满足破坏条件且该怪兽为表侧表示且场上存在可用怪兽区
function s.desfilter(c,p,att,rp)
	if not att and not c:IsAttribute(ATTRIBUTE_WATER) then return false end
	-- 检查目标怪兽是否为表侧表示且场上存在可用怪兽区
	return c:IsFaceup() and Duel.GetMZoneCount(p,c,rp)>0
end
-- 效果处理函数：选择目标怪兽并设置操作信息
function s.target(att)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
			if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp,att) end
			-- 判断是否满足发动条件：场上存在满足特殊召唤条件的墓地怪兽
			if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,att) end
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择满足条件的墓地怪兽作为特殊召唤对象
			local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,att)
			local gc=g:GetFirst()
			-- 获取目标怪兽的持有者场上的所有怪兽作为破坏对象
			local dg=Duel.GetFieldGroup(gc:GetOwner(),LOCATION_MZONE,0)
			-- 设置操作信息：将要破坏的怪兽加入操作信息
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
			-- 设置操作信息：将要特殊召唤的怪兽加入操作信息
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
		end
end
-- 效果发动处理函数：执行特殊召唤和破坏操作
function s.activate(att)
	return function(e,tp,eg,ep,ev,re,r,rp)
			-- 获取当前连锁效果的目标怪兽
			local tc=Duel.GetFirstTarget()
			if not tc:IsRelateToEffect(e) then return end
			local sp=tc:GetOwner()
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择满足条件的场上怪兽作为破坏对象
			local g=Duel.SelectMatchingCard(tp,s.desfilter,sp,LOCATION_MZONE,0,1,1,nil,sp,att,tp)
			if g then
				-- 显示被选为破坏对象的动画效果
				Duel.HintSelection(g)
				-- 执行破坏操作并判断是否满足特殊召唤条件
				if Duel.Destroy(g,REASON_EFFECT)~=0 and aux.NecroValleyFilter()(tc) then
					-- 将目标怪兽特殊召唤到场上
					Duel.SpecialSummon(tc,0,tp,sp,false,false,POS_FACEUP_DEFENSE)
				end
			end
		end
end
