--星に願いを
-- 效果：
-- 选择自己场上表侧表示存在的1只怪兽发动。持有和选择的怪兽相同攻击力或者相同守备力的自己场上的怪兽的等级直到结束阶段时变成和选择的怪兽相同。
function c43661068.initial_effect(c)
	-- 效果发动，设置为自由连锁，具有取对象效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c43661068.target)
	e1:SetOperation(c43661068.activate)
	c:RegisterEffect(e1)
end
-- 选择自己场上表侧表示存在的1只怪兽发动
function c43661068.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c43661068.tfilter(chkc,tp) end
	-- 检查自己场上是否存在满足条件的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c43661068.tfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c43661068.tfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 过滤函数，用于判断怪兽是否满足等级改变条件
function c43661068.filter(c,atk,def)
	return c:IsFaceup() and c:GetLevel()>0 and (c:IsAttack(atk) or c:IsDefense(def))
end
-- 过滤函数，用于判断怪兽是否可以作为效果对象
function c43661068.tfilter(c,tp)
	return c:IsFaceup() and c:GetLevel()>0
		-- 检查是否存在与选择怪兽攻击力或守备力相同的怪兽
		and Duel.IsExistingMatchingCard(c43661068.filter,tp,LOCATION_MZONE,0,1,c,c:GetAttack(),c:GetDefense())
end
-- 效果处理函数，将符合条件的怪兽等级改为与选择怪兽相同
function c43661068.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 获取所有与对象怪兽攻击力或守备力相同的怪兽
		local g=Duel.GetMatchingGroup(c43661068.filter,tp,LOCATION_MZONE,0,tc,tc:GetAttack(),tc:GetDefense())
		local lv=tc:GetLevel()
		local lc=g:GetFirst()
		while lc do
			-- 设置等级改变效果，直到结束阶段时重置
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			lc:RegisterEffect(e1)
			lc=g:GetNext()
		end
	end
end
