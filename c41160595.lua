--コーリング・マジック
-- 效果：
-- 对方控制的魔法·陷阱卡的效果把盖放的这张卡破坏送去墓地时，从卡组选择1张速攻魔法卡给双方确认并在自己场上盖放。
function c41160595.initial_effect(c)
	-- 创建效果，描述为“检索盖放”，分类为盖放，类型为单体诱发必发效果，时点为送去墓地
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41160595,0))  --"检索盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c41160595.setcon)
	e1:SetOperation(c41160595.setop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：被破坏的原因包含REASON_EFFECT和REASON_DESTROY，破坏者为对方，破坏的卡为魔法或陷阱卡，破坏前控制者为玩家，破坏前位置为场上，破坏前表示形式为背面表示
function c41160595.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,0x41)==0x41 and rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 过滤函数，筛选出类型为速攻魔法且可以盖放的魔法卡
function c41160595.filter(c)
	return c:GetType()==TYPE_SPELL+TYPE_QUICKPLAY and c:IsSSetable()
end
-- 效果处理：若场上魔陷区有空位，则提示选择速攻魔法卡并盖放
function c41160595.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上魔陷区是否还有空位，若无则不执行后续操作
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向玩家发送提示信息“请选择要盖放的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择1张满足条件的速攻魔法卡
	local g=Duel.SelectMatchingCard(tp,c41160595.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的速攻魔法卡盖放在玩家场上
		Duel.SSet(tp,g:GetFirst())
	end
end
