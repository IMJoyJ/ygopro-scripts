--セネトの啓示者－ネフェルタリ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，把这张卡送去墓地才能发动。选自己的手卡·卡组·场上（表侧表示）·墓地最多2张通常怪兽卡，给双方确认。那之后，那个数量的「塞尼特」魔法卡从卡组到自己场上盖放。
-- ②：对方回合，把墓地的这张卡除外才能发动。从自己墓地把1只通常怪兽当作装备魔法卡使用给自己场上1只仪式怪兽装备。
local s,id,o=GetID()
-- 初始化卡片效果：注册登场送墓确认通常怪兽盖放「塞尼特」魔法卡以及对方回合墓地除外将墓地通常怪兽给仪式怪兽装备效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，把这张卡送去墓地才能发动。选自己的手卡·卡组·场上（表侧表示）·墓地最多2张通常怪兽卡，给双方确认。那之后，那个数量的「塞尼特」魔法卡从卡组到自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.setcost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：对方回合，把墓地的这张卡除外才能发动。从自己墓地把1只通常怪兽当作装备魔法卡使用给自己场上1只仪式怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"状态"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.eqcon)
	-- 发动代价：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
end
-- 发动代价：把这张卡送去墓地
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤表侧表示的通常怪兽卡
function s.chkfilter(c)
	return c:IsFaceupEx() and c:IsAllCardTypes(TYPE_NORMAL+TYPE_MONSTER)
end
-- 过滤卡组中可以盖放的「塞尼特」魔法卡
function s.setfilter(c)
	return c:IsSetCard(0x1eb) and c:IsSSetable() and c:IsType(TYPE_SPELL)
end
-- 盖放效果的发动条件检查
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡·卡组·场上·墓地是否存在通常怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_DECK,0,1,nil)
		-- 检查卡组是否存在可以盖放的「塞尼特」魔法卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 检查选取的卡片组中场地魔法数量与魔陷区可用空格是否匹配
function s.gcheck(g,ft,res)
	-- 检查非场地魔法卡的数量是否不超过魔陷区可用空格数
	return (g:FilterCount(aux.NOT(Card.IsType),nil,TYPE_FIELD)<=ft-1 or res)
		and g:FilterCount(Card.IsType,nil,TYPE_FIELD)<=1
end
-- 选最多2张通常怪兽卡给双方确认，并将同等数量的「塞尼特」魔法卡从卡组盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有可以盖放的「塞尼特」魔法卡
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()==0 then return end
	-- 获取魔法与陷阱区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft>=2 then ft=2 end
	local res=true
	if g:IsExists(Card.IsType,1,nil,TYPE_FIELD) and ft<2 then
		ft=ft+1
		res=false
	end
	-- 获取手卡·墓地·场上·卡组中所有通常怪兽卡
	local cg=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_DECK,0,nil)
	local dt=g:GetCount()
	-- 若仅能盖放场地魔法则将可操作卡片上限限制为1张
	if dt>1 and not g:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_FIELD) then dt=1 end
	local ct=math.min(ft,dt,cg:GetCount())
	if ct==0 then return end
	-- 提示玩家选择给双方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local rg=cg:Select(tp,1,ct,nil)
	if rg:GetCount()>0 then
		local hg=rg:Filter(Card.IsLocation,nil,LOCATION_HAND+LOCATION_DECK)
		local og=rg-hg
		-- 将选中的手卡或卡组中的卡给对方确认
		Duel.ConfirmCards(1-tp,hg)
		-- 为选中的场上或墓地的卡显示确认提示
		Duel.HintSelection(og)
		if hg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)>0 then
			-- 洗切被确认的手卡
			Duel.ShuffleHand(tp)
		end
		if g:GetCount()>0 then
			-- 提示玩家选择要盖放的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:SelectSubGroup(tp,s.gcheck,false,rg:GetCount(),rg:GetCount(),ft,res)
			if sg:GetCount()>0 then
				-- 将选中的「塞尼特」魔法卡盖放到自己场上
				Duel.SSet(tp,sg)
			end
		end
	end
end
-- 装备效果的发动时点检查：仅在对方回合可以发动
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤墓地中可作为装备卡且场上有合法装备对象的通常怪兽
function s.eqfilter(c,tp)
	return  c:IsType(TYPE_NORMAL) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		-- 检查自己场上是否存在表侧表示的仪式怪兽
		and Duel.IsExistingMatchingCard(s.eqtgfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤自己场上表侧表示的仪式怪兽
function s.eqtgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL)
end
-- 装备效果的发动条件检查与操作信息设置
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区域是否有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查墓地是否存在可以作为装备卡使用的通常怪兽
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 设置操作信息：1张卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
-- 从自己墓地把1只通常怪兽当作装备魔法卡装备给场上的仪式怪兽
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己魔陷区域是否有可用空格
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要作为装备卡的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从墓地选择1只不受王长影响的通常怪兽作为装备卡
		local ec=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
		if ec then
			-- 提示玩家选择要装备的对象怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 从自己场上选择1只仪式怪兽作为装备对象
			local tc=Duel.SelectMatchingCard(tp,s.eqtgfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
			-- 将选中的通常怪兽作为装备卡装备给仪式怪兽并检查是否成功
			if not Duel.Equip(tp,ec,tc) then return end
			-- 给自己场上1只仪式怪兽装备。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetLabelObject(tc)
			e1:SetValue(s.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e1)
		end
	end
end
-- 限制装备对象：仅当目标怪兽为当时选择的仪式怪兽时有效
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
