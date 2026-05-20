--CNo.5 亡朧龍 カオス・キマイラ・ドラゴン
-- 效果：
-- 6星怪兽×3只以上
-- ①：这张卡的攻击力上升这张卡的超量素材数量×1000。
-- ②：这张卡进行攻击的伤害步骤结束时，把这张卡1个超量素材取除才能发动。这张卡向对方怪兽可以继续攻击。
-- ③：战斗阶段结束时，把基本分支付一半，以自己·对方的墓地的卡合计2张为对象才能发动。那之内的1张在持有者卡组最上面放置，另1张在这张卡下面重叠作为超量素材。
function c69757518.initial_effect(c)
	-- 设置XYZ召唤手续：等级6怪兽3只以上（最多99只）
	aux.AddXyzProcedure(c,nil,6,3,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c69757518.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡进行攻击的伤害步骤结束时，把这张卡1个超量素材取除才能发动。这张卡向对方怪兽可以继续攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69757518,0))  --"再次攻击"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(c69757518.atcon)
	e2:SetCost(c69757518.atcost)
	e2:SetOperation(c69757518.atop)
	c:RegisterEffect(e2)
	-- ③：战斗阶段结束时，把基本分支付一半，以自己·对方的墓地的卡合计2张为对象才能发动。那之内的1张在持有者卡组最上面放置，另1张在这张卡下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(69757518,1))  --"请选择要返回卡组的卡"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c69757518.cost)
	e3:SetTarget(c69757518.target)
	e3:SetOperation(c69757518.operation)
	c:RegisterEffect(e3)
end
-- 设定该怪兽的“No.”数值为5
aux.xyz_number[69757518]=5
-- 攻击力上升值计算函数：返回超量素材数量×1000
function c69757518.atkval(e,c)
	return c:GetOverlayCount()*1000
end
-- 再次攻击效果的发动条件：此卡是当前攻击怪兽且可以继续进行连击
function c69757518.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前攻击怪兽是否为自身，且自身是否满足可以继续攻击的条件
	return Duel.GetAttacker()==c and c:IsChainAttackable(0,true)
end
-- 再次攻击效果的代价：取除此卡的1个超量素材
function c69757518.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 再次攻击效果的处理：使此卡可以继续攻击，并添加不能直接攻击的限制
function c69757518.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() then return end
	-- 使当前攻击怪兽可以再进行1次攻击
	Duel.ChainAttack()
	-- 这张卡向对方怪兽可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE+PHASE_DAMAGE_CAL)
	c:RegisterEffect(e1)
end
-- 效果③的代价：支付一半基本分
function c69757518.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 扣除发动玩家当前基本分的一半（向下取整）
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 墓地目标卡片的过滤条件：可以被选为效果对象，且可以回到卡组或可以作为超量素材
function c69757518.tdfilter(c,e)
	return c:IsCanBeEffectTarget(e) and (c:IsAbleToDeck() or c:IsCanOverlay())
end
-- 目标卡组的合法性检查：选出的2张卡中必须至少有1张可以作为超量素材
function c69757518.gcheck(g)
	return g:IsExists(Card.IsCanOverlay,1,nil)
end
-- 效果③的发动准备：选择双方墓地合计2张卡作为对象，并声明操作信息
function c69757518.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取双方墓地中满足过滤条件的所有卡片
	local g=Duel.GetMatchingGroup(c69757518.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and g:CheckSubGroup(c69757518.gcheck,2,2) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,c69757518.gcheck,false,2,2)
	-- 将选中的卡片组注册为当前连锁的对象
	Duel.SetTargetCard(sg)
	-- 设置操作信息：预计将对象中的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,1,0,0)
	-- 设置操作信息：预计有2张卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,2,0,0)
end
-- 效果③的效果处理：将其中1张卡放回卡组最上面，另1张重叠作为此卡的超量素材
function c69757518.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()==1 then
		-- 闪烁显示被选为对象的卡片
		Duel.HintSelection(sg)
		-- 将目标卡片送回持有者卡组的最上方
		Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
	elseif sg:GetCount()>1 then
		local og=sg:Filter(Card.IsCanOverlay,nil)
		local sg1=nil
		if og:GetCount()==0 then
			return
		elseif og:GetCount()==1 then
			sg1=sg-og
		elseif og:GetCount()==2 then
			-- 提示玩家选择要返回卡组的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			sg1=sg:Select(tp,1,1,nil)
		end
		local c=e:GetHandler()
		-- 闪烁显示被选择放回卡组的卡片
		Duel.HintSelection(sg1)
		-- 如果成功将其中1张卡放回卡组最上面，且此卡仍在场上
		if Duel.SendtoDeck(sg1,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
			sg:Sub(sg1)
			local sc=sg:GetFirst()
			if sc:IsCanOverlay() then
				-- 将剩下的另1张卡重叠在此卡下方作为超量素材
				Duel.Overlay(c,sg)
			end
		end
	end
end
