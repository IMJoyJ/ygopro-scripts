--インフェルニティ・ポーン
-- 效果：
-- ①：自己手卡是0张的场合，自己抽卡阶段可以作为进行通常抽卡的代替，把墓地的这张卡除外，从以下效果选择1个发动。
-- ●从卡组选1张「永火」卡在卡组最上面放置。
-- ●从卡组选1张「炼狱」魔法·陷阱卡在自己场上盖放。
function c82434071.initial_effect(c)
	-- ①：自己手卡是0张的场合，自己抽卡阶段可以作为进行通常抽卡的代替，把墓地的这张卡除外，从以下效果选择1个发动。●从卡组选1张「永火」卡在卡组最上面放置。●从卡组选1张「炼狱」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82434071,0))  --"发动「永火兵卒」的效果代替抽卡"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCondition(c82434071.opcon)
	-- 将墓地的这张卡除外作为发动的Cost
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c82434071.optg)
	e1:SetOperation(c82434071.opop)
	c:RegisterEffect(e1)
end
-- 效果发动条件函数：自己回合且手卡为0张
function c82434071.opcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合，且自己手卡数量为0
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 过滤条件：卡名含有「永火」的卡
function c82434071.ttopfilter(c)
	return c:IsSetCard(0xb)
end
-- 过滤条件：卡名含有「炼狱」的魔法·陷阱卡，且可以在场上盖放
function c82434071.ssetfilter(c)
	return c:IsSetCard(0xc5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果发动靶向（Target）函数：检查是否满足代替抽卡的条件，并让玩家选择要适用的分支效果
function c82434071.optg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「永火」卡，且卡组卡片数量大于1
	local b1=Duel.IsExistingMatchingCard(c82434071.ttopfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
	-- 检查卡组中是否存在可以盖放的「炼狱」魔法·陷阱卡
	local b2=Duel.IsExistingMatchingCard(c82434071.ssetfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查阶段：玩家必须能够进行通常抽卡，且两个分支效果中至少有一个可以适用
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and (b1 or b2) end
	-- 使玩家放弃本回合抽卡阶段的通常抽卡
	aux.GiveUpNormalDraw(e,tp)
	local off=1
	local ops,opval={},{}
	if b1 then
		ops[off]=aux.Stringid(82434071,1)  --"从卡组选1张「永火」卡在卡组最上面放置"
		opval[off]=0
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(82434071,2)  --"从卡组选1张「炼狱」魔法·陷阱卡在自己场上盖放"
		opval[off]=1
		off=off+1
	end
	-- 让玩家从可用的分支效果中选择一个
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	if sel==1 then
		e:SetCategory(CATEGORY_SSET)
	else
		e:SetCategory(0)
	end
	e:SetLabel(sel)
end
-- 效果运行（Operation）函数：根据玩家选择的分支，执行对应的卡组操作
function c82434071.opop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==0 then
		-- 提示玩家选择要放置在卡组最上面的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(82434071,3))  --"请选择要放置在卡组最上面的卡"
		-- 从卡组中选择1张「永火」卡
		local g=Duel.SelectMatchingCard(tp,c82434071.ttopfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 洗切卡组
			Duel.ShuffleDeck(tp)
			-- 将选中的卡移动到卡组最上面
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			-- 确认并展示卡组最上方的一张卡
			Duel.ConfirmDecktop(tp,1)
		end
	else
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组中选择1张满足条件的「炼狱」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c82434071.ssetfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡在自己场上盖放
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
