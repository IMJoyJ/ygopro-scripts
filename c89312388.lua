--E・HERO プリズマー
-- 效果：
-- ①：1回合1次，把额外卡组1只融合怪兽给对方观看，把那只怪兽有卡名记述的1只融合素材怪兽从卡组送去墓地才能发动。直到结束阶段，这张卡当作和为这个效果发动而送去墓地的怪兽同名卡使用。
function c89312388.initial_effect(c)
	-- ①：1回合1次，把额外卡组1只融合怪兽给对方观看，把那只怪兽有卡名记述的1只融合素材怪兽从卡组送去墓地才能发动。直到结束阶段，这张卡当作和为这个效果发动而送去墓地的怪兽同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89312388,0))  --"变成同名卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c89312388.coscost)
	e1:SetOperation(c89312388.cosoperation)
	c:RegisterEffect(e1)
end
-- 过滤卡组中作为指定融合怪兽素材且能作为代价送去墓地的怪兽
function c89312388.filter2(c,fc)
	-- 检查卡片是否在融合怪兽的素材卡名列表中，且能作为代价送去墓地
	return aux.IsMaterialListCode(fc,c:GetCode()) and c:IsAbleToGraveAsCost()
end
-- 过滤额外卡组中存在可用素材在卡组的融合怪兽
function c89312388.filter1(c,tp)
	-- 检查卡片是否为融合怪兽，且卡组中存在至少1张该融合怪兽记述卡名的素材怪兽
	return c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(c89312388.filter2,tp,LOCATION_DECK,0,1,nil,c)
end
-- 发动代价：展示额外卡组1只融合怪兽，并将该怪兽记述的1只素材怪兽从卡组送去墓地，并记录该素材的卡名
function c89312388.coscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：额外卡组是否存在可展示的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c89312388.filter1,tp,LOCATION_EXTRA,0,1,nil,tp) end
	-- 提示玩家选择要确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从额外卡组选择1只满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c89312388.filter1,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	-- 给对方玩家确认选择的融合怪兽
	Duel.ConfirmCards(1-tp,g)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张被确认融合怪兽记述的素材怪兽
	local cg=Duel.SelectMatchingCard(tp,c89312388.filter2,tp,LOCATION_DECK,0,1,1,nil,g:GetFirst())
	-- 将选择的素材怪兽作为发动代价送去墓地
	Duel.SendtoGrave(cg,REASON_COST)
	e:SetLabel(cg:GetFirst():GetCode())
end
-- 效果处理：使自身直到结束阶段当作送去墓地的怪兽的同名卡使用，并注册结束阶段重置卡名的效果
function c89312388.cosoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 直到结束阶段，这张卡当作和为这个效果发动而送去墓地的怪兽同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(e:GetLabel())
	c:RegisterEffect(e1)
	-- 直到结束阶段，这张卡当作和为这个效果发动而送去墓地的怪兽同名卡使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89312388,1))  --"变成同名卡的效果结束"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e2:SetLabelObject(e1)
	e2:SetOperation(c89312388.rstop)
	c:RegisterEffect(e2)
end
-- 结束阶段重置卡名效果的函数
function c89312388.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 在场上选中这张卡以示效果重置
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家提示该卡片的效果已结束
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
