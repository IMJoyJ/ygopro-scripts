--マジック・ガードナー
-- 效果：
-- 选择自己场上表侧表示存在的1张魔法卡才能发动。给选择的卡放置1个指示物。选择的卡被破坏的场合，作为代替把1个指示物取除。
function c61844784.initial_effect(c)
	-- 选择自己场上表侧表示存在的1张魔法卡才能发动。给选择的卡放置1个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c61844784.addct)
	e1:SetOperation(c61844784.addc)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示且可以放置该指示物的魔法卡
function c61844784.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsCanAddCounter(0x102a,1)
end
-- 效果发动时的对象选择与合法性检查
function c61844784.addct(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c61844784.filter(chkc) and chkc~=e:GetHandler() end
	-- 检查自己场上是否存在可以作为对象的表侧表示魔法卡
	if chk==0 then return Duel.IsExistingTarget(c61844784.filter,tp,LOCATION_SZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择一张表侧表示的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(61844784,0))  --"请选择一张表侧表示的魔法卡"
	-- 选择自己场上1张表侧表示的魔法卡作为效果对象
	Duel.SelectTarget(tp,c61844784.filter,tp,LOCATION_SZONE,0,1,1,e:GetHandler())
end
-- 效果处理：给选择的卡放置1个指示物，并为其注册代替破坏的效果
function c61844784.addc(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x102a,1)
		-- 选择的卡被破坏的场合，作为代替把1个指示物取除。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EFFECT_DESTROY_REPLACE)
		e1:SetTarget(c61844784.reptg)
		e1:SetOperation(c61844784.repop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 检查代替破坏的条件：不是规则破坏且该卡上存在至少1个该指示物
function c61844784.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return bit.band(r,REASON_RULE)==0
		and e:GetHandler():GetCounter(0x102a)>0 end
	return true
end
-- 代替破坏的处理：取除该卡上的1个指示物
function c61844784.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x102a,1,REASON_EFFECT)
end
