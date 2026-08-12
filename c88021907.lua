--塊斬機ラプラシアン
-- 效果：
-- 4星怪兽×3
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡超量召唤成功的场合，可以把这张卡最多3个超量素材取除，从以下效果选择那个数量发动。
-- ●对方手卡随机选1张送去墓地。
-- ●选对方场上1只怪兽送去墓地。
-- ●选对方场上1张魔法·陷阱卡送去墓地。
-- ②：自己场上的「斩机」卡被效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
function c88021907.initial_effect(c)
	-- 设置该怪兽的超量召唤手续为4星怪兽×3
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功的场合，可以把这张卡最多3个超量素材取除，从以下效果选择那个数量发动。●对方手卡随机选1张送去墓地。●选对方场上1只怪兽送去墓地。●选对方场上1张魔法·陷阱卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88021907,4))  --"取除超量素材选择效果发动"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,88021907)
	e1:SetCost(c88021907.ctcost)
	e1:SetCondition(c88021907.effcon)
	e1:SetTarget(c88021907.efftg)
	e1:SetOperation(c88021907.effop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「斩机」卡被效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c88021907.desreptg)
	e2:SetValue(c88021907.desrepval)
	e2:SetOperation(c88021907.desrepop)
	c:RegisterEffect(e2)
end
-- 检查此卡是否为超量召唤成功，作为①效果的发动条件
function c88021907.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- ①效果的发动代价：根据对方手牌、怪兽区、魔陷区是否存在卡片，决定最多可取除的超量素材数量（最多3个），并取除至少1个素材，将取除的数量作为标签保存
function c88021907.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rt=3
	-- 若对方手牌没有卡，则将最大可选效果数量减1
	if not Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_HAND,1,nil) then rt=rt-1 end
	-- 若对方怪兽区没有卡，则将最大可选效果数量减1
	if not Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) then rt=rt-1 end
	-- 若对方场上没有魔法·陷阱卡，则将最大可选效果数量减1
	if not Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) then rt=rt-1 end
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local ct=c:RemoveOverlayCard(tp,1,rt,REASON_COST)
	e:SetLabel(ct)
end
-- ①效果的目标选择：根据取除的素材数量，让玩家依次选择对应数量的非重复子效果，并设置相应的效果分类与操作信息
function c88021907.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌是否存在卡片，作为“对方手卡随机选1张送去墓地”效果是否可选的依据
	local b1=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_HAND,1,nil)
	-- 检查对方场上是否存在怪兽，作为“选对方场上1只怪兽送去墓地”效果是否可选的依据
	local b2=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	-- 检查对方场上是否存在魔法·陷阱卡，作为“选对方场上1张魔法·陷阱卡送去墓地”效果是否可选的依据
	local b3=Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP)
	if chk==0 then return b1 or b2 or b3 end
	local ct=e:GetLabel()
	local sel=0
	local off=0
	repeat
		local ops={}
		local opval={}
		off=1
		if b1 then
			ops[off]=aux.Stringid(88021907,0)  --"对方手卡随机选1张送去墓地"
			opval[off-1]=1
			off=off+1
		end
		if b2 then
			ops[off]=aux.Stringid(88021907,1)  --"选对方场上1只怪兽送去墓地"
			opval[off-1]=2
			off=off+1
		end
		if b3 then
			ops[off]=aux.Stringid(88021907,2)  --"选对方场上1张魔法·陷阱卡送去墓地"
			opval[off-1]=3
			off=off+1
		end
		-- 让玩家从当前可选的子效果中选择一个
		local op=Duel.SelectOption(tp,table.unpack(ops))
		if opval[op]==1 then
			sel=sel+1
			b1=false
		elseif opval[op]==2 then
			sel=sel+2
			b2=false
		else
			sel=sel+4
			b3=false
		end
		ct=ct-1
	until ct==0 or off<3
	e:SetLabel(sel)
	if bit.band(sel,1)~=0 then
		-- 设置效果处理信息：将对方手牌的1张卡送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
	end
	if bit.band(sel,2)~=0 then
		-- 设置效果处理信息：将对方场上的1只怪兽送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE)
	end
	if bit.band(sel,3)~=0 then
		-- 获取对方场上所有的魔法·陷阱卡
		local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
		-- 设置效果处理信息：将对方场上的1张魔法·陷阱卡送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	end
end
-- 过滤条件：对方场上可以送去墓地的魔法·陷阱卡
function c88021907.tgfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- ①效果的效果处理：根据之前选择的子效果组合，依次执行对应的送去墓地操作
function c88021907.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if bit.band(sel,1)~=0 then
		-- 获取对方的所有手牌
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if g:GetCount()>0 then
			local sg=g:RandomSelect(tp,1)
			-- 将随机选出的对方手牌送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
	if bit.band(sel,2)~=0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家选择对方场上1只可以送去墓地的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 选中卡片的视觉提示（向对方展示所选的卡）
			Duel.HintSelection(g)
			-- 将选中的对方怪兽送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
	if bit.band(sel,4)~=0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家选择对方场上1张可以送去墓地的魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c88021907.tgfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 选中卡片的视觉提示（向对方展示所选的卡）
			Duel.HintSelection(g)
			-- 将选中的对方魔法·陷阱卡送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 过滤条件：自己场上因效果破坏而需要被代替破坏的表侧表示「斩机」卡
function c88021907.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:IsSetCard(0x132)
end
-- 代替破坏效果的目标与条件判断：检查是否有自己场上的「斩机」卡被效果破坏，且此卡拥有至少1个超量素材
function c88021907.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c88021907.repfilter,1,nil,tp)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 询问玩家是否使用代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 确定代替破坏效果的适用对象（即符合过滤条件的「斩机」卡）
function c88021907.desrepval(e,c)
	return c88021907.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的处理：取除此卡的1个超量素材作为代替
function c88021907.desrepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	-- 提示该卡的效果正在适用（展示卡片动画）
	Duel.Hint(HINT_CARD,0,88021907)
end
