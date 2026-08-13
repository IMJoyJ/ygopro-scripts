--コーリング・マジック
-- 效果：
-- 对方控制的魔法·陷阱卡的效果把盖放的这张卡破坏送去墓地时，从卡组选择1张速攻魔法卡给双方确认并在自己场上盖放。
function c41160595.initial_effect(c)
	-- 对方控制的魔法·陷阱卡的效果把盖放的这张卡破坏送去墓地时，从卡组选择1张速攻魔法卡给双方确认并在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41160595,0))  --"检索盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c41160595.setcon)
	e1:SetOperation(c41160595.setop)
	c:RegisterEffect(e1)
end
-- 诱发必发效果的发动条件判定：这张卡被对方控制的魔法·陷阱卡效果破坏并送去墓地，且破坏前以背面表示存在于我方场上（bit.band(r,0x41)==0x41表示破坏并送去墓地，rp==1-tp表示是对方效果，re:IsActiveType(TYPE_SPELL+TYPE_TRAP)限定为魔法·陷阱卡效果，c:IsPreviousControler(tp)和c:IsPreviousLocation(LOCATION_ONFIELD)和c:IsPreviousPosition(POS_FACEDOWN)确认之前在我方场上且为里侧表示）。
function c41160595.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,0x41)==0x41 and rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 过滤函数：选择类型为速攻魔法且当前可以盖放到魔陷区的卡片。
function c41160595.filter(c)
	return c:GetType()==TYPE_SPELL+TYPE_QUICKPLAY and c:IsSSetable()
end
-- 效果处理操作：先检查自己魔陷区是否有空位，空位不足则终止；否则向玩家展示选择提示，从自己卡组中选择1张满足条件的速攻魔法卡，并将其盖放到自己魔法陷阱区。
function c41160595.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己魔陷区是否有可用空位，没有空位则无法盖放，直接结束本次效果处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向操作玩家发送选择卡片的提示消息，内容为“请选择要盖放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己卡组中选出1张符合c41160595.filter条件的速攻魔法卡（此时不取对象，在效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c41160595.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的速攻魔法卡以背面表示盖放在自己场上（魔陷区）。
		Duel.SSet(tp,g:GetFirst())
	end
end
